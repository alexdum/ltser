

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
              dats.ssm |> format("%Y %b"),
              selected = max(dats.ssm) |> format("%Y %b")
          )
        )
      ),
      grid_card(
        area = "map_ltser",
        card_header("LTSER location"),
        card_body(
          full_screen = TRUE,
          leafletOutput("map_ltser", height = 450)
        )
      )
    )
  ),
  tabPanel(
    title = "Distributions",
    grid_container(
      row_sizes = c(
        "165px",
        "1fr"
      ),
      col_sizes = c(
        "1fr"
      ),
      gap_size = "10px",
      layout = c(
        "facetOption",
        "dists"
      ),
      grid_card_plot(area = "dists"),
      grid_card(
        area = "facetOption",
        card_header("Distribution Plot Options"),
        card_body_fill(
          radioButtons(
            inputId = "distFacet",
            label = "Facet distribution by",
            choices = list("Diet Option" = "Diet", "Measure Time" = "Time")
          )
        )
      )
    )
  ),
  tabPanel(title = "About")
)