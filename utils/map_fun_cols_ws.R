colintRdYlBu <- colorRampPalette(brewer.pal(10,"RdYlBu"),interpolate = "linear")
colintYlGn <- colorRampPalette(brewer.pal(9,"YlGn"),interpolate = "linear")
colintRdYlGn <- colorRampPalette(brewer.pal(11,"RdYlGn"),interpolate = "linear")
cols_temp <- c("#F7FCFD","#EBF4F8","#E0ECF4","#CFDFED","#BFD3E6","#AEC7E0","#9EBCDA","#95A9D0","#8C96C6","#8C80BB", "#8C6BB1", "#8A56A7","#88419D","#0000ff","#0049ff","#0072ff","#00a3ff","#00ccff","#00e5ff","#00ffff","#007700","#009900","#00bb00","#00dd00","#00ff00","#7fff00","#cfff00","#ffff00","#ffe500","#ffcc00","#ffad00","#ff9900","#ff7f00","#FF4E00","#F23A00","#E42700","#D81300","#CB0000","#A62137","#9D3673","#813986","#532B6E")
colint_pres <- colorRampPalette(c("#49234E","#893782","#A25492","#644F92","#326BAA","#5EBCDB","#FFFFFF","#78BF4D","#C4D72C","#EFA633","#E3642F", "#DC3632"))
colint_hurs <- colorRampPalette(brewer.pal(11,"Spectral"),interpolate = "linear")
colint_wind <- colorRampPalette(brewer.pal(9,"PuRd"),interpolate = "linear")
colint_irrad <- colorRampPalette(brewer.pal(9,"YlOrRd"),interpolate = "linear")
colint_trsum <- colorRampPalette(brewer.pal(9,"BuPu"),interpolate = "linear") 

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
  
  if (substr(indic,1,2) %in% c("tm","ts")) { # pentru toate temperaturile
    df.col <- data.frame(
      cols = cols_temp, 
      vals = c(-40,-38,-36,-34,-32,-30,-28,-26,-24,-22,-20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42)							
    ) 
    leaflet_titleg <- paste0("<html>", gsub(",","",toString(rep("&nbsp;", 5))), "°C","</html>")
  }
  
  if (substr(indic,1,2) %in% c("ps")) { # pentru toate temperaturile
    df.col <- data.frame(
      cols = colint_hurs(19), 
      vals = seq(960,1050,5)							
    ) 
    leaflet_titleg <- paste0("<html>", gsub(",","",toString(rep("&nbsp;", 6))), "hPa","</html>")
  }
  
  if (substr(indic,1,2) %in% c("hu")) { # pentru toate temperaturile
    df.col <- data.frame(
      cols = colint_hurs(12), 
      vals = c(seq(0,90,10),95,100)							
    ) 
    leaflet_titleg <- paste0("<html>", gsub(",","",toString(rep("&nbsp;", 4))), "%","</html>")
  }
  
  if (substr(indic,1,2) %in% c("ws")) { # pentru toate temperaturile
    df.col <- data.frame(
      cols = colint_wind(13), 
      vals = c(0,0.5,1,2,3,4,6,8,10,15,20,30,40)						
    ) 
    leaflet_titleg <- paste0("<html>", gsub(",","",toString(rep("&nbsp;", 3))), "m/s","</html>")
  }
  
  if (substr(indic,1,2) %in% c("sh")) { # pentru toate temperaturile
    df.col <- data.frame(
      cols = colint_hurs(15), 
      vals = seq(0,0.7, 0.05)						
    ) 
    leaflet_titleg <- paste0("<html>", gsub(",","",toString(rep("&nbsp;", 5))), "m³/m³","</html>")
  }
  
  
  if (indic %in% c("irrmean_01h")) { # pentru toate temperaturile
    df.col <- data.frame(
      cols = colint_irrad(21), 
      vals = seq(0,1000, 50)						
    ) 
    leaflet_titleg <- paste0("<html>", gsub(",","",toString(rep("&nbsp;", 5))), "W/m²","</html>")
  }
  
  if (indic %in% c("irrmean_24h")) { # pentru toate temperaturile
    df.col <- data.frame(
      cols = colint_irrad(15), 
      vals = seq(0,350, 25)						
    ) 
    leaflet_titleg <- paste0("<html>", gsub(",","",toString(rep("&nbsp;", 5))), "W/m²","</html>")
  }
  
  if (indic  %in% "trsum_01h") { # pentru toate temperaturile
    df.col <- data.frame(
      cols = colint_trsum(12), 
      vals = c(0,0.1,0.2,0.4,0.5,1,5,10,20,30,40,50)						
    ) 
    leaflet_titleg <- paste0("<html>", gsub(",","",toString(rep("&nbsp;", 5))), "l/m²","</html>")
  }
  
  if (indic  %in% "trsum_24h") { # pentru toate temperaturile
    df.col <- data.frame(
      cols = colint_trsum(13), 
      vals = c(0,0.5,1,5,10,20,30,40,50, 75, 100, 125, 150)						
    ) 
    leaflet_titleg <- paste0("<html>", gsub(",","",toString(rep("&nbsp;", 5))), "l/m²","</html>")
  }
  
  if (indic  %in% "co2_flux") { # pentru toate temperaturile
    df.col <- data.frame(
      cols = colint_trsum(13), 
      vals = c(0,0.5,1,5,10,20,30,40,50, 75, 100, 125, 150)						
    ) 
    leaflet_titleg <- paste0("<html>", gsub(",","",toString(rep("&nbsp;", 5))), "l/m²","</html>")
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
  
  return(list(pal = pal, pal_rev = pal2, tit_leg = leaflet_titleg, minmax = range(df.col$vals)))
  
}




