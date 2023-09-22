
# pentru selectare perioada timp sepcifica fiecarui parametru
observeEvent(input$temporal_resolution, {
  choice_filt <- 
    switch(
      input$temporal_resolution,
      hourly = select_meteo_hourly,
      daily = select_meteo_daily
    )
  updateSelectInput(
    session, "parameter_meteo",
    choices = choice_filt,
    selected = choice_filt[2]
  )
  
})



data_sel <- reactive({
  net <- input$network_data
  # selectie unitate
  switch( # alege nume indicator care să fie afișat
    which(c("ws", "ec", "bu") %in%  net),
    admin_spat <- ws,
  )
  data_sub <- 
    switch(
      input$temporal_resolution,
      hourly = hourly,
      daily = daily
    )
  timesel_sub <- 
    switch(
      input$temporal_resolution,
      hourly = input$datetime_meteo,
      daily = input$date_meteo
    )
  print(timesel_sub)
  
  data_sub <- data_sub |> 
    filter(
      time == timesel_sub,
      variable == input$parameter_meteo
    )  |> collect()
  print(data_sub)
  
  list(
    admin_spat = admin_spat
  )
  
})


# harta leaflet -----------------------------------------------------------
output$map_data <- renderLeaflet({
  leaflet_fun_data(
    data = isolate(data_sel()$admin_spat)
  )
})

observe({
  data <- data_sel()$admin_spat
  # pentru zoom retea observatii vizualizata
  bbox <- st_bbox(data) |> as.vector()
  
  leafletProxy("map_data", data = data) |>
    mapOptions(zoomToLimits = "first") |>
    clearMarkers() |>
    addMarkers(
      label =  ~paste("<font size='2'><b>",Name,"</b></font><br/><font size='1' color='#E95420'>Click to
                       get data</font>") %>% lapply(htmltools::HTML),
      group = "Network",
      layerId = ~Name
      #clusterOptions = markerClusterOptions(freezeAtZoom = T) 
    ) |> # pentru zoom limite retea incarcata
    fitBounds(bbox[1], bbox[2], bbox[3], bbox[4]) 
})





