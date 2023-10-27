# functie harta
leaflet_fun_meta <- function(data) {
  
  map <- leaflet(
    #data = data,
    options = leafletOptions(
      minZoom = 6, maxZoom = 18
    ) 
  ) %>%
    leaflet.extras::addBootstrapDependency() %>%
    #setView(25, 46, zoom = 6) |>
    setMaxBounds(20, 43.5, 30, 48.2) |>
    addMapPane(name = "pol", zIndex = 410) %>%
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
      overlayGroups = c("Labels", "Network"))  %>% 
    addProviderTiles(
      "CartoDB.PositronOnlyLabels",
      options = pathOptions(pane = "maplabels"),
      group = "Labels"
    ) |>
    addMarkers(
      data = data,
      label = ~paste("<font size='2'><b>",Name,"</b></font><br/><font size='1' color='#E95420'>Click to
                       get additional info</font>") %>% lapply(htmltools::HTML),
      group = "Network",
      layerId = ~Name
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