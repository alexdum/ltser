filters_data_ws <- list(
  
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
      value = as.character(max(hourly_dats$time)), # transforma in caracater sa nu le decaleze
      minDate = as.character(min(hourly_dats$time)),
      maxDate = as.character(max(hourly_dats$time)),
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
      value = as.character(max(daily_dats$time)),
      minDate = as.character(min(daily_dats$time)),
      maxDate = as.character(max(daily_dats$time)),
      timepicker = F,
      autoClose = T
    )
  )
)

data_level_ws <- card(
  fill = F,
  full_screen = F,
  layout_sidebar(
    sidebar = filters_data_ws,
    
    layout_columns(
      # width = 1/2,
      # heights_equal = "row",
      card(
        full_screen = T,
        leafletOutput("map_data", height = 450)
      ),
      card(
        full_screen = T,
        highchartOutput("meteo_plot", height = "450px")# %>% withSpinner(size = 0.5)
      )
    ),
    accordion(
      open = F,
      accordion_panel(
        "Data", icon = bsicons::bs_icon("table",  class = "d-flex justify-content-between align-items-center"),
        DT::dataTableOutput('metoe_table')
       
      )
    )
  )
)