
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
  
  indicator <- input$parameter_monthly_ad
  # selectie unitate
  switch( # alege nume indicator care să fie afișat
    which(c("ltser", "nut") %in%  input$admin_unit),
    admin_spat <- ltser,
    admin_spat <- ltser_uat
  )
  
 tab <-  
    read_parquet(paste0("www/data/parquet/", input$admin_unit,"/", indicator, "_mon.parquet")) |>
    filter(format(date, "%Y %b") %in% input$month_indicator_ad)
 
 admin_spat_sub <-
   admin_spat |>
    left_join(tab, by = c("natcode" = "ID"))
  
  
  map_leg <- mapa_fun_cols(indic = indicator,domain = range(admin_spat_sub$value))
  
  list(admin_spat_sub = admin_spat_sub, pal = map_leg$pal, pal_rev = map_leg$pal_rev, tit_leg = map_leg$tit_leg)
})

# harta leaflet -----------------------------------------------------------
output$map_ltser_ad <- renderLeaflet ({
  
  leaflet_fun_ad(
    data = isolate(admin_sel()$admin_spat_sub),
    pal =  isolate(admin_sel()$pal),
    pal_rev =  isolate(admin_sel()$pal_rev),
    tit_leg = isolate(admin_sel()$tit_leg)
  )
  
})

# opacitate polygon
observe({
  
  pal_rev =  admin_sel()$pal_rev
  tit_leg = admin_sel()$tit_leg
  data <- admin_sel()$admin_spat_sub
  pal <- admin_sel()$pal
  data <- admin_sel()$admin_spat_sub

  proxy <- leafletProxy("map_ltser_ad", data = data) |>
    clearShapes() |>
    addPolygons(
      #data =  admin_sel()$admin_spat,
      label = ~paste("<font size='2'><b>",name,
                              "<br/>",round(value,1),"</b></font><br/>") %>% lapply(htmltools::HTML),
      group = "LTSER",
      #fillColor = "#99d8c9",
      color = "grey",
      weight = 0.5, smoothFactor = 0.1,
      opacity = 0.5,
      fillColor = ~pal(value),
      #color = ~pal(values),
      fillOpacity = input$transp_ind_ad,
      layerId = ~natcode,
      highlightOptions = highlightOptions(
        weight = 2,
        color = "#666",
        fillOpacity = 0.2,
        bringToFront = TRUE,
        sendToBack = TRUE)
    ) |>
    clearControls() |>
    addLegend(
      title = tit_leg,
      "bottomleft", pal = pal_rev, values = ~value, opacity = 1,
      labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE))
    ) 
# # add lines la uat
#   if(input$admin_unit == "nut") {
#     proxy <- 
#       proxy |>
#       addPolylines(
#         data = ltser_uat_union,opacity = 0.8,
#         color = c('#fdcdac','#cbd5e8','#f4cae4','#e6f5c9','#fff2ae','#b3e2cd'),
#         group = "LTSER limits",
#         options = pathOptions(clickable = FALSE)
#       )
#   }
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


