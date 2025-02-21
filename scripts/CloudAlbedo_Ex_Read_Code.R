#### This file was made by Rachel Clemesha (rclemesha@ucsd.edu) April 2019
#### Example R code to read in the new 1km satellite-derived cloud albedo record for San Clemente Island
#### Please email me with any questions

#### load libraries
library("chron")  ## The time file is stored as a chron object. if you don't have the chron library, install one using this line: install.packages("chron")


####load in data files  (set paths for your own file organization, use setwd() and getwd()) 
setwd('/Users/patmccornack/Documents/ucsb_fog_project/_repositories/sci-fog-analysis/data/01-raw/geospatial/goes-west-lcl')
load(file="cldalb_SantaCruz_30min_96to19_120523.rda") ## cloud albedo data, unit percent

load(file="timePDT_chron_30min_96to19_120523.rda") ## time in PST
load(file="lon_SantaCruz_120523.rda") ## lon in degrees
load(file="lat_SantaCruz_120523.rda") ## lat in degrees North


#### view properties of objects 
dim(cldalb) ## dims of cloud albedo are lon X lat X time, dim 61 X 61 X 85932

length(timePDT)  ## time length  85932
range(timePDT) ## from May 1 1996 to Sep 30, 2018 (daytime, May through Sep) 

length(lon)   ## lon length  61
range(lon) ## -118.8 to -118.2
unique(diff(lon))  ## by 0.01 degree 

length(lat) ## lat length  61
range(lat) ## 32.6 to 33.2
unique(diff(lat))  ## by 0.01 degree 


####################################################
#### A map of any given time 
####################################################
library("fields") ## I use this package for creating maps, this does not need to be installed if you map otherwise, but I use it for this example
i <- 1
outdir <- '/Users/patmccornack/Documents/ucsb_fog_project/_repositories/sci-fog-analysis/outputs/lcl-plots/R-albedo-plots'
for (day in 1:30) {
  for (hour in 9:18) {
    fpath <- file.path(outdir, paste0("R-albedo-", i, ".png"))
    
    png(file=fpath)
      cl <-   read.table("NOAA_CoastLine_102913.dat") ### This is the coastline I use for this example
      ti <- which(years(timePDT)==2008&months(timePDT)=="Aug"&days(timePDT)==day&hours(timePDT)==hour&minutes(timePDT)==0) ### Example of July 4, 2015 at 11:00 PST
      image.plot(lon,lat,cldalb[,,ti],main=paste("cloud albedo (%)", timePDT[ti]))
      lines(cl) ## show coastline 
      contour(lon,lat,cldalb[,,ti],add=TRUE,col="gray",levels=15.5) ## Cloud albedo below ~15.5% should be considered clear  
      i <- i+1
    dev.off()
  }
}


####################################################
### Extract full time series of a location of interest 
####################################################
NROlat <- 32.996   ### using location of NRO  
NROlon <- -118.553 

#### find the grid cells surronding the location of interest 
loni <- order(abs(lon-NROlon))[1:2] 
lati <- order(abs(lat-NROlat))[1:2]

lon[loni];lat[lati]

ts <- apply(cldalb[loni,lati,],c(3),mean) ### take the average of the 4 surronding grid cells 
length(ts)== length(timePDT)#### full record of 85932 time step

####### plot an example day from the full time series  
dayi <- which(years(timePDT)==2015&months(timePDT)=="Jul"&days(timePDT)==4) ### Example of July 4, 2015 at 11:00 PST
plot(timePDT[dayi],ts[dayi],type="b",xlab="July 4, 2015",main="Location: NRO ",ylab="cloud albedo (%)")

#### This time series could then be written to a .csv file for example by:
write.csv(ts,file="cldalb_NRO.csv",row.names=as.character(timePDT))


############ view above locations with zoom in of  previous map 
image.plot(lon,lat,cldalb[,,ti],main=paste("cloud albedo (%)", timePDT[ti]),xlim=c(-118.62,-118.5),ylim=c(32.95,33.05))
lines(cl) ## show coastline 
contour(lon,lat,cldalb[,,ti],add=TRUE,col="gray",levels=15.5) ## Cloud albedo below ~15.5% should be considered clear  

points(lon[loni[c(1,1,2,2)]],lat[lati[c(1,2,1,2)]] ) #### closet grid cells 
points(NROlon,NROlat,pch=3,cex=3) ### NRO location 
legend("topright",pch=c(3,1),legend=c("NRO","Grid Cell Center"))

      
