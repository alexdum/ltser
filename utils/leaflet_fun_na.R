# functie harta
leaflet_fun_na <- function(data, raster, domain, cols, cols_rev, title) {
  
  
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
    addProviderTiles( "CartoDB.PositronNoLabels", group = "CartoDB")   %>% 
    addProviderTiles("Esri.WorldImagery", group = "Esri Imagery") |> 
    addEasyButton(
      easyButton (
        icon    = "glyphicon glyphicon-home", title = "Reset zoom",
        onClick = JS("function(btn, map){ map.setView([46, 25], 3); }")
      )
    ) %>%
    addLayersControl(
      baseGroups = c("CartoDB", "Esri Imagery"),
      overlayGroups = c("Labels", "LTSER", "Weather stations", "Eddy covariance",  "CUV5 Total UV Radiometer", "RaZON+", "Cosmic Ray Neutron","Buoy"))  %>% 
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
      group = "LTSER",
      fillColor = "#99d8c9",
      color = "#003c30",
      #fillColor = ~pal(values),
      #color = ~pal(values),
      fillOpacity = 0.8,
      layerId = ~natcode,
      weight = 1
    ) |>
    addRasterImage(
      raster, colors = cols, opacity = .8
      # options = leafletOptions(pane = "raster")
    )  |>
    # pentru poztionare raster mereu in top
    htmlwidgets::onRender(" 
    function(el, x) {
      this.on('baselayerchange', function(e) {
        e.layer.bringToBack();
      })
    }
  ") |>
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
    clearControls() %>%
    addLegend(
      title = title,
      position = "bottomleft",
      pal =  cols_rev, values = domain,
      opacity = 1,
      labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE))
    )
  return(map)
}