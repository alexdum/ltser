# reconfigurare menu https://rstudio.github.io/bslib/reference/navs.html#details
source("sections/ui_national.R")
source("sections/ui_admin.R")
source("sections/ui_insitu.R")
ui <- page_navbar(
  title = "LTSER Explorer",
  selected = "Maps",
  collapsible = TRUE,
  fluid = T,
  inverse = F,
  theme = my_theme,
  nav_panel(
    title = "Maps",
    navset_card_tab(
      id = "tab_maps",
      nav_panel("National level", national_level),
      nav_panel("Admin level", admin_level)
    )
  ),
  nav_panel (
    title = "In situ data",
    navset_card_tab(
      id = "tab_insitu",
      nav_panel("Lifewatch network", insitu_level)
      
    )
  ),
  nav_panel(title = "About", p("TBA") )
)