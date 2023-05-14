
reac_rs_mon <- reactive ({
  
  index <- which(format(dats.ssm, "%Y %b") %in% input$month_indicator)
  indicator <- input$parameter_monthly
  # indicator <- "mm" 
  
  switch (
    which(c("ssm") %in% input$parameter_monthly),
    rs <- ssm
  )
  
  rs <- terra::setMinMax(rs[[index]])
  domain <- terra::minmax(rs)
  map_leg <- mapa_fun_cols(indic = indicator, domain)
  
  
  list(rs = rs, index = index, domain = domain, pal =  map_leg$pal, pal_rev =  map_leg$pal_rev,  
       tit_leg  =   map_leg$tit_leg,  indicator= indicator)
})
  
  # harta leaflet -----------------------------------------------------------
  output$map_ltser <- renderLeaflet ({
      
    leaflet_fun(
      ltser,
      isolate(reac_rs_mon()$rs), 
      domain =  isolate(reac_rs_mon()$domain),
      cols = isolate(reac_rs_mon()$pal), 
      cols_rev = isolate(reac_rs_mon()$pal_rev),
      title = isolate(reac_rs_mon()$tit_leg)
    )
    
    })
  
  # opacitate polygon
  observe({

    proxy <- leafletProxy("map_ltser") |>
      clearShapes() |>
      addPolygons(
        data = ltser,
        label = ~htmlEscape(name),
        group = "LTSER",
        fillColor = "#99d8c9",
        color = "#003c30",
        #fillColor = ~pal(values),
        #color = ~pal(values),
        fillOpacity = input$transp_ind,
        layerId = ~natcode,
        weight = 1
      )
    
    # click <- input$map_ltser_shape_click
    # print(click)
    # if(is.null(click))
    #   return()
    # proxy %>% setView(lng = click$lng, lat = click$lat, zoom = 8)
    
    
  })
  
  # navigare raster
  observe({
    rs <- reac_rs_mon()$rs
    leafletProxy("map_ltser") %>%
      clearImages() %>%
      addRasterImage(
        rs, 
        colors = reac_rs_mon()$pal,  
        opacity = .8 ) %>%
      clearControls() %>%
      leaflet::addLegend(
        title = reac_rs_mon()$tit_leg,
        position = "bottomright",
        pal = reac_rs_mon()$pal_rev, values = reac_rs_mon()$domain,
        opacity = 1,
        labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE))
      )
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
  

