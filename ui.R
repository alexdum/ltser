
ui <- navbarPage(
  title = "LTSER Explorer",
  selected = "Maps",
  collapsible = TRUE,
  theme = my_theme,
  tabPanel(
    title = "Maps",
    grid_container(
      row_sizes = c(
        "1fr"
      ),
      col_sizes = c(
        "250px",
        "1fr"
      ),
      gap_size = "10px",
      layout = c(
        "transp_ind map_ltser"
      ),
      grid_card(
        area = "transp_ind",
        card_header("Settings"),
        card_body_fill(
          sliderInput(
            inputId = "transp_ind",
            label = "Transparency LTSER",
            min = 0,
            max = 1,
            value = 0.5,
            step = 0.1,
            width = "100%"
          ),
          selectInput(
            "parameter_monthly", "Parameter:", 
            choices_map_monthly, 
            selected = choices_map_monthly[2]
          ),
          selectInput(
            inputId = 'month_indicator',
              label = 'Month:',
              rev(dats.ssm) |> format("%Y %b"),
              selected = max(dats.ssm) |> format("%Y %b")
          ),
          radioButtons( # radio button show values
            "radio_mon", label = "Click on map behavior",
            choices = 
              list(
                "Display current values on popup" = 1, 
                "Plot timeseries (below map)" = 2
              ), 
            selected = 1
          )
        )
      ),
      grid_card(
        area = "map_ltser",
        card_header("LTSER location"),
        card_body(
          full_screen = F,
          leafletOutput("map_ltser", height = 450)
        ),
        card_body(
          full_screen = F,
          conditionalPanel( # show graphs only when data available
            condition = "input.radio_mon == 2 && output.condpan_monthly != 'nas'",
            wellPanel(
              highchartOutput("rs_mon")# %>% withSpinner(size = 0.5)
            )
          ),
          conditionalPanel(
            condition = "input.radio_mon == 2 && output.condpan_monthly == 'nas'",
            wellPanel(
              p("You must click on an area with indicator values available")
            )
          )
        )
      )
    )
  ),
  tabPanel(
    title = "Other section"
  ),
  tabPanel(title = "About")
)