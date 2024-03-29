data_ec <- reactive({
  
  # pentru situatiile cand nu schimbi data, bug in airdatapicker
  req(input$datetime_ec, cancelOutput = T)

  
  # selectie unitate
  admin_spat <- ec
  data_sub <- # select dataset
    switch(
      input$temp_res_ec,
      halfhourly = hhourly_ec,
      daily = daily_ec
    )
  
  data_sel <- 
    data_sub |> 
    filter(
      variable == input$parameter_ec,
      time_eet %in% input$datetime_ec,
      !is.na(values)
    ) |> collect()
  
  # join cu datele spatiale
  admin_spat <- admin_spat |> mutate(Name = tolower(Name)) |> inner_join(data_sel, by = c("Name" = "id"))
  
  unit <- ec_halfhourly$unit[ec_halfhourly$choice ==  input$parameter_ec]
  
  if (nrow(admin_spat) > 1 ) {
    map_leg <- mapa_fun_cols_ec(
      indic = input$parameter_ec, domain = range(admin_spat$values), 
      title = unit,
      nbins = nrow(admin_spat)
    )
    
    
    
    
    list(
      admin_spat = admin_spat, data_sel = data_sel, pal = map_leg$pal, pal_rev = map_leg$pal_rev, 
      tit_leg = map_leg$tit_leg, unit = unit, time = input$datetime_ec
    )
  }
})

# harta leaflet -----------------------------------------------------------
output$map_ec <- renderLeaflet({
  
  leaflet_fun_data(
    data = isolate(data_ec()$admin_spat),
    pal =  isolate(data_ec()$pal),
    pal_rev =  isolate(data_ec()$pal_rev),
    tit_leg = isolate(data_ec()$tit_leg)
  )
})

observe({
  
  pal_rev =  data_ec()$pal_rev
  tit_leg = data_ec()$tit_leg
  data <- data_ec()$admin_spat_sub
  pal <- data_ec()$pal
  data <- data_ec()$admin_spat
  # pentru zoom retea observatii vizualizata
  bbox <- st_bbox(data) |> as.vector()
  leafletProxy("map_ec", data = data) |>
    mapOptions(zoomToLimits = "first") |>
    clearMarkers() |>
    addCircleMarkers(
      stroke = FALSE,
      radius = 12, weight = 10,
      color = ~pal(values), fillOpacity = 1,
      label = ~paste("<font size='2'><b>",Name, values,"</b></font><br/><font size='1' color='#E95420'>Click to
      #                  get data</font>") %>% lapply(htmltools::HTML),
      group = "Network",
      layerId = ~Name
      #clusterOptions = markerClusterOptions(freezeAtZoom = T) 
    ) |>
    #clearMarkers() |>
    addLabelOnlyMarkers(
      label = ~values,
      labelOptions = labelOptions(
        noHide = TRUE, textOnly = TRUE,
        direction = "center", offset = c(0,0), sticky = T,
        fontsize = 14
      )
    ) |> # pentru zoom limite retea incarcata
    #fitBounds(bbox[1], bbox[2], bbox[3], bbox[4]) |>
    clearControls() |>
    addLegend(
      title = tit_leg,
      "bottomleft", pal = pal_rev, values = ~values, opacity = 1,
      labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE))
    ) 
})


# reactive values pentru plot meteo
values_plot_ec <- reactiveValues(
  id = NA, data = NA
)
# valoare de pronire 
observeEvent(list(isolate(input$tab_metadata),input$network_data),{
  values_plot_ec$id <- unique(data_ec()$admin_spat$Name)[1] 
  values_plot_ec$param <- "ss" 
})

# update plot by click
observeEvent(input$map_ec_marker_click$id,{ 
  values_plot_ec$id  <- input$map_ec_marker_click$id 
})


output$ec_plot <- renderHighchart({
  
  
  name <- ec$Name[tolower(ec$Name) %in% values_plot_ec$id]
  locality <- ec$Locality[tolower(ec$Name) %in% values_plot_ec$id]
  county <- ec$County[tolower(ec$Name) %in% values_plot_ec$id]
  
  
  time_threshold <-  (3600 * 24 * 7)
  time_sub1 <- data_ec()$time - time_threshold
  
  
  ec_subset <- 
    hhourly_ec |>
    filter(
      time_eet > time_sub1  &  time_eet <= data_ec()$time ,
      variable %in% input$parameter_ec,
      id %in% values_plot_ec$id) |>
    collect() 
  
  values_plot_meteo$data <-  ec_subset
  
  graph_ec(ec_subset,  title = paste0(name, " (", locality, county,")"), filename_save = paste0(name,"_",input$parameter_ec, ".png"), y1lab  = data_ec()$unit)
})

output$ec_table <-  DT::renderDT({
  

  values_plot_meteo$data |>
    DT::datatable(
      extensions = 'Buttons', rownames = F,
      options = list(
        dom = 'Bfrtip',digits = 1,
        pageLength = 5, autoWidth = TRUE,
        buttons = c('pageLength','copy', 'csv', 'excel'),
        pagelength = 10, lengthMenu = list(c(10, 25, 100, -1), c('10', '25', '100','All')
        )
        
      )
    )
  
})

# outout imagine ec
output$photo_ec <- renderImage({
  
  width  <- session$clientData$output_photo_ec_width # take width from the client
  #height <- session$clientData$output_photo_ec_height
  
  img_path <- # creeaza calea catre imagine
    paste0(
      "www/data/img/ec/", values_plot_ec$id, "/", format(data_ec()$time, "%Y/%m/%d"),
      "/", values_plot_ec$id,"_", format(input$datetime_ec, "%Y-%m-%d-%H%M.jpg")
    )
  # daca nu este imagine disponibila
  if (!file.exists(img_path)) img_path <- "www/data/img/ec/no_image_available.png"
  
  #Return a list containing the filename and alt text
  list(
    src = img_path,
    alt = paste(toupper(values_plot_ec$id), format(data_ec()$time, "%Y-%m-%d-%H%M")),
    width = width
  )
  
}, deleteFile = FALSE)

