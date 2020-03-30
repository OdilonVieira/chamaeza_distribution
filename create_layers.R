# *** Author: Odilon Vieira da Fonseca                                  ***
# *** Date: 30/March/2020                                            ***

cut_raster = function(r,m){
  require(raster)
  r %>%
    #cut by the extent
    crop(m) %>%
    #cut by the polygon shape
    mask(m)
}

create_layers <- function(prec,tmin,tmax,m){
  # function to create biovars on a layer cut
  require(dismo)
  # cut layers by the mask
  prec = cut_raster(prec,m)
  tmin = cut_raster(tmin,m)
  tmax = cut_raster(tmax,m)
  # create biovars
  biovars(prec,tmin,tmax)
}


