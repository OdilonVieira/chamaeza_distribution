# *** Author: Odilon Vieira da Fonseca                                          ***
# *** Date: 31/March/2020                                                       ***

library(raster)
library(dplyr)

read_stack = function(directory,pattern="tif"){
  #shortcut to read stacks
  list.files(directory,pattern,full.names = T) %>%
    stack()
}

write_stack = function(s,fn,type="Gtiff",suffix="numbers"){
  #shortcut to write stacks
  writeRaster(s,fn,type,bylayer=T,suffix=suffix)
}

split_raster <- function(r, row, col, na.rm=T){
  #split raster in sub-raster with equal dimensions (row, col)
  
  #aggregate cells by dimension (row, col)
  aggregate(r,c(col,row), na.rm=na.rm) %>%
    #create polygons with the aggregations
    as('SpatialPolygons') %>%
    #use polygons to get raster cuts
    do(
      lapply(seq_along(.), function(i) crop(r,.[i]))
    )
}