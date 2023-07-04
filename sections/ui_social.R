
filters_social <- list(
  
  # select_admin
  selectInput(
    inputId = "social_indicator",
    label = "Social statistics",
    choices = 
      c("Resident pop July 1st" = "pop106a",
        "Pop residency July 1st." = "pop108d",
        "Definitive emigrants" = "pop309e"
      ),
    selected =  "pop106a"
  ),
  selectInput(
    inputId = "social_years",
    label = "Years",
    choices = 2022,
    selected =  2021
  ),
  
  conditionalPanel(
    condition = "input.social_indicator == 'pop106a' || input.social_indicator == 'pop108d'",
    selectInput(
      "social_gender", "Gender",
      choices = 
        c(
          "Famale" = 1,
          "Male" = 2,
          "All" = 3
        ),
      selected = 3
    ),
    selectInput(
      "social_ages", "Ages",
      choices = 
        c(
          "Years" = "years",
          "All" = "all"
        ),
      selected = "all"
    ),
    conditionalPanel(
      condition = "input.social_ages == 'years'",
      selectInput("social_years", NULL,
                  socio_ages, 
                  selected = socio_ages[35]
                  
                  
      )
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
        #leafletOutput("map_insitu", height = 450)
        p("TBA")
      ),
      card(
        full_screen = F,
        #uiOutput("net_desc_markdown")
        #highchartOutput("ad_plot", height = "450px")# %>% withSpinner(size = 0.5)
        p("TBA")
      )
    )
  )
)