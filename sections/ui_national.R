
filters_monthly_rs <- list(
  # transparenta ltser
  ltser_transp <- sliderInput(
    inputId = "transp_ind",
    label = "Transparency LTSER",
    min = 0,
    max = 1,
    value = 0.5,
    step = 0.1,
    width = "100%",
    ticks = F
  ),
  # selecteaza parametri
  param_select <- selectInput(
    "parameter_monthly", "Parameter:", 
    choices_map_monthly, 
    selected = choices_map_monthly[2]
  ),
  # selecteaza perioada
  period_select <- selectInput(
    inputId = 'month_indicator',
    label = 'Month:',
    rev(dats.ssm) |> format("%Y %b"),
    selected = max(dats.ssm) |> format("%Y %b")
  ),
  # radio button show values
  vals_radio <- radioButtons( 
    "radio_mon", label = "Click on map behavior",
    choices = 
      list(
        "Display current values on popup" = 1, 
        "Plot timeseries (below map)" = 2
      ), 
    selected = 1
  )
)


months_rs <- card(
  full_screen = TRUE,
  #card_header("National level"),
  layout_sidebar(
    sidebar(
      title = "Settings",
      !!!filters_monthly_rs 
    ),
    leafletOutput("map_ltser", height = 450),
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