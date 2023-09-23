filters_data <- list(
  
  # select_admin
  selectInput(
    inputId = "network_data",
    label = "Network",
    choices = 
      c(
        "Weather stations" = "ws"
      ),
    selected =  "ws"
  ),
  
  selectInput(
    inputId = "temporal_resolution",
    label = "Temporal resolution",
    choices = 
      c(
        "Hourly" = "hourly",
        "Daily" = "daily"
      ),
    selected =  "daily"
  ),
  
  selectInput(
    "parameter_meteo", "Parameter:", 
    select_meteo_hourly, 
    selected = select_meteo_hourly[2]
  ),
  conditionalPanel(
    condition = "input.temporal_resolution == 'hourly'",
    shinyWidgets::airDatepickerInput(
      inputId = "datetime_meteo",
      label = "Date/Time:",
      multiple = F,
      value = max(hourly_dats$time) - 3600*3,
      minDate = min(hourly_dats$time) - 3600*3,
      maxDate = max(hourly_dats$time) - 3600*3,
      timepicker = TRUE,
      autoClose = T,
      timepickerOpts =  shinyWidgets::timepickerOptions(
        hoursStep = 1,
        timeFormat = "HH",
        minutesStep = 60
      )
    )
  ),
  conditionalPanel(
    condition = "input.temporal_resolution == 'daily'",
    shinyWidgets::airDatepickerInput(
      inputId = "date_meteo",
      label = "Date:",
      multiple = F,
      value = max(daily_dats$time),
      minDate = min(daily_dats$time),
      maxDate = max(daily_dats$time),
      timepicker = F,
      autoClose = T
    )
  )
)

data_level <- card(
  fill = F,
  full_screen = F,
  layout_sidebar(
    sidebar = filters_data,
    
    layout_columns(
      # width = 1/2,
      # heights_equal = "row",
      card(
        full_screen = T,
        leafletOutput("map_data", height = 450)
      ),
      card(
        full_screen = F,
        "TBA"
        #highchartOutput("ad_plot", height = "450px")# %>% withSpinner(size = 0.5)
      )
    )
  )
)