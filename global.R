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
library(DT)
Sys.setenv(TZ = "GMT") 
source_python("utils/extract_point.py") 
source("utils/leaflet_fun_na.R")
source("utils/leaflet_fun_ad.R")
source("utils/leaflet_fun_meta.R")
source("utils/leaflet_fun_data.R")

source("utils/map_fun_cols.R", local = T)
source("utils/show_pop.R", local = T)
source("utils/graphs_funs.R", local = T)
source("utils/subset_param.R", local = T)
source("utils/graphs_meteo.R", local = T)

library(showtext) # Needed for custom font support
# Setup the bslib theme object
my_theme <- 
  bs_theme(
    bootswatch = "spacelab",
    version = 5
    # base_font = font_google("Righteous")
  )

ltser <- st_read("www/data/shp/ltser.topojson", quiet = T)
ltser_uat <-  st_read("www/data/shp/uat_ltser.topojson", quiet = T)
ltser_uat$name <- paste0(ltser_uat$name,"\n", ltser_uat$ltser)
ltser_uat_union <-  st_read("www/data/shp/uat_ltser_lines_union.geojson", quiet = T)

ws <- st_read("www/data/shp/ws.geojson", quiet = T)

ws$Locality[ws$Name == "IF-Cor"] <- "Mihilești"
ws$County[ws$Name == "IF-Cor"] <- "Giurgiu"
ws$Name[ws$Name == "IF-Cor"]  <- "GR-Mih"

ws$Locality[ws$Name == "IF-Ste"] <- "Lilieci"
ws$County[ws$Name == "IF-Ste"] <-  "Ialomița"
ws$Name[ws$Name == "IF-Ste"]  <- "IL-Lil"




ws_df <- as.data.frame(ws)
ec <- st_read("www/data/shp/ec.geojson", quiet = T)
bu <- st_read("www/data/shp/bu.geojson", quiet = T)

# read social
# pop106a <- read_parquet("www/data/parquet/socio/pop106a.parquet") |> setDT()  
pop108d <- open_dataset("www/data/parquet/socio/pop108d.parquet") 
pop309e <- open_dataset("www/data/parquet/socio/pop309e.parquet") 
socio_years <- readRDS("www/data/tabs/socio_years.rds")

# network description
net_des <- read.csv("www/data/tabs/network_description.csv")

# selectare perioada de interes
select_period <- read.csv("www/data/tabs/select_period.csv") 
select_period <- setNames(select_period$choice, select_period$parameter)

choices_map_monthly <- read.csv("www/data/tabs/slelect_input_parameters_monthly.csv") 
choices_map_monthly <- setNames(choices_map_monthly$choice, choices_map_monthly$parameter)

socio_ages <- read.csv("www/data/tabs/select_input_socio_ages.csv") 
socio_ages <- setNames(socio_ages$id, socio_ages$eticheta)

# citeste produse
ssm <- terra::rast("www/data/ncs/ssm_ltser_mon_dineof.nc")
#ats.ssm <- as.Date(names(ssm) %>% gsub("ssm_days=", "",.) %>% as.integer(), origin = "1970-1-1 00:00:00")
dats.ssm <- time(ssm)
dats.ssm <- dats.ssm[dats.ssm < as.Date("2023-09-01")]

ndvi <- terra::rast("www/data/ncs/ndvi_ltser_mon.nc")
dats.ndvi <- as.Date(names(ndvi) %>% gsub("ndvi_days=", "",.) %>% as.integer(), origin = "1970-1-1 00:00:00")
time(ndvi) <- dats.ndvi


fapar <- terra::rast("www/data/ncs/fapar_ltser_mon.nc")
dats.fapar <- as.Date(names(fapar) %>% gsub("fapar_days=", "",.) %>% as.integer(), origin = "1970-1-1 00:00:00")
time(fapar) <- dats.fapar

# read meteo

daily <- open_dataset("www/data/parquet/meteo/daily/")
daily_dats <- daily |> select(time) |> distinct() |> filter(time > as.Date("2023-08-22")) |> arrange(desc(time)) |> collect() 

max_hourly <-  as.POSIXct(paste(max(daily_dats$time), "23:59:00"))
hourly <- open_dataset("www/data/parquet/meteo/hourly/")
hourly_dats <-
  hourly |> select(time) |> distinct() |> 
  filter(time > as.POSIXct("2023-08-22")) |> filter(time <= max_hourly) |> arrange(desc(time)) |> collect()


# selectare meteo controlere
select_meteo_daily <- read.csv("www/data/tabs/select_input_meteo_daily.csv") 
select_meteo_daily <- setNames(select_meteo_daily$choice, select_meteo_daily$parameter)
select_meteo_hourly <- read.csv("www/data/tabs/select_input_meteo_hourly.csv") 
select_meteo_hourly <- setNames(select_meteo_hourly$choice, select_meteo_hourly$parameter)

# selectare ec controloere
ec_halfhourly <- read.csv("www/data/tabs/select_input_ec_halfhourly.csv")
select_ec_halfhourly <- setNames(ec_halfhourly$choice, ec_halfhourly$parameter)

# read ec
hhourly_ec <- open_dataset("www/data/parquet/ec/")
hhourly_dats <- hhourly_ec  |> select(time_eet) |> distinct() |> arrange(desc(time_eet)) |> collect() 
