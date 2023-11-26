data_ec <- reactive({
  
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
  
  map_leg <- mapa_fun_cols_ec(
    indic = input$parameter_ec, domain = range(admin_spat$values), 
    title = ec_halfhourly$unit[ec_halfhourly$choice ==  input$parameter_ec],
    nbins = nrow(admin_spat)
  )
  
  list(
    admin_spat = admin_spat, data_sel = data_sel, pal = map_leg$pal, pal_rev = map_leg$pal_rev, 
    tit_leg = map_leg$tit_leg
  )
  
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


observe({
  print(nrow(data_ec()$admin_spat))
  print(data_ec()$data_sel)
  
})