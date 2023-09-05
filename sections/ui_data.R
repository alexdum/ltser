filters_data<- list(
  
  # select_admin
  selectInput(
    inputId = "network_data",
    label = "Network",
    choices = 
      c(
        "Weather stations" = "ws"
      ),
    selected =  "ws"
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