
# reac_rs_mon <- reactive ({
#   
#  
#   index <- which(format(dats.ssm, "%Y %b") %in% input$month_indicator)
#   indicator <- input$parameter_monthly
#   # indicator <- "mm" 
#   
#   switch (
#     which(c("ssm") %in% input$parameter_monthly),
#     rs <- ssm
#   )
#   
#   rs <- terra::setMinMax(rs[[index]])
#   domain <- terra::minmax(rs)
#   map_leg <- mapa_fun_cols(indic = indicator, domain)
#   
#   
#   list(rs = rs, index = index, domain = domain, pal =  map_leg$pal, pal_rev =  map_leg$pal_rev,  
#        tit_leg  =   map_leg$tit_leg,  indicator= indicator)
# })

admin_sel <- reactive({
  
  # selectie unitate
  switch( # alege nume indicator care să fie afișat
    which(c("ltser", "nut") %in%  input$admin_unit),
    admin_spat <- ltser,
    admin_spat <- ltser_uat
  )
  list(admin_spat = admin_spat)
})

# harta leaflet -----------------------------------------------------------
output$map_ltser_ad <- renderLeaflet ({
  
  leaflet_fun_ad(
    isolate(admin_sel()$admin_spat)
    # isolate(reac_rs_mon()$rs), 
    # domain =  isolate(reac_rs_mon()$domain),
    # cols = isolate(reac_rs_mon()$pal), 
    # cols_rev = isolate(reac_rs_mon()$pal_rev),
    # title = isolate(reac_rs_mon()$tit_leg)
  )
  
})

# opacitate polygon
observe({

  proxy <- leafletProxy("map_ltser_ad") |>
    clearShapes() |>
    addPolygons(
      data =  admin_sel()$admin_spat,
      label = ~(name),
      group = "LTSER",
      fillColor = "#99d8c9",
      color = "#003c30",
      #fillColor = ~pal(values),
      #color = ~pal(values),
      fillOpacity = input$transp_ind_ad,
      layerId = ~natcode,
      weight = 1
    )
# add lines la uat
  if(input$admin_unit == "nut") {
    proxy <- 
      proxy |>
      addPolylines(
        data = ltser_uat_union,opacity = 0.8,
        color = c('#fdcdac','#cbd5e8','#f4cae4','#e6f5c9','#fff2ae','#b3e2cd'),
        group = "LTSER limits",
        options = pathOptions(clickable = FALSE)
      )
  }
})

# # navigare raster
# observe({
#   rs <- reac_rs_mon()$rs
#   leafletProxy("map_ltser") %>%
#     clearImages() %>%
#     addRasterImage(
#       rs, 
#       colors = reac_rs_mon()$pal,  
#       opacity = .8 ) %>%
#     clearControls() %>%
#     leaflet::addLegend(
#       title = reac_rs_mon()$tit_leg,
#       position = "bottomleft",
#       pal = reac_rs_mon()$pal_rev, values = reac_rs_mon()$domain,
#       opacity = 1,
#       labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE))
#     )
# })
# 
# # reactive values pentru plot lst time series din raster
# values_plot_lst_mon <- reactiveValues(input = NULL, title = NULL, cors = NULL)
# 
# observe({
#   isolate(print(input$tab_maps))
#   var <- reac_rs_mon()$indicator
#   lon = 25
#   lat = 46
#   dd <- extract_point(fname =  paste0("www/data/ncs/",  var, "_ltser_mon.nc"), lon  = lon, lat = lat, variable = var) 
#   print(head(dd))
#   ddf <- data.frame(date = as.Date(names(dd)), value = round(dd, 1)) %>% slice(1:reac_rs_mon()$index)
#   values_plot_lst_mon$input <- ddf
#   values_plot_lst_mon$title <- paste0("Extracted value ",toupper(var)," values for point lon = ",round(lon, 5)," lat = "  , round(lat, 5))
# })
# 
# # interactivitate raster
# observe({
#   proxy <- leafletProxy("map_ltser")
#   click <- input$map_ltser_click
#   rs <- reac_rs_mon()$rs
#   var <- reac_rs_mon()$indicator
#   fil.nc <- paste0("www/data/ncs/", var, "_ltser_mon.nc")
#   
#   if (input$radio_mon == 1 & !is.null(click)) {
#     show_pop(var = var,x = click$lng, y = click$lat, rdat = rs, proxy = proxy)
#   } else {
#    
#     proxy %>% clearPopups()
#     if (!is.null(click)) {
#       cell <- terra::cellFromXY(rs, cbind(click$lng, click$lat))
#       xy <- terra::xyFromCell(rs, cell)
#       dd <- extract_point(fname = fil.nc , lon = xy[1], lat = xy[2], variable = var) 
#       # pentru afisare conditional panel si titlu grafic coordonates
#       condpan_monthly.txt <- ifelse(
#         is.na(mean(dd, na.rm = T)) | is.na(cell), 
#         "You must click on an area with indicator values available", 
#         paste0("Extracted value ",toupper(var)," values for point lon = ",round(click$lng, 5)," lat = "  , round(click$lat, 5))
#       )
#       output$condpan_monthly <- renderText({
#         condpan_monthly.txt 
#       })
#       outputOptions(output, "condpan_monthly", suspendWhenHidden = FALSE)
#       ddf <- data.frame(date = as.Date(names(dd)), value = round(dd, 1)) %>% slice(1:reac_rs_mon()$index)
#       # valori pentru plot la reactive values
#       values_plot_lst_mon$title <- condpan_monthly.txt
#       values_plot_lst_mon$input <- ddf
#       values_plot_lst_mon$cors <- paste0(round(click$lng, 5), "_", round(click$lat, 5))
#       
#     }
#   }
#   
# })
# 
# # plot actualizat daca schimb si coordonatee
# output$rs_mon <- renderHighchart({
#   req(values_plot_lst_mon$input)
#   indicator <- reac_rs_mon()$indicator
#   
#   ytitle <- ifelse(indicator %in% c("ssm"),"%")
# 
#   hc_plot(
#     input =  values_plot_lst_mon$input , xaxis_series = c("value"), filename_save = indicator,
#     cols = c("green"), names = toupper(indicator), ytitle =   ytitle,
#     title =   values_plot_lst_mon$title
#   )
# })
# 


