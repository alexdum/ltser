data_sel <- reactive({
  net <- input$network_data
  # selectie unitate
  admin_spat <- 
    switch( # alege nume indicator care să fie afișat
      which(c("ws", "ec", "bu") %in%  net),
      ws
    )
  data_sub <- # select dataset
    switch(
      input$temporal_resolution,
      hourly = hourly,
      daily = daily
    )
  param_sub <-  # select time slice
    switch(
      input$temporal_resolution,
      hourly = input$parameter_meteo,
      daily =  gsub("01h", "24h", input$parameter_meteo)
    )
  
  timesel_sub <-  # select timpe de interes timepicker
    switch(
      input$temporal_resolution,
      hourly = input$datetime_meteo,
      daily = input$date_meteo
    )
  
  data_sel <- 
    data_sub |> 
    filter(
      variable == param_sub,
      time %in% timesel_sub,
      !is.na(values)
    ) |> collect()
  
  # join cu datele spatiale
  admin_spat <- admin_spat |> inner_join(data_sel, by = c("Name" = "id"))
  
  map_leg <- mapa_fun_cols(indic = param_sub, domain = range(admin_spat$values))
  
  list(
    admin_spat = admin_spat, pal = map_leg$pal, pal_rev = map_leg$pal_rev, 
    tit_leg = map_leg$tit_leg,  param_sub =  param_sub, data_sub = data_sub, timesel_sub =   timesel_sub
  )
  
})


# harta leaflet -----------------------------------------------------------
output$map_data <- renderLeaflet({
  
  leaflet_fun_data(
    data = isolate(data_sel()$admin_spat),
    pal =  isolate(data_sel()$pal),
    pal_rev =  isolate(data_sel()$pal_rev),
    tit_leg = isolate(data_sel()$tit_leg)
  )
})

observe({
  
  pal_rev =  data_sel()$pal_rev
  tit_leg = data_sel()$tit_leg
  data <- data_sel()$admin_spat_sub
  pal <- data_sel()$pal
  data <- data_sel()$admin_spat
  # pentru zoom retea observatii vizualizata
  bbox <- st_bbox(data) |> as.vector()
  leafletProxy("map_data", data = data) |>
    mapOptions(zoomToLimits = "first") |>
    clearShapes() |>
    addCircles(
      stroke = FALSE,
      radius = 13000, weight = 5,
      color = ~pal(values), fillOpacity = 1,
      label = ~paste("<font size='2'><b>",Name, values,"</b></font><br/><font size='1' color='#E95420'>Click to
      #                  get data</font>") %>% lapply(htmltools::HTML),
      group = "Network",
      layerId = ~Name
      #clusterOptions = markerClusterOptions(freezeAtZoom = T) 
    ) |>
    clearMarkers() |>
    addLabelOnlyMarkers(
      label = ~values,
      labelOptions = labelOptions(
        noHide = TRUE, textOnly = TRUE,
        direction = "center", offset = c(0,0), sticky = T,
        fontsize = 14
      )
    ) |> # pentru zoom limite retea incarcata
    fitBounds(bbox[1], bbox[2], bbox[3], bbox[4]) |>
    clearControls() |>
    addLegend(
      title = tit_leg,
      "bottomleft", pal = pal_rev, values = ~values, opacity = 1,
      labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE))
    ) 
})

# reactive values pentru plot meteo
values_plot_meteo <- reactiveValues(
  id = NA, data = NA
)
# valoare de pronire 
observeEvent(list(isolate(input$tab_metadata),input$network_data),{
  
  values_plot_meteo$id <- unique(data_sel()$admin_spat$Name)[1] 
  print(values_plot_meteo$id)
})

# update plot by click
observeEvent(input$map_data_shape_click$id,{ 
  values_plot_meteo$id <- input$map_data_shape_click$id 

})

output$meteo_plot <- renderHighchart({
  
  
  time_threshold <- # pentru subset date ploturi/ descarcare
    switch(
      input$temporal_resolution,
      hourly = 3600 * 24 * 7,
      daily = 31
    )

  timesel_sub2 <-  data_sel()$timesel_sub -  time_threshold
  # selectie perechi parametri
  subset_param_meteo <- subset_param(input$parameter_meteo)

  # table pentru ploturi/descarcare date
  data_sel_tempo <-
    data_sel()$data_sub |>
    filter(
      time >= timesel_sub2  & time <= data_sel()$timesel_sub,
      substr(variable,1,2) %in%  subset_param_meteo,
      id %in% values_plot_meteo$id
    ) 

  data1 <- 
    data_sel_tempo |>
    filter(substr(variable,1,2) %in% subset_param_meteo[1]) |> 
    collect() 
  
  data2 <- 
    data_sel_tempo  |>
    filter(substr(variable,1,2) %in% subset_param_meteo[2]) |>
    collect() 
  # transforma orele in milisecunde
  if (input$temporal_resolution == "hourly") {
    data1$time <- as.numeric(data1$time) * 1000
    data2$time <- as.numeric(data2$time) * 1000
  }
  
  graph_meteo(data1, data2, title = values_plot_meteo$id, filename_save = "plot.png", y1lab = subset_param_meteo[1],  y2lab = subset_param_meteo[2])
})


