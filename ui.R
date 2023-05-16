# reconfigurare menu https://rstudio.github.io/bslib/reference/navs.html#details
ui <- page_navbar(
  title = "LTSER Explorer",
  selected = "Maps",
  collapsible = TRUE,
  fluid = T,
  inverse = F,
  theme = my_theme,
  fill_mobile = T,
  nav_panel(
    title = "Maps",
    fluidRow(
      column(
        width = 2,
        card(
          card_body(
            
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
        )
      ),
      column(
        width = 7,
        card(
          card_body(
            leafletOutput("map_ltser")
            ),
          card_body(
            conditionalPanel( # show graphs only when data available
              condition = "input.radio_mon == 2 && output.condpan_monthly != 'nas'",
              highchartOutput("rs_mon", height = "350px")# %>% withSpinner(size = 0.5)
            ),
            conditionalPanel(
              condition = "input.radio_mon == 2 && output.condpan_monthly == 'nas'",
              p("You must click on an area with indicator values available")
            )
          )
        )
      )
    )
  ),
  nav_panel(
    title = "Other section"
  ),
  nav_panel(
    title = "About"
  )
)