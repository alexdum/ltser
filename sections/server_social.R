# observeEvent(input$social_indicator, ignoreInit = T, {
#   
#   # update ani
#   updateSelectizeInput(
#     session, "social_years",
#     choices = socio_years[[input$social_indicator]],
#     selected = max(socio_years[[input$social_indicator]])
#   )
#   
# })

soc_df <- reactive({
  
  if (input$social_indicator == "pop108d") {
    soc_ind_sub <- 
      pop108d |> 
      filter(an %in% input$social_years_pop108d, varsta %in% input$social_agesyear, sex %in% input$social_gender) |>
      collect()
    year_filt <- input$social_years_pop108d
    # pentru initializare grafic
    tab <- 
      pop108d |> 
      filter(varsta %in% input$social_agesyear, sex %in% input$social_gender) |>
      collect()
  } else {
    tab <- soc_ind_sub <- 
      pop309e |>
      collect() 
    
    soc_ind_sub <- soc_ind_sub |> filter(an %in% input$social_years_pop309e) 
    
    
    year_filt <- input$social_years_pop309e
  }
  
  socio_spat <-
    ltser_uat |>
    #mutate(natcode = as.numeric(natcode)) |>
    left_join( soc_ind_sub, by = c("natcode" = "uat")) |>
    mutate(value = ifelse(is.na(value), 0, value))
  
  #pentru grafic
  tab <- tab |>
    rename(date = an) |>
    mutate(date = as.Date(paste0(date, "-01-01")))
  year_filt <- as.Date(paste0(year_filt, "-01-01"))
  
  map_leg <- mapa_fun_cols(indic = input$social_indicator, domain = range(socio_spat$value))
  
  list(socio_spat =  socio_spat, pal = map_leg$pal, pal_rev = map_leg$pal_rev, tit_leg = map_leg$tit_leg,
       tab = tab,  year_filt = year_filt)
})

output$map_ltser_social <- renderLeaflet ({
  leaflet_fun_ad(
    indicator = input$social_indicator ,
    data = isolate(soc_df()$socio_spat),
    pal =  isolate(soc_df()$pal),
    pal_rev =  isolate(soc_df()$pal_rev),
    tit_leg = isolate(soc_df()$tit_leg)
  )
  
})

# opacitate polygon
observe({
  data = soc_df()$socio_spat
  pal =  soc_df()$pal
  pal_rev = soc_df()$pal_rev
  tit_leg = soc_df()$tit_leg
  
  lab_legend <- labelFormat(transform = function(x) sort(x, decreasing = TRUE), digits = 0)
  
  proxy <- leafletProxy("map_ltser_social", data = data) |>
    clearShapes() |>
    addPolygons(
      #data =  admin_sel()$admin_spat,
      label = ~paste("<font size='2'><b>",name,
                     "<br/>",round(value,0),"</b></font><br/><font size='1' color='#E95420'>Click to
                       get values and graph</font>") %>% lapply(htmltools::HTML),
      group = "Unit",
      #fillColor = "#99d8c9",
      color = "grey",
      weight = 0.5, smoothFactor = 0.1,
      opacity = 0.5,
      fillColor = ~pal(value),
      #color = ~pal(values),
      # fillOpacity = input$transp_ind_ad,
      fillOpacity = 0.8,
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
      labFormat = lab_legend
    ) 
  
})

# reactive values pentru plot lst time series 
values_plot_so <- reactiveValues(
  input = NULL, title = NULL, id = NULL, name = NULL, 
  admin = NULL, update_admin = NULL
)
# valori initiale de start
observeEvent(list(isolate(input$tab_socio),input$social_indicator, isolate(input$social_years_pop309e), 
                  isolate(input$social_years_pop108d), input$social_gender, input$social_agesyear),{
                    tab <- soc_df()$tab
                    admin_spat_sub <- soc_df()$socio_spat
                    first_sel <- sample(1:nrow(admin_spat_sub), 1)
                    values_plot_so$id <- admin_spat_sub$natcode[first_sel]
                    values_plot_so$name <- admin_spat_sub$name[admin_spat_sub$natcode == values_plot_so$id]
                    values_plot_so$input <-
                      tab |>
                      filter(uat %in% values_plot_so$id) |>
                      select(date, value) #|>
                    
                    
                  })


# update plot by click
observeEvent(input$map_ltser_social_shape_click$id,{ 
  tab <- soc_df()$tab
  admin_spat_sub <- soc_df()$socio_spat
  values_plot_so$id  <- input$map_ltser_social_shape_click$id
  values_plot_so$name <- admin_spat_sub$name[admin_spat_sub$natcode == values_plot_so$id]
  values_plot_so$input <-  
    tab |>
    filter(uat %in% values_plot_so$id) |>
    select(date, value) 
})

# plot actualizat
output$so_plot <- renderHighchart({
  #req(input$admin_unit)
  # pentru subsetare in functie de data selectate
  tab_plot <- values_plot_so$input
  tab_plot  <-
    tab_plot  |>
    filter(date <=  soc_df()$year_filt) 
  
  ytitle <- "No persons"
  
  hc_plot(
    input =  tab_plot, xaxis_series = c("value"), filename_save = input$social_indicator,
    cols = c("green"), names = toupper(input$social_indicator), ytitle =   ytitle,
    title =   values_plot_so$name
  )
})

# pentru descarcare fisier Geotiff
output$downsocio <- downloadHandler(
  filename = function() { paste0(input$social_indicator,".geojson") },
  content = function(file) {
    st_write(soc_df()$socio_spat, file, driver = "GeoJSON", quiet = T, delete_layer = T)
  })


