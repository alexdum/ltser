library(shiny)
library(ggplot2)
library(gridlayout)
library(bslib)
library(sf)
library(leaflet)
library(htmltools)

library(showtext) # Needed for custom font support
# Setup the bslib theme object
my_theme <- 
  bs_theme(
    bootswatch = "spacelab"
    # base_font = font_google("Righteous")
  )

ltser <- st_read("www/data/shp/ltser.topojson", quiet = T)


