
nation_sel<- reactive ({
  
 
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
  
  leaflet_fun_na(
    ltser,
    isolate(nation_sel()$rs), 
    domain =  isolate(nation_sel()$domain),
    cols = isolate(nation_sel()$pal), 
    cols_rev = isolate(nation_sel()$pal_rev),
    title = isolate(nation_sel()$tit_leg)
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
  rs <- nation_sel()$rs
  leafletProxy("map_ltser") %>%
    clearImages() %>%
    addRasterImage(
      rs, 
      colors = nation_sel()$pal,  
      opacity = .8 ) %>%
    clearControls() %>%
    leaflet::addLegend(
      title = nation_sel()$tit_leg,
      position = "bottomleft",
      pal = nation_sel()$pal_rev, values = nation_sel()$domain,
      opacity = 1,
      labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE))
    )
})

# reactive values pentru plot lst time series din raster
values_plot_na <- reactiveValues(input = NULL, title = NULL, cors = NULL)

observe({
  var <- nation_sel()$indicator
  lon = 25
  lat = 46
  dd <- extract_point(fname =  paste0("www/data/ncs/",  var, "_ltser_mon.nc"), lon  = lon, lat = lat, variable = var) 
  ddf <- data.frame(date = as.Date(names(dd)), value = round(dd, 1)) %>% slice(1:nation_sel()$index)
  values_plot_na$input <- ddf
  values_plot_na$title <- paste0("Extracted value ",toupper(var)," values for point lon = ",round(lon, 5)," lat = "  , round(lat, 5))
})

# interactivitate raster
observe({
  proxy <- leafletProxy("map_ltser")
  click <- input$map_ltser_click
  rs <- nation_sel()$rs
  var <- nation_sel()$indicator
  fil.nc <- paste0("www/data/ncs/", var, "_ltser_mon.nc")
  
  if (input$radio_mon == 1 & !is.null(click)) {
    show_pop(var = var,x = click$lng, y = click$lat, rdat = rs, proxy = proxy)
  } else {
   
    proxy %>% clearPopups()
    if (!is.null(click)) {
      cell <- terra::cellFromXY(rs, cbind(click$lng, click$lat))
      xy <- terra::xyFromCell(rs, cell)
      dd <- extract_point(fname = fil.nc , lon = xy[1], lat = xy[2], variable = var) 
      # pentru afisare conditional panel si titlu grafic coordonates
      condpan_monthly.txt <- ifelse(
        is.na(mean(dd, na.rm = T)) | is.na(cell), 
        "You must click on an area with indicator values available", 
        paste0("Extracted value ",toupper(var)," values for point lon = ",round(click$lng, 5)," lat = "  , round(click$lat, 5))
      )
      output$condpan_monthly <- renderText({
        condpan_monthly.txt 
      })
      outputOptions(output, "condpan_monthly", suspendWhenHidden = FALSE)
      ddf <- data.frame(date = as.Date(names(dd)), value = round(dd, 1)) %>% slice(1:nation_sel()$index)
      # valori pentru plot la reactive values
      values_plot_na$title <- condpan_monthly.txt
      values_plot_na$input <- ddf
      values_plot_na$cors <- paste0(round(click$lng, 5), "_", round(click$lat, 5))
      
    }
  }
  
})

# plot actualizat daca schimb si coordonatee
output$na_plot <- renderHighchart({
  req(values_plot_na$input)
  indicator <- nation_sel()$indicator
  
  ytitle <- ifelse(indicator %in% c("ssm"),"%")

  hc_plot(
    input =  values_plot_na$input , xaxis_series = c("value"), filename_save = indicator,
    cols = c("green"), names = toupper(indicator), ytitle =   ytitle,
    title =   values_plot_na$title
  )
})



