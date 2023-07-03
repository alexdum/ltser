# functie harta
leaflet_fun_in <- function(data) {
  
  map <- leaflet(
    #data = data,
    options = leafletOptions(
      minZoom = 6, maxZoom = 12
    ) 
  ) %>%
    leaflet.extras::addBootstrapDependency() %>%
    #setView(25, 46, zoom = 6) |>
    setMaxBounds(20, 43.5, 30, 48.2) |>
    addMapPane(name = "pol", zIndex = 410) %>%
    addMapPane(name = "maplabels", zIndex = 420) %>%
    addProviderTiles( "CartoDB.PositronNoLabels")   %>% 
    addEasyButton(
      easyButton (
        icon    = "glyphicon glyphicon-home", title = "Reset zoom",
        onClick = JS("function(btn, map){ map.setView([46, 25], 3); }")
      )
    ) %>%
    addLayersControl(
      baseGroups = "CartoDB.PositronNoLabels",
      overlayGroups = c("Labels", "Network"))  %>% 
    addProviderTiles(
      "CartoDB.PositronOnlyLabels",
      options = pathOptions(pane = "maplabels"),
      group = "Labels"
    ) |>
    addMarkers(
      data = data,
      label = ~Name,
      group = "Network"#
      #clusterOptions = markerClusterOptions(freezeAtZoom = T) 
      )
  # clearControls() |>
  # addLegend(
  #   title = tit_leg,
  #   "bottomleft", pal = pal_rev, values = ~value, opacity = 1,
  #   labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE))
  # ) 
  return(map)
}