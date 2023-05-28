admin_sel <- reactive({
  
  indicator <- input$parameter_monthly_ad
  # selectie unitate
  switch( # alege nume indicator care să fie afișat
    which(c("ltser", "nut") %in%  input$admin_unit),
    admin_spat <- ltser,
    admin_spat <- ltser_uat
  )
  
  tab <-  
    read_parquet(paste0("www/data/parquet/", input$admin_unit,"/", indicator, "_mon.parquet")) #|>
  #filter(format(date, "%Y %b") <= input$month_indicator_ad)
  
  admin_spat_sub <-
    admin_spat |>
    left_join(tab, by = c("natcode" = "ID")) |>
    filter(format(date, "%Y %b") %in% input$month_indicator_ad) 
  
  
  map_leg <- mapa_fun_cols(indic = indicator,domain = range(admin_spat_sub$value))
  
  list(
    admin_spat_sub = admin_spat_sub, pal = map_leg$pal, pal_rev = map_leg$pal_rev, 
    tit_leg = map_leg$tit_leg, tab = tab,  indicator= indicator, unit = input$admin_unit
  )
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
                     "<br/>",round(value,1),"</b></font><br/><font size='1' color='#E95420'>Click to
                       get values and graph</font>") %>% lapply(htmltools::HTML),
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

# reactive values pentru plot lst time series 
values_plot_ad <- reactiveValues(
  input = NULL, title = NULL, id = NULL, name = NULL, 
  admin = NULL, update_admin = NULL
)

# valori initiale de start
observeEvent(list(isolate(input$tab_maps),input$admin_unit),{
  tab <- admin_sel()$tab
  admin_spat_sub <- admin_sel()$admin_spat_sub
  first_sel <- sample(1:nrow(admin_spat_sub), 1)
  values_plot_ad$id <- admin_spat_sub$natcode[first_sel]
  values_plot_ad$name <- admin_spat_sub$name[admin_spat_sub$natcode == values_plot_ad$id]
  values_plot_ad$input <-  
    tab |>
    filter(ID %in% values_plot_ad$id) |>
    select(date, value) #|>
  #filter(date <=  as.Date(paste(input$month_indicator_ad, "25"),  "%Y %b %d"))
})

# update plot by click
observeEvent(input$map_ltser_ad_shape_click$id,{ 
  tab <- admin_sel()$tab
  admin_spat_sub <- admin_sel()$admin_spat_sub
  values_plot_ad$id  <- input$map_ltser_ad_shape_click$id
  values_plot_ad$name <- admin_spat_sub$name[admin_spat_sub$natcode == values_plot_ad$id]
  values_plot_ad$input <-  
    tab |>
    filter(ID %in% values_plot_ad$id) |>
    select(date, value) 
})


# plot actualizat
output$ad_plot <- renderHighchart({
  #req(input$admin_unit)
  indicator <- admin_sel()$indicator
  # pentru subsetare in functie de data selectate
  tab_plot <- values_plot_ad$input
  tab_plot  <-
    tab_plot  |>
    filter(date <= as.Date(paste(input$month_indicator_ad, "25"),  "%Y %b %d"))
  
  ytitle <- ifelse(indicator %in% c("ssm"),"%")
  
  hc_plot(
    input =  tab_plot, xaxis_series = c("value"), filename_save = indicator,
    cols = c("green"), names = toupper(indicator), ytitle =   ytitle,
    title =   values_plot_ad$name
  )
})





