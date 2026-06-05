data_sel <- reactive({

  # pentru situatiile cand nu schimbi data, bug in airdatapicker
  if (input$temporal_resolution == "hourly") {
    req(input$datetime_meteo)
  } else {
    req(input$date_meteo)
  }
  
  print(paste("data_sel reactive running. Resolution:", input$temporal_resolution))
  print(paste("datetime_meteo:", input$datetime_meteo))
  print(paste("date_meteo:", input$date_meteo))
  
  # selectie unitate
  admin_spat <- ws
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
  req(timesel_sub)
  print(paste("timesel_sub (raw):", timesel_sub))
  timesel_sub <- as.POSIXct(timesel_sub, tz = "UTC")
  print(paste("timesel_sub (POSIXct):", timesel_sub))
  
  data_sel <- 
    data_sub |> 
    filter(
      variable == param_sub,
      time %in% timesel_sub,
      !is.na(values)
    ) |> collect()
  print(paste("data_sel row count:", nrow(data_sel)))
  #mutare statii
  data_sel$id[data_sel$id == "IF-Ste"] <- "IL-Lil"
  data_sel$id[data_sel$id == "IF-Cor"] <- "GR-Mih"
  
  
  # join cu datele spatiale
  admin_spat <- admin_spat |> inner_join(data_sel, by = c("Name" = "id"))
  
  
  val_range <- if (nrow(admin_spat) > 0) range(admin_spat$values, na.rm = TRUE) else c(0, 100)
  map_leg <- mapa_fun_cols(indic = param_sub, domain = val_range)
  
  # limitare minmax cu valorile din map_fun_cols.R
  admin_spat <-
    admin_spat |> 
    mutate(
      values = ifelse(values <  map_leg$minmax[1], map_leg$minmax[1], values),
      values = ifelse(values >  map_leg$minmax[2], map_leg$minmax[2], values),
    )
  
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
  req(data_sel())
  pal_rev =  data_sel()$pal_rev
  tit_leg = data_sel()$tit_leg
  pal <- data_sel()$pal
  data <- data_sel()$admin_spat
  req(data, nrow(data) > 0)
  # pentru zoom retea observatii vizualizata
  bbox <- st_bbox(data) |> as.vector()
  leafletProxy("map_data", data = data) |>
    mapOptions(zoomToLimits = "first") |>
    clearMarkers() |>
    addCircleMarkers(
      stroke = FALSE,
      radius = 12, weight = 10,
      color = ~pal(values), fillOpacity = 1,
      label = ~paste("<font size='2'><b>",Name, values,"</b></font><br/><font size='1' color='#E95420'>Click to get data</font>") %>% lapply(htmltools::HTML),
      group = "Network",
      layerId = ~Name,
      options = pathOptions(pane = "network")
    ) |>
    #clearMarkers() |>
    addLabelOnlyMarkers(
      label = ~values,
      layerId = ~paste0("label_", Name),
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
values_plot_meteo <- reactiveValues(
  id = NA, data = NA
)
# valoare de pronire 
observe({
  req(data_sel())
  names_spat <- unique(data_sel()$admin_spat$Name)
  req(length(names_spat) > 0)
  if (is.na(values_plot_meteo$id) || !(values_plot_meteo$id %in% names_spat)) {
    values_plot_meteo$id <- names_spat[1]
  }
})

# update plot by click
observeEvent(input$map_data_marker_click$id,{ 
  values_plot_meteo$id <- input$map_data_marker_click$id 
  
})





output$meteo_plot <- renderHighchart({
   
  # # update only both parameters are changed
  # req(subset_param(input$parameter_meteo)[1] != values_plot_meteo$param[1],   cancelOutput = T) 
  # req(input$map_data_marker_click$id)
  # values_plot_meteo$param <-  subset_param(input$parameter_meteo)
  # #values_plot_meteo$id <- input$map_data_marker_click$id
  
  time_threshold <- # pentru subset date ploturi/ descarcare
    switch(
      input$temporal_resolution,
      hourly = 3600 * 24 * 7,
      daily = 3600 * 24 * 31
    )
  
  time_limit <- data_sel()$timesel_sub
  timesel_sub2 <- time_limit - time_threshold
  
  # selectie perechi parametri
  subset_param_meteo <- subset_param(input$parameter_meteo)
  
  print(paste("meteo_plot: id =", values_plot_meteo$id))
  print(paste("meteo_plot: time_limit =", time_limit))
  print(paste("meteo_plot: timesel_sub2 =", timesel_sub2))
  print(paste("meteo_plot: subset_param_meteo =", paste(subset_param_meteo, collapse = ", ")))
  
  # table pentru ploturi/descarcare date
  data_sel_tempo <-
    data_sel()$data_sub |>
    mutate( # mutare statii
      id = ifelse(id %in% "IF-Ste", "IL-Lil", id),
      id = ifelse(id %in% "IF-Cor", "GR-Mih", id)
    ) |>
    filter(
      time >= timesel_sub2 & time <= time_limit,
      substr(variable,1,2) %in%  subset_param_meteo,
      id %in% values_plot_meteo$id
    ) 
  
  # pentru vizualiare data table - urmatoare sectiune
  values_plot_meteo$data <- data_sel_tempo
  
  data1 <- 
    data_sel_tempo |>
    filter(substr(variable,1,2) %in% subset_param_meteo[1]) |> 
    arrange(time) |>
    collect() 
  
  data2 <- 
    data_sel_tempo  |>
    filter(substr(variable,1,2) %in% subset_param_meteo[2]) |>
    arrange(time) |>
    collect() 
  
  print(paste("meteo_plot: data1 row count =", nrow(data1)))
  print(paste("meteo_plot: data2 row count =", nrow(data2)))
  
  # transforma timpii in milisecunde (Highcharts stock necesita ms)
  if (input$temporal_resolution == "hourly") {
    data1$time <- as.numeric(data1$time) * 1000
    data2$time <- as.numeric(data2$time) * 1000
  } else {
    # daily: Date -> POSIXct -> numeric seconds -> milliseconds
    data1$time <- as.numeric(as.POSIXct(data1$time, tz = "UTC")) * 1000
    data2$time <- as.numeric(as.POSIXct(data2$time, tz = "UTC")) * 1000
  }
  
  loc <- ws_df$Locality[ws_df$Name == values_plot_meteo$id]
  cou <- ws_df$County[ws_df$Name == values_plot_meteo$id]
  loc <- if (length(loc) > 0) loc else "Unknown"
  cou <- if (length(cou) > 0) cou else "Unknown"
  id_val <- if (!is.null(values_plot_meteo$id)) values_plot_meteo$id else "No Station"
  tit_plot <- paste0(id_val, " (", loc, ", ", cou, ")")
  graph_meteo(data1, data2, title = tit_plot, filename_save = "plot.png", param = input$parameter_meteo)
  

})


output$metoe_table <-  DT::renderDT({
  
  values_plot_meteo$data |>
    collect() |>
    tidyr::pivot_wider(names_from = variable, values_from = values) |>
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

# Update datepicker default value based on selected parameter and resolution
observeEvent(list(input$parameter_meteo, input$temporal_resolution), {
  data_sub <- switch(
    input$temporal_resolution,
    hourly = hourly,
    daily = daily
  )
  param_sub <- switch(
    input$temporal_resolution,
    hourly = input$parameter_meteo,
    daily = gsub("01h", "24h", input$parameter_meteo)
  )
  
  # Fetch the last time where at least 2 stations have data for this parameter
  last_time_df <- data_sub |>
    filter(variable == param_sub, !is.na(values), !is.na(time)) |>
    group_by(time) |>
    summarize(n_st = n()) |>
    filter(n_st >= 2) |>
    arrange(desc(time)) |>
    head(1) |>
    collect()
  
  # Use full date range from global data, explicitly reset min/max to override any previous constraints
  if (input$temporal_resolution == "hourly") {
    val_t <- if (nrow(last_time_df) > 0) as.character(last_time_df$time[1]) else as.character(max(hourly_dats$time))
    print(paste("updateAirDateInput: val_t =", val_t, "resolution = hourly"))
    shinyWidgets::updateAirDateInput(
      session, "datetime_meteo",
      value = val_t,
      options = list(
        minDate = as.character(min(hourly_dats$time)),
        maxDate = as.character(max(hourly_dats$time))
      )
    )
  } else {
    val_t <- if (nrow(last_time_df) > 0) as.character(last_time_df$time[1]) else as.character(max(daily_dats$time))
    print(paste("updateAirDateInput: val_t =", val_t, "resolution = daily"))
    shinyWidgets::updateAirDateInput(
      session, "date_meteo",
      value = val_t,
      options = list(
        minDate = as.character(min(daily_dats$time)),
        maxDate = as.character(max(daily_dats$time))
      )
    )
  }
})


