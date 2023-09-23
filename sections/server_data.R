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
      time %in% timesel_sub,
      !is.na(values)
    ) |> collect()
  
  # join cu datele spatiale
  admin_spat <- admin_spat |> inner_join(data_sel, by = c("Name" = "id"))
  print(range(admin_spat$values))
  map_leg <- mapa_fun_cols(indic = param_sub, domain = range(admin_spat$values))

  list(
    admin_spat = admin_spat, pal = map_leg$pal, pal_rev = map_leg$pal_rev, 
    tit_leg = map_leg$tit_leg,  param_sub =  param_sub 
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

# update plot by click
observeEvent(input$map_data_shape_click$id,{ 
  print(input$map_data_shape_click$id)
})




