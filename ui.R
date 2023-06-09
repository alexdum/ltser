# reconfigurare menu https://rstudio.github.io/bslib/reference/navs.html#details
source("sections/ui_national.R")
source("sections/ui_admin.R")
source("sections/ui_insitu.R")
source("sections/ui_social.R")
ui <- page_navbar(
  title = "LTSER Explorer",
  selected = "Remote sensing",
  collapsible = TRUE,
  fluid = T,
  inverse = F,
  theme = my_theme,
  id = "tabs", #id pentru activare tab when selected
  nav_panel(
    title = "Remote sensing",
    navset_card_tab(
      id = "tab_maps",
      nav_panel("National level", national_level),
      nav_panel("Admin level", admin_level)
    )
  ),
  nav_panel(
    title = "In situ",
    navset_card_tab(
      id = "tab_insitu",
      nav_panel("Lifewatch network", insitu_level)
    )
  ),
  nav_panel(
    title = "Social indicators",
    navset_card_tab(
      id = "tab_socio",
      nav_panel("Admin level", social_level)
    )
  ), 
  nav_panel(title = "About", p("TBA"))
)