# reconfigurare menu https://rstudio.github.io/bslib/reference/navs.html#details
source("sections/ui_months.R")
ui <- page_navbar(
  title = "LTSER Explorer",
  selected = "Maps",
  collapsible = TRUE,
  fluid = T,
  inverse = F,
  theme = my_theme,
  fill_mobile = T,
  nav_panel(
    "Maps",
    navset_card_tab(
      nav_panel("National level", months_rs, width = "50%"),
      nav_panel("Admin level",  p("TBA"))
    )
  ),
  nav_panel(title = "Other section", p("TBA")),
  nav_panel(title = "About", p("TBA") )
)