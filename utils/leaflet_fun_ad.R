# functie harta
leaflet_fun_ad <- function(data) {
  
  map <- leaflet(
    data = data,
    options = leafletOptions(
      minZoom = 6, maxZoom = 12
    ) 
  ) %>%
    leaflet.extras::addBootstrapDependency() %>%
    setView(25, 46, zoom = 6) |>
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
      overlayGroups = c("Labels", "NUT"))  %>% 
    addProviderTiles(
      "CartoDB.PositronOnlyLabels",
      options = pathOptions(pane = "maplabels"),
      group = "Labels"
    ) %>%
    addScaleBar(
      position = c("bottomright"),
      options = scaleBarOptions(metric = TRUE)
    ) |>
    addPolygons(
      label = ~htmlEscape(name),
      group = "NUT",
      fillColor = "#99d8c9",
      color = "#003c30",
      #fillColor = ~pal(values),
      #color = ~pal(values),
      fillOpacity = 0.8,
      layerId = ~natcode,
      weight = 1
    ) #|>
    # addPolygons(
    #   data = ltser,
    #   stroke = FALSE, fillOpacity = 0.2, smoothFactor = 0.5,
    #   color = ~colorQuantile("YlOrRd", ltser$id)(),
    #   group = "LTSER limits",
    #   options = pathOptions(clickable = FALSE)
    )#|>
  # addRasterImage(
  #   raster, colors = cols, opacity = .8
  #   # options = leafletOptions(pane = "raster")
  # )  |>
  # clearControls() %>%
  # addLegend(
  #   title = title,
  #   position = "bottomleft",
  #   pal =  cols_rev, values = domain,
  #   opacity = 1,
  #   labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE))
  # )
  return(map)
}