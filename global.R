library(shiny)
library(ggplot2)
library(gridlayout)
library(bslib)

library(showtext) # Needed for custom font support
# Setup the bslib theme object
my_theme <- 
  bs_theme(
    bootswatch = "spacelab"
    # base_font = font_google("Righteous")
  )