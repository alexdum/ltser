# functie harta
leaflet_fun_data <- function(data,  pal, pal_rev, tit_leg) {
  
  map <- leaflet(
    data = data,
    options = leafletOptions(
      minZoom = 6, maxZoom = 18
    ) 
  ) %>%
    leaflet.extras::addBootstrapDependency() %>%
    #setView(25, 46, zoom = 6) |>
    setMaxBounds(20, 43.5, 30, 48.2) |>
    addMapPane(name = "ltser", zIndex = 410) %>%
    addMapPane(name = "network", zIndex = 415) %>%
    addMapPane(name = "maplabels", zIndex = 420) %>%
    # Base groups
    addProviderTiles( "CartoDB.PositronNoLabels", group = "CartoDB") |> 
    addProviderTiles("Esri.WorldImagery", group = "Esri Imagery") |> 
    addEasyButton(
      easyButton(
        icon    = "glyphicon glyphicon-home", title = "Reset zoom",
        onClick = JS("function(btn, map){ map.setView([46, 25], 3); }")
      )
    ) %>%
    addLayersControl(
      baseGroups = c("CartoDB", "Esri Imagery"),
      overlayGroups = c("Labels", "Network", "LTSER"))  %>% 
    addProviderTiles(
      "CartoDB.PositronOnlyLabels",
      options = pathOptions(pane = "maplabels"),
      group = "Labels"
    ) |>
    clearShapes() |>
    addCircleMarkers(
      stroke = FALSE,
      radius = 12, weight = 10,
      color = ~pal(values), fillOpacity = 1,
      label = ~paste("<font size='2'><b>",Name, values,"</b></font><br/><font size='1' color='#E95420'>Click to
      #                  get data</font>") %>% lapply(htmltools::HTML),
      group = "Network",
      layerId = ~Name,
      options = pathOptions(pane = "network")
      #clusterOptions = markerClusterOptions(freezeAtZoom = T) 
    ) |>
    addLabelOnlyMarkers(
      label = ~as.character(values),
      labelOptions = labelOptions(
        noHide = TRUE, textOnly = TRUE,
        direction = "center", offset = c(0,0), sticky = T,
        fontsize = 14
      )
    ) |>
    addPolygons(
      data = ltser,
      label = ~htmlEscape(name),
      group = "LTSER",
      fillColor = "#99d8c9",
      color = "#003c30",
      #fillColor = ~pal(values),
      #color = ~pal(values),
      fillOpacity = 0.8,
      layerId = ~natcode,
      weight = 1,
      options = pathOptions(pane = "ltser")
    ) |>
    # nu vizualiza bufere
    hideGroup(c("LTSER")) |>
    clearControls() |>
    
    addLegend(
      title = tit_leg,
      "bottomleft", pal = pal_rev, values = ~values, opacity = 1,
      labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE))
    ) 
  
  # clearControls() |>
  # addLegend(
  #   title = tit_leg,
  #   "bottomleft", pal = pal_rev, values = ~value, opacity = 1,
  #   labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE))
  # ) 
  return(map)
}