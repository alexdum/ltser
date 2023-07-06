
filters_social <- list(
  
  # select_admin
  selectInput(
    inputId = "social_indicator",
    label = "Social statistics",
    choices = 
      c(#"Resident pop July 1st" = "pop106a",
        "Pop residency" = "pop108d",
        "Definitive emigrants" = "pop309e"
      ),
    selected =  "pop108d"
  ),
  
  conditionalPanel(
    condition = "input.social_indicator == 'pop309e'",
    selectInput(
      inputId = "social_years_pop309e",
      label = "Year",
      choices = socio_years$pop309e 
    )
  ),
  
  
  conditionalPanel(
    condition = "input.social_indicator == 'pop108d'",
    selectInput(
      inputId = "social_years_pop108d",
      label = "Year",
      choices = socio_years$pop108d 
    ),
    selectInput(
      "social_gender", "Gender",
      choices = 
        c(
          "All" = 3,
          "Famale" = 1,
          "Male" = 2
        ),
      selected = 3
    ),
    # selectInput(
    #   "social_ages", "Ages",
    #   choices = 
    #     c(
    #       "Years" = "years",
    #       "All" = "all"
    #     ),
    #   selected = "all"
    # ),
    # conditionalPanel(
    #   condition = "input.social_ages == 'years'",
      selectInput("social_agesyear", 
                  "Ages",
                  socio_ages, 
                  selected = socio_ages[1]
                  
                  
      #)
    )
  )
)

social_level <- card(
  max_height = 550,
  full_screen = F,
  layout_sidebar(
    sidebar = filters_social ,
    
    layout_columns(
      # width = 1/2,
      # heights_equal = "row",
      card(
        full_screen = T,
        leafletOutput("map_ltser_social", height = 450)
      ),
      card(
        full_screen = F,
        #uiOutput("net_desc_markdown")
        highchartOutput("so_plot", height = "450px")# %>% withSpinner(size = 0.5)
      )
    )
  )
)