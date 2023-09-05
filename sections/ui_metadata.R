filters_metadata <- list(
  
  # select_admin
  selectInput(
    inputId = "network",
    label = "Network",
    choices = 
      c("Weather stations" = "ws",
        "Eddy covariance" = "ec",
        "Buoys" = "bu"
      ),
    selected =  "ws"
  )
)


metadata_level <- card(
  fill = F,
  full_screen = F,
  layout_sidebar(
    sidebar = filters_metadata,
    
    layout_columns(
      # width = 1/2,
      # heights_equal = "row",
      card(
        full_screen = T,
        leafletOutput("map_metadata", height = 450)
      ),
      card(
        full_screen = F,
        uiOutput("net_desc_markdown")
        #highchartOutput("ad_plot", height = "450px")# %>% withSpinner(size = 0.5)
      )
    )
  )
)