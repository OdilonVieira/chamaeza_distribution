# *** Author: Odilon Vieira da Fonseca                                          ***
# *** Date: 31/March/2020                                                       ***

pca_stack <- function(layers,axes=1:4,scale_=T){
  #create a raster stack with the scores axes of a PCA
  
  #requiriments
  require(raster)
  require(dplyr)
  require(tibble)
  # require(doParallel) apparently is not working, still slow
  
  #create a cluster
  # cores=detectCores()-1
  # cl = makeCluster(cores)
  # registerDoParallel(cl)
  
  #extract layers values
  values = getValues(layers) %>%
    #transform in tibble
    as_tibble() %>%
    #get the row names (cells indexes)
    rownames_to_column() %>%
    #change to numeric indexes
    mutate(rowname=as.numeric(rowname)) %>%
    #remove NA values
    filter_all(all_vars(!is.na(.)))
  #saves the cells indexes
  cells_numbers = values$rowname
  #remove indexes from the values tibble
  pca = select(values,-rowname) %>%
    #scale values, if necessary
    do(if(scale_) as_tibble(scale(.)) else .) %>%
    #do the PCA
    princomp(cor=F)
  #save PCA results
  pca_list = list(princomp=pca, axes_importance = summary(pca))
  #create the raster for the PCA axes scores
  brick_ = brick(extent(layers),ncol=ncol(layers), nrow=nrow(layers), crs=crs(layers), nl=length(axes))
  #rasterize selected axes
  pca_raster = rasterize(xyFromCell(brick_,cells_numbers),brick_,pca$scores[,axes])
  #ends cluster
  # stopCluster(cl)
  #export results
  list(
    pca = pca_list,
    rasters = pca_raster
  )
}

