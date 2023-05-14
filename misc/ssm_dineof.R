library(dplyr)
library(sinkr)
library(raster)
r <- raster("~/Downloads/test.nc")
r <- crop(r, extent(20,30,43,48))
plot(r)



library(terra)
r <- rast("~/Downloads/test.nc", subds = "ssm")
r <- crop(r, ext(20,30,43,48))
plot(r)





system("cdo monmean ssm_ltser_day.nc ssm_ltser_mon.nc")



r <- rast("ssm_ltser_day.nc")
dats.r <- as.Date(names(r) %>% gsub("ssm_days=", "",.) %>% as.integer(), origin = "1970-1-1 00:00:00")
summary(dats.r)

rmean<- app(r, mean, na.rm = T)

r.m <- as.matrix(r)
r.fill <- dineof(r.m, delta.rms = 1e-02)

r.mf <- r.m
r.mf[is.na(r.mf)] <- round(r.fill$Xa[is.na(r.mf)],1)

rf <- r

rf <- setValues(r , r.mf)
rf[is.na(rmean)] <- NA

dats.ssm <- as.Date(names(rf) %>% gsub("SSM_days=", "",.) %>% as.integer(), origin = "1970-1-1 00:00:00")

time(rf) <- dats.ssm 
writeCDF(rf, "ssm_ltser_day_dineof.nc")

system("cdo monmean ssm_ltser_day_dineof.nc ssm_ltser_mon_dineof.nc")

plot(c(r[[1]], rf[[1]]))
time(rf)


rm1 <- rast("ssm_ltser_mon.nc")
rm2 <- rast("ssm_ltser_mon_dineof.nc")


plot(c(rm1[[20]] ,rm2[[20]]))



