import xarray as xr

def extract_point(fname, lon, lat, variable):
  ds = xr.open_dataset(fname)
  ds.close()
  dsloc = ds.sel(lon=lon,lat=lat,method='nearest')
  data = dsloc[variable].to_pandas().round(1)
  return(data)

