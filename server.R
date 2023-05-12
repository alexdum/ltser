

server <- function(input, output) {
  
  # harta leaflet -----------------------------------------------------------
  output$map_ltser <- renderLeaflet ({
      
      leaflet(
        data = ltser,
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
          overlayGroups = c("Labels", "LTSER"))  %>% 
        addProviderTiles(
          "CartoDB.PositronOnlyLabels",
          options = pathOptions(pane = "maplabels"),
          group = "Labels"
        ) %>%
        addScaleBar(
          position = c("bottomleft"),
          options = scaleBarOptions(metric = TRUE)
        ) |>
        addPolygons(
          label = ~htmlEscape(name),
          group = "LTSER",
          fillColor = "#99d8c9",
          color = "#2ca25f",
          #fillColor = ~pal(values),
          #color = ~pal(values),
          fillOpacity = isolate(input$transp_ind),
          layerId = ~natcode,
          weight = 1
        )
    })
  
  # zoom on polygon
  observe({
    
  
    proxy <- leafletProxy("map_ltser") |>
      clearShapes() |>
      addPolygons(
        data = ltser,
        label = ~htmlEscape(name),
        group = "LTSER",
        fillColor = "#99d8c9",
        color = "#2ca25f",
        #fillColor = ~pal(values),
        #color = ~pal(values),
        fillOpacity = input$transp_ind,
        layerId = ~natcode,
        weight = 1
      )
    
    click <- input$map_ltser_shape_click
    print(click)
    if(is.null(click))
      return()
    proxy %>% setView(lng = click$lng, lat = click$lat, zoom = 8)
    
    
  })
  
  
  
  
  output$dists <- renderPlot({
    ggplot(
      ChickWeight,
      aes(x = weight)
    ) +
      facet_wrap(input$distFacet) +
      geom_density(fill = "#fa551b", color = "#ee6331") +
      ggtitle("Distribution of weights by diet")
  })
  
}
