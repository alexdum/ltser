
filters_insitu <- list(
  
  # select_admin
  selectInput(
    inputId = "network",
    label = "Network",
    choices = c("Weather stations" = "ws",
                "Eddy covariance" = "ec"),
    selected =  "ws"
  )
)


insitu_level <- card(
  full_screen = F,
  layout_sidebar(
    sidebar = filters_insitu ,
    
    layout_column_wrap(
      width = 1/2,
      heights_equal = "row",
      card(
        full_screen = T,
        leafletOutput("map_insitu", height = 450)
      ),
      card(
        full_screen = F,
        p("TBA")
        #highchartOutput("ad_plot", height = "450px")# %>% withSpinner(size = 0.5)
        
      )
    )
  )
)