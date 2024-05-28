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
meta_desc <- reactiveValues(description = NULL, img_path = NULL)

observeEvent(input$map_metadata_marker_click$id,{
  df <- metadata_sel()$admin_spat
  df <- meta_desc$description <- 
    df[df$Name == input$map_metadata_marker_click$id,] |> 
    as.data.frame() |>
    select(Name, Locality, County, Parameters, geometry) |>
    rename(Coordinates = geometry, `Parameters measured` = Parameters) |>
    knitr::kable("html") |>
    kableExtra::kable_styling()
  
  meta_desc$img_path <-  input$map_metadata_marker_click$id
  
})

#observe iar pentru resetare valori metadata in functie de retea
observeEvent(input$network,{
  meta_desc$description <- NULL
  meta_desc$img_path <- NULL
})

output$net_desc_markdown <- renderUI({
  #if (!is.null(meta_desc$description)) {
  HTML(
    net_des$description[net_des$network == input$network],
  ) 
})
output$net_detail <- renderUI({
  #if (!is.null(meta_desc$description)) {
  HTML(
    meta_desc$description
  ) 
})


# outout imagine meta
output$photo_meta <- renderImage({
  
  width  <- session$clientData$output_photo_meta_width # take width from the client
  #height <- session$clientData$output_photo_ec_height
  
  img_path <- paste0("www/data/img/meta/", input$network,"/", meta_desc$img_path ,".png")

  # daca nu este imagine disponibila
  if (!file.exists(img_path)) img_path <- "www/data/img/ec/no_image_available.png"
  
  #Return a list containing the filename and alt text
  list(
    src = img_path#,
    #width = width
  )
  
}, deleteFile = FALSE)


# afisare detalii cand ai click pe simbol
output$meta_detail <- renderUI({
  req(meta_desc$description)
  
  layout_columns(
    card(
      full_screen = T,
      fill = T,
      uiOutput("net_detail")
    ),
    card( 
      full_screen = T,
      fill = T,
      imageOutput("photo_meta")
    )
  )
})



