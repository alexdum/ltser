
filters_monthly_rs <- list(
  # transparenta ltser
  ltser_transp <- sliderInput(
    inputId = "transp_ind",
    label = "Transparency LTSER",
    min = 0,
    max = 1,
    value = 0.5,
    step = 0.1,
    width = "100%",
    ticks = F
  ),
  # selecteaza parametri
  param_select <- selectInput(
    "parameter_monthly", "Parameter:", 
    choices_map_monthly, 
    selected = choices_map_monthly[2]
  ),
  # selecteaza perioada
  period_select <- selectInput(
    inputId = 'month_indicator',
    label = 'Month:',
    rev(dats.ssm) |> format("%Y %b"),
    selected = max(dats.ssm) |> format("%Y %b")
  ),
  # radio button show values
  vals_radio <- radioButtons( 
    "radio_mon", label = "Click on map behavior",
    choices = 
      list(
        "Display current values on popup" = 1, 
        "Plot timeseries" = 2
      ), 
    selected = 2
  ),
  
  gettif <- downloadButton('downgtif', 'Get GeoTIFF')
)


national_level <- card(
  full_screen = F,
  #card_header("National level"),
  layout_sidebar(
    sidebar(
      title = "Settings",
      !!!filters_monthly_rs 
    ),
    
    layout_column_wrap(
      width = 1/2,
      heights_equal = "row",
      card(
        full_screen = T,
        leafletOutput("map_ltser", height = 450)
      ),
      card(
        full_screen = T,
        highchartOutput("na_plot", height = "450px")# %>% withSpinner(size = 0.5)
        
      )
      
    )
  )
)