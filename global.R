library(shiny)
library(ggplot2)
library(gridlayout)
library(bslib)
library(sf)
library(leaflet)
library(htmltools)
library(dplyr)
library(RColorBrewer)
library(terra)

source("utils/leaflet_fun.R")
source("utils/map_fun_cols.R")

library(showtext) # Needed for custom font support
# Setup the bslib theme object
my_theme <- 
  bs_theme(
    bootswatch = "spacelab"
    # base_font = font_google("Righteous")
  )

ltser <- st_read("www/data/shp/ltser.topojson", quiet = T)


# selectare perioada de interes
select_period <- read.csv("www/data/tabs/select_period.csv") 
select_period <- setNames(select_period$choice, select_period$parameter)

choices_map_monthly <- read.csv("www/data/tabs/slelect_input_parameters_monthly.csv") 
choices_map_monthly <- setNames(choices_map_monthly$choice, choices_map_monthly$parameter)

# citeste produse
ssm <- terra::rast("www/data/ncs/ssm_ltser_mon.nc")
dats.ssm <- as.Date(names(ssm) %>% gsub("ssm_days=", "",.) %>% as.integer(), origin = "1970-1-1 00:00:00") |> rev()

