# About: This script converts the R data files for GOES-West Coastal Low Clouds to NetCDF files. 
# Author: Pat McCornack
# Date: February 2025


library(ncdf4)
setwd("/Users/patmccornack/Documents/ucsb_fog_project/_repositories/sci-fog-analysis/data/01-raw/geospatial/goes-west-lcl/")
load(file="cldalb_SantaCruz_30min_96to19_120523.rda") ## cloud albedo data, unit percent
load(file="timePDT_chron_30min_96to19_120523.rda") ## time in PST
load(file="lon_SantaCruz_120523.rda") ## lon in degrees
load(file="lat_SantaCruz_120523.rda") ## lat in degrees North

ncpath <- 'cldalb-sci-v2.nc'

# Define dimensions
latdim <- ncdim_def("lat", "degrees_north", lat)
londim <- ncdim_def("lon", "degrees_east", lon)
timedim <- ncdim_def("time", "days since 1970-01-01", timePDT)

# Define variables
fillvalue <- -9999  # Unsure on what this actually is
dlname <- "cloud albedo"
cldalb_def <- ncvar_def("cldalb", "%", list(londim, latdim, timedim),
                        missval=NULL, longname=dlname, prec="float")

# Create netCDF file and put arrays
ncout <- nc_create(ncpath, cldalb_def, force_v4=TRUE)

# Put variables
ncvar_put(ncout, cldalb_def, cldalb)

# Put additional attributes into dimension and data variables
ncatt_put(ncout, "lon", "axis", "X")
ncatt_put(ncout, "lat", "axis", "Y")
ncatt_put(ncout, "time", "axis", "T")

# Add global attribtues
# ! Should probably add metadata about where this came from,
#   what it is, etc.

# Get summary of created file
ncout


nc_close(ncout)


