# functie harta
leaflet_fun_ad <- function(data, pal, pal_rev, tit_leg, indicator = NA) {
  
  if (indicator %in% c("pop108d","pop309e")) {
    label_legend <- labelFormat(transform = function(x) sort(x, decreasing = TRUE), digits = 0)
  } else {
    label_legend <- labelFormat(transform = function(x) sort(x, decreasing = TRUE))
  }
  
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
      overlayGroups = c("Labels", "Unit", "Weather stations", "Eddy covariance",  "CUV5 Total UV Radiometer", "RaZON+", "Cosmic Ray Neutron","Buoy"))  %>% 
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
      label = ~paste("<font size='2'><b>",name,
                     "<br/>",round(value,1),"</b></font><br/><font size='1' color='#E95420'>Click to
                       get values and graph</font>") %>% lapply(htmltools::HTML),
      group = "Unit",
      fillColor = ~pal(value), 
      #fillColor = ~pal(values),
      #color = ~pal(values),
      fillOpacity = 0.8,
      color = "grey",
      weight = 0.5, smoothFactor = 0.1,
      opacity = 0.5,
      layerId = ~natcode,
      highlightOptions = highlightOptions(
        weight = 2,
        color = "#666",
        fillOpacity = 0.2,
        bringToFront = TRUE,
        sendToBack = TRUE)
    )  |>
    addMarkers(
      data = ws,
      label = ~paste("<font size='2'><b>",Name,"</b></font><br/><font size='1'>") %>% lapply(htmltools::HTML),
      layerId = ~Name,
      group = "Weather stations" 
    ) |>
    addMarkers(
      data = ec,
      label = ~paste("<font size='2'><b>",Name,"</b></font><br/><font size='1'>") %>% lapply(htmltools::HTML),
      layerId = ~Name,
      group = "Eddy covariance" 
    ) |> addMarkers(
      data = cu,
      label = ~paste("<font size='2'><b>",Name,"</b></font><br/><font size='1'>") %>% lapply(htmltools::HTML),
      layerId = ~Name,
      group = "CUV5 Total UV Radiometer" 
    ) |> addMarkers(
      data = ra,
      label = ~paste("<font size='2'><b>",Name,"</b></font><br/><font size='1'>") %>% lapply(htmltools::HTML),
      layerId = ~Name,
      group = "RaZON+" 
    ) |> addMarkers(
      data = co,
      label = ~paste("<font size='2'><b>",Name,"</b></font><br/><font size='1'>") %>% lapply(htmltools::HTML),
      layerId = ~Name,
      group = "Cosmic Ray Neutron" 
    ) |> addMarkers(
      data = bu,
      label = ~paste("<font size='2'><b>",Name,"</b></font><br/><font size='1'>") %>% lapply(htmltools::HTML),
      layerId = ~Name,
      group = "Buoy" 
    ) |>
    hideGroup(c("Weather stations","Weather stations", "Eddy covariance",  "CUV5 Total UV Radiometer", "RaZON+", "Cosmic Ray Neutron","Buoy")) |> # nu vizualiza bufere
    
    clearControls() |>
    addLegend(
      title = tit_leg,
      "bottomleft", pal = pal_rev, values = ~value, opacity = 1,
      labFormat = label_legend
    ) 
  return(map)
}