data_sel <- reactive({
  net <- input$network_data
  # selectie unitate
  switch( # alege nume indicator care să fie afișat
    which(c("ws", "ec", "bu") %in%  net),
    admin_spat <- ws
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
  
  timesel_sub <-  # select aparm of interest
    switch(
      input$temporal_resolution,
      hourly = input$datetime_meteo,
      daily = input$date_meteo
    )
 
  data_sel <- data_sub |> 
    mutate(time = time) |>
    filter(
      variable == param_sub,
      time %in% timesel_sub
    ) |> collect()
  
 
  admin_spat <- admin_spat |> inner_join(data_sel, by = c("Name" = "id"))
  # print(admin_spat )
  
  
  list(
    admin_spat = admin_spat
  )
  
})


# harta leaflet -----------------------------------------------------------
output$map_data <- renderLeaflet({
  qpal <- colorQuantile("YlOrRd", isolate(data_sel()$admin_spat$values), n = 3)
  leaflet_fun_data(
    data = isolate(data_sel()$admin_spat), qpal = isolate(qpal)
  )
})

observe({
  data <- data_sel()$admin_spat
  # pentru zoom retea observatii vizualizata
  bbox <- st_bbox(data) |> as.vector()
  qpal <- colorQuantile("YlOrRd", data$values, n = 3)
  leafletProxy("map_data", data = data) |>
    mapOptions(zoomToLimits = "first") |>
    #clearMarkers() |>
    addCircles(
      stroke = FALSE,
      radius = 13000, weight = 5,
      color = ~qpal(values), fillOpacity = 1,
      label = ~paste("<font size='2'><b>",Name, values,"</b></font><br/><font size='1' color='#E95420'>Click to
      #                  get data</font>") %>% lapply(htmltools::HTML),
      group = "Network",
      layerId = ~Name
      #clusterOptions = markerClusterOptions(freezeAtZoom = T) 
    )  |>
    clearMarkers() |>
    addLabelOnlyMarkers(
      label = ~values,
      labelOptions = labelOptions(
        noHide = TRUE, textOnly = TRUE,
        direction = "center", offset = c(0,0), sticky = T,
        fontsize = 14
      )
    ) |> # pentru zoom limite retea incarcata
    fitBounds(bbox[1], bbox[2], bbox[3], bbox[4]) 
})





