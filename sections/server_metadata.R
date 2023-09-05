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
  leaflet_fun_meta(
    data = isolate(metadata_sel()$admin_spat)
  )
})

observe({
  data <- metadata_sel()$admin_spat
  # pentru zoom retea observatii vizualizata
  bbox <- st_bbox(data) |> as.vector()
  
  leafletProxy("map_metadata", data = data) |>
    mapOptions(zoomToLimits="first") |>
    clearMarkers() |>
    addMarkers(
      label =  ~paste("<font size='2'><b>",Name,"</b></font><br/><font size='1' color='#E95420'>Click to
                       get additional info</font>") %>% lapply(htmltools::HTML),
      group = "Network",
      layerId = ~Name
      #clusterOptions = markerClusterOptions(freezeAtZoom = T) 
    ) |> # pentru zoom limite retea incarcata
    fitBounds(bbox[1], bbox[2], bbox[3], bbox[4]) 
})

# network description -----------------------------------------------------
meta_desc <- reactiveValues(description = NULL)

observeEvent(input$map_metadata_marker_click$id,{
  df <- metadata_sel()$admin_spat
  meta_desc$description <- 
    df[df$Name == input$map_metadata_marker_click$id,] |> 
    as.data.frame() |>
    select(Name, Locality, County, geometry) |>
    rename(Coordinates = geometry) |>
    knitr::kable("html") |>
    kableExtra::kable_styling()
})

#observe iar pentru resetare valori metadata in functie de retea
observeEvent(input$network,{
  meta_desc$description <- NULL
})

output$net_desc_markdown <- renderUI({
  if(!is.null(meta_desc$description)) {
    HTML(
      net_des$description[net_des$network == input$network],
      "<br/>", "<br/>",
      meta_desc$description
    ) 
  } else {
    HTML(
      net_des$description[net_des$network == input$network]
    ) 
  }
  
  
})



