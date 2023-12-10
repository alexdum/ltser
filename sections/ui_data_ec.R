filters_data_ec <- list(
  
  selectInput(
    inputId = "temp_res_ec",
    label = "Temporal resolution",
    choices = 
      c(
        "Halfhourly" = "halfhourly"
      ),
    selected =  "Halfhourly"
  ),
  
  selectInput(
    "parameter_ec", "Parameter:", 
    select_ec_halfhourly, 
    selected = select_ec_halfhourly[1]
  ),
  
  shinyWidgets::airDatepickerInput(
    inputId = "datetime_ec",
    label = "Date/Time:",
    multiple = F,
    value = as.character(max(hhourly_dats$time_eet)), # transforma in caracater sa nu le decaleze
    minDate = as.character(min(hhourly_dats$time_eet)),
    maxDate = as.character(max(hhourly_dats$time_eet)),
    timepicker = TRUE,
    autoClose = T,
    timepickerOpts =  shinyWidgets::timepickerOptions(
      hoursStep = 1,
      timeFormat = "HH:mm",
      minutesStep = 30
    )
    
  )
  
  
)


data_level_ec <- card(
  fill = F,
  full_screen = F,
  layout_sidebar(
    sidebar = filters_data_ec,
    
    layout_columns(
      height = "500px",
      card(
        full_screen = T,
        leafletOutput("map_ec")
      ),
      navset_card_underline(
        full_screen = T,
        id = "graph_img_nav",
        nav_panel(
          "Graph",
          highchartOutput("ec_plot")
        ),
        nav_panel(
          "Camera",
          card( 
            full_screen = F,
            fill = T,
            imageOutput("photo_ec")
          )
        )
      )
    ),
    accordion(
      open = F,
      accordion_panel(
        "Data", icon = bsicons::bs_icon("table",  class = "d-flex justify-content-between align-items-center"),
        DT::dataTableOutput('ec_table')
        
      )
    )
  )
)
