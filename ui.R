# reconfigurare menu https://rstudio.github.io/bslib/reference/navs.html#details
source("sections/ui_national.R")
source("sections/ui_admin.R")
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
      id = "tab_maps",
      nav_panel("National level", national_level),
      nav_panel("Admin level", admin_level)
    )
  ),
  nav_panel(title = "Other section", p("TBA")),
  nav_panel(title = "About", p("TBA") )
)