data_sel <- reactive({
  net <- input$network_data
  # selectie unitate
  switch( # alege nume indicator care să fie afișat
    which(c("ws", "ec", "bu") %in%  net),
    admin_spat <- ws,

  )
  
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
    mapOptions(zoomToLimits="first") |>
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





