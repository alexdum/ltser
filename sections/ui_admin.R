
filters_admin_rs <- list(
  
  # select_admin
  selectInput(
    inputId = "admin_unit",
    label = "Unit",
    choices = c("LTSER" = "ltser",
                "NUT" = "nut"),
    selected =  "ltser"
  ),
  # selecteaza parametri
  param_select_ad <- selectInput(
    "parameter_monthly_ad", "Parameter:", 
    choices_map_monthly, 
    selected = choices_map_monthly[1]
  ),
  # selecteaza perioada
  period_select_ad <- selectInput(
    inputId = 'month_indicator_ad',
    label = 'Month:',
    rev(dats.ssm) |> format("%Y %b"),
    selected = max(dats.ssm) |> format("%Y %b")
  ),
  # transparenta ltser
  ltser_transp <- sliderInput(
    inputId = "transp_ind_ad",
    label = "Transparency unit",
    min = 0,
    max = 1,
    value = 0.5,
    step = 0.1,
    width = "100%",
    ticks = F
  ),
  getshp <- downloadButton('downshp', 'Get GeoJSON')
)


admin_level <- card(
  fill = F,
  full_screen = F,
  #card_header("National level"),
  layout_sidebar(
    sidebar = filters_admin_rs,
    
    layout_columns(
      #width = 1/2,
     # heights_equal = "row",
      card(
        full_screen = T,
        leafletOutput("map_ltser_ad", height = 450)
      ),
      card(
        full_screen = T,
        highchartOutput("ad_plot", height = "450px")# %>% withSpinner(size = 0.5)
        
      )
      
    )
  )
)