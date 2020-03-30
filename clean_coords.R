# *** Author: Odilon Vieira da Fonseca                                          ***
# *** Date: 30/March/2020                                                       ***

clean_coords <- function(xy,region,remove_duplicates=F,get_centroids=F){
  # Function to 'clean' a coordinates dataset, removing points outside the desire region,
  # duplicates and getting centroids (case region is a RasterLayer).
  
  # Requirements
  require("raster")
  require("dplyr")
  
  # transform the dataset in a tibble
  xy = as_tibble(xy) %>%
    # get only the firts two columns of xy data,
    # assuming that they are longitude and latitude values respectively
    select(c(1,2)) %>%
    # rename columns
    rename(long=1,lat=2)
  #if region is a RasterLayer
  if(is(region,"RasterLayer")){
    #create a symbol with the layer name
    r_name = as.symbol(names(region))
    # the columns that should be unique
    distinct_by = if(get_centroids) c("center.x","center.y") else c("long","lat")
    # extract the layer values by the xy data
    extract(region,xy,cellnumbers=T) %>%   
      # transform in tibble
      as_tibble() %>% 
      # transform 'cells' column in a numeric column
      mutate(cells=as.numeric(cells)) %>% 
      # append the xy data
      bind_cols(xy) %>% 
      # remove NA values (points out the layer)
      filter(!is.na(!! r_name)) %>% 
      # remove the extract column
      select(-!! r_name) %>%
      # get the centroids
      do(if(get_centroids) bind_cols(.,as_tibble(xyFromCell(region, .$cells))) else .) %>% 
      # rename centroids columns
      do(if(get_centroids) rename(., center.x=x, center.y=y) else .) %>% 
      # remove duplicates
      do(if(remove_duplicates) distinct_at(., vars(!!distinct_by), .keep_all=T) else .)
  }
  # if region is a SpatialPolygonDataFrame (shapefile)
  else if(is(region,"SpatialPolygonsDataFrame")){
    # project coordinates on the region
    SpatialPoints(xy, proj4string = CRS(proj4string(region)))[region] %>%
      # get coordinates inside the region
      coordinates() %>%
      # transform in tibble
      as_tibble() %>%
      # remove duplicates
      do(if(remove_duplicates) distinct(.) else .)
  }else{
    warning(paste("Incorrect type, 'region' must be a RasterLayer or a SpatialPolygonDataFrame object, not",typeof(region)))
  }
}
