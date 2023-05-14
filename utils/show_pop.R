#show raster values on the map
show_pop <- function(x = NULL, y = NULL, rdat = NULL, proxy = NULL, var) {
  cell <- terra::cellFromXY(rdat, cbind(x, y))
  if (!is.na(cell)) {
    xy <- terra::xyFromCell(rdat, cell)
    val = rdat[cell]
    if (!is.na(val)) proxy %>% clearPopups() %>% addPopups(xy[1],xy[2], popup = paste(var, ": ", round(val,1)))
  }
}