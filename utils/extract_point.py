import xarray as xr
import pandas as pd

def extract_point(fname, lon, lat, variable):
  ds = xr.open_dataset(fname)
  ds.close()
  dsloc = ds.sel(lon=lon,lat=lat,method='nearest')
  data = dsloc[variable].to_pandas().round(1)
  if isinstance(data.index, pd.DatetimeIndex):
    idx = data.index.strftime('%Y-%m-%d')
  else:
    idx = data.index.map(str)
  return dict(zip(idx, data.values))

