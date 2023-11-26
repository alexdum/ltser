mapa_fun_cols_ec <- function(indic = NA,  domain = NA, title = NA, nbins) {

  
  
  if (indic  %in% c("co2_flux", "ch4_flux", "LE","H", "RN_1_1_1", "RH_1_1_1","ET", "PPFD_1_1_1")) { # pentru toate temperaturile
   
    pal <- colorBin(palette = "BuPu",domain = domain, bins = nbins)
    pal2 <- colorBin(palette = "BuPu",domain = domain, reverse = T, bins = nbins)
    leaflet_titleg <- paste0("<html>", gsub(",","",toString(rep("&nbsp;", 2))), title,"</html>")
    
  }
  
  
  return(list(pal = pal, pal_rev = pal2, tit_leg = leaflet_titleg))
  
}




