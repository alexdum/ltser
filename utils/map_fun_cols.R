colintRdYlBu <- colorRampPalette(brewer.pal(10,"RdYlBu"),interpolate = "linear")
colintYlGn <- colorRampPalette(brewer.pal(9,"YlGn"),interpolate = "linear")
colintRdYlGn <- colorRampPalette(brewer.pal(11,"RdYlGn"),interpolate = "linear")

mapa_fun_cols <- function(indic = NA,  domain = NA) {
  # culori interpolate
  # culori culori leaflet ---------------------------------------------------------
  colintRdYlBu <- colorRampPalette(brewer.pal(10,"RdYlBu"),interpolate = "linear")
  colintBuPu <- colorRampPalette(brewer.pal(9,"BuPu"),interpolate = "linear")
  colintYlOrBr <- colorRampPalette(brewer.pal(9,"YlOrBr"),interpolate = "linear")
  
  if (indic %in% c("ssm")) {
        df.col <- data.frame(
          cols = colintRdYlBu(11), 
          vals = seq(0,100,10)
        ) 
      leaflet_titleg <- paste0("<html>", gsub(",","",toString(rep("&nbsp;", 2))), "SSM [%]","</html>")
  }
  
  if (indic %in% c("ndvi")) {
    df.col <- data.frame(
      cols = brewer.pal(11,"RdYlGn")[2:11], 
      vals = seq(-0.8,1,0.2)
    ) 
    leaflet_titleg <- paste0("<html>", gsub(",","",toString(rep("&nbsp;", 5))), "NDVI","</html>")
  }
  
  if (indic %in% c("fapar")) {
    df.col <- data.frame(
      cols = brewer.pal(11,"RdYlGn")[2:11], 
      vals = c(seq(0,0.8,0.1), 0.94)
    ) 
    leaflet_titleg <- paste0("<html>", gsub(",","",toString(rep("&nbsp;", 5))), "FAPAR","</html>")
  }
  
  if (indic %in% c("pop309e", "pop108d")) {
    df.col <- data.frame(
      cols = rev(viridis::plasma(7)), 
      vals = quantile(domain, probs = c(0,0.025, 0.05, 0.1, 0.33,0.66, 1))
    ) 
    leaflet_titleg <- paste0("<html>", gsub(",","",toString(rep("&nbsp;", 3))), "No persons","</html>")
  }
  
  # print(head(df.col))
  # print(domain)
  ints <- findInterval(domain, df.col$vals, rightmost.closed = T, left.open = F)
  
  bins <-  df.col$vals[ints[1]:(ints[2] + 1)]
  cols <- df.col$cols[ints[1]:(ints[2])]
  
  # print(bins)
  # print(cols)
  # 
  pal <- colorBin(cols, domain = domain, bins = bins, na.color = "transparent")
  pal2 <- colorBin(cols, domain = domain, bins = bins, reverse = T, na.color = "transparent")
  
  return(list(pal = pal, pal_rev = pal2, tit_leg = leaflet_titleg))
  
}

# indicators_def <- function(indicators) {
#   switch (
#     which(c("heatuspring","heatufall","scorchno","scorchu", "coldu","frostu10", "frostu15","frostu20","prveget", "prfall", "prwinter" ) %in%  indicators),
#     
#     text.desc <- "Cumulative heat units (ΣTmed. > 0°C) in the period 01 February - 10 April",
#     text.desc <- "Cumulative heat units (ΣTmed. > 0°C) in the period 01 September - 31 October",
#     text.desc <- "Scorching heat units (ΣTmax. ≥ 32°C) from 1 June to 31 August",
#     text.desc <- "Scorching heat number of days (Tmax. ≥ 32°C) from 1 June to 31 August",
#     text.desc <- "Cold units (ΣTmed. < 0°C) cumulated during the period 01 November - 31 March",
#     text.desc <- "Frost units (ΣTmin. ≤ -10°C) cumulated in the period 01 December - 28/29 February",
#     text.desc <- "Frost units (ΣTmin. ≤ -15°C) cumulated in the period 01 December - 28/29 February",
#     text.desc <- "Frost units (ΣTmin. ≤ -20°C) cumulated in the period 01 December - 28/29 February",
#     text.desc <- "Precipitatin amounts (l/m²) during the autumn wheat growing season, 01 September to 30 June",
#     text.desc <- "Precipitation amounts (l/m²) during the autumn sowing period, 01 September - 31 October",
#     text.desc <- "Precipitation amounts (l/m²) during the soil water accumulation period, 01 November - 31 March",
#   )
#   return(text.desc)
#   
# }

