##################################################
# Date: 02/19/25
# Author: Pat McCornack
#
# Purpose: This script extracts cloud albedo values from Rachel Clemesha's GOES-derived coastal low clouds
#          dataset for a given set of site coordinates provided in a csv file. 
#
##################################################



import os
from pathlib import Path
import numpy as np
import pandas as pd

import matplotlib.pyplot as plt

import netCDF4 as nc
import xarray as xr

# Define file paths
root_dir = Path().resolve().parents[0]
data_dir = root_dir / "data"
ds_fpath = data_dir / "01-raw" / "geospatial" / "goes-west-lcl" / "cldalb-sci.nc"
site_fpath = data_dir / "01-raw" / "sci-stations.csv"

out_fpath = data_dir / "02-clean" / "sites-clc.csv"

# Load data
ds = xr.open_dataset(ds_fpath)
site_meta = pd.read_csv(site_fpath)

# Extract LCL for each site
lcl_df = pd.DataFrame()
for i, row in site_meta.iterrows():
    latitude = row['latitude']
    longitude = row['longitude']

    site_lcl = ds.sel(lat=latitude, lon=longitude, method='nearest')
    site_df = site_lcl.to_dataframe()[['cldalb']].reset_index()
    site_df['time-PDT'] = site_df['time'].dt.ceil('30min') 
    site_df['site'] = row['station']

    lcl_df = pd.concat([lcl_df, site_df], axis=0)

lcl_df.drop('time', axis=1, inplace=True)  # Drop UTC time

# Create binary cloud variable using Clemesha's suggested threshold
lcl_df['cld-binary'] = lcl_df['cldalb'].apply(lambda x : 1 if x > 8.5 else 0)

lcl_df.to_csv(out_fpath)
print(out_fpath)


