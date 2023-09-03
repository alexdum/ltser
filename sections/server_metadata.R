metadata_sel <- reactive({
  net <- input$network
  # selectie unitate
  switch( # alege nume indicator care să fie afișat
    which(c("ws", "ec", "bu") %in%  net),
    admin_spat <- ws,
    admin_spat <- ec,
    admin_spat <- bu
  )
  
  list(
    admin_spat = admin_spat
  )
})

# harta leaflet -----------------------------------------------------------
output$map_metadata <- renderLeaflet({
  leaflet_fun_in(
    data = isolate(metadata_sel()$admin_spat)
  )
})

observe({
  data <- metadata_sel()$admin_spat
  # pentru zoom pe noul set de date
  bbox <- st_bbox(data) |> as.vector()
  
  leafletProxy("map_metadata", data = data) |>
    mapOptions(zoomToLimits="first") |>
    clearMarkers() |>
    addMarkers(
      label = ~Name,
      group = "Network"#
      #clusterOptions = markerClusterOptions(freezeAtZoom = T) 
    ) |> 
    fitBounds(bbox[1], bbox[2], bbox[3], bbox[4]) 
})

# network description -----------------------------------------------------

output$net_desc_markdown <- renderUI({
  HTML(net_des$description[net_des$network == input$network])
})

