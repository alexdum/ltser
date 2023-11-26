filters_data_ec <- list(
  
  selectInput(
    inputId = "temp_res_ec",
    label = "Temporal resolution",
    choices = 
      c(
        "Halfhourly" = "halfhourly",
        "Daily" = "daily"
      ),
    selected =  "Halfhourly"
  )
)


data_level_ec <- card(
  fill = F,
  full_screen = F,
  layout_sidebar(
    sidebar = filters_data_ec,
    
    layout_columns(
      card(
        full_screen = T,
       "tba"
      ),
      card(
        full_screen = T,
       "tba"
      )
      ),
    accordion(
      open = F,
      accordion_panel(
       "tba"
        
      )
    )
  )
)