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
library(reticulate)
library(highcharter)
library(arrow)

source_python("utils/extract_point.py") 
source("utils/leaflet_fun_na.R")
source("utils/leaflet_fun_ad.R")
source("utils/map_fun_cols.R", local = T)
source("utils/show_pop.R", local = T)
source("utils/graphs_funs.R", local = T)

library(showtext) # Needed for custom font support
# Setup the bslib theme object
my_theme <- 
  bs_theme(
    bootswatch = "spacelab"
    # base_font = font_google("Righteous")
  )

ltser <- st_read("www/data/shp/ltser.topojson", quiet = T)
ltser_uat <-  st_read("www/data/shp/uat_ltser.topojson", quiet = T)
ltser_uat$name <-paste0(ltser_uat$name,"\n", ltser_uat$ltser)
ltser_uat_union <-  st_read("www/data/shp/uat_ltser_lines_union.geojson", quiet = T)


# selectare perioada de interes
select_period <- read.csv("www/data/tabs/select_period.csv") 
select_period <- setNames(select_period$choice, select_period$parameter)

choices_map_monthly <- read.csv("www/data/tabs/slelect_input_parameters_monthly.csv") 
choices_map_monthly <- setNames(choices_map_monthly$choice, choices_map_monthly$parameter)

# citeste produse
ssm <- terra::rast("www/data/ncs/ssm_ltser_mon.nc")
dats.ssm <- as.Date(names(ssm) %>% gsub("ssm_days=", "",.) %>% as.integer(), origin = "1970-1-1 00:00:00")

