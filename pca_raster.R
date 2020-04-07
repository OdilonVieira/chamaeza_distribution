# *** Author: Odilon Vieira da Fonseca                                          ***
# *** Date: 07/April/2020                                                       ***

choose_axes <- function(eigenvalues,method="brokenstick"){
  importance = 100*eigenvalues/sum(eigenvalues)
  if(method == "brokenstick"){ 
    # Broken stick aproach
    n = length(eigenvalues)
    model = data.frame(j=seq(1:n), p=0)
    model$p[1] <- 1/n
    for(i in 2:n) model$p[i] = model$p[i-1] + (1/(n+1-i))
    model$p = 100 * model$p / n
    expected_importance = model$p[n:1]
    tb = rbind(importance,expected_importance)
    barplot(tb, beside=T)
    which(importance >= expected_importance)
  }else if(method == "mean"){
    # Kaiser-Guttman aproach
    which(importance >= mean(eigenvalues))
  }else{
    warning("Invalid method, choose between 'brokenstick' or 'mean'.")
  }
}

pca_stack <- function(layers,choose_="brokenstick",scale_=T){
  #create a raster stack with the scores axes of a PCA
  
  #requiriments
  require(raster)
  require(dplyr)
  require(tibble)
  
  #extract layers values
  values = getValues(layers) %>%
    #transform in tibble
    dplyr::as_tibble() %>%
    #get the row names (cells indexes)
    tibble::rownames_to_column() %>%
    #change to numeric indexes
    dplyr::mutate(rowname=as.numeric(rowname)) %>%
    #remove NA values
    dplyr::filter_all(dplyr::all_vars(!is.na(.)))
  #saves the cells indexes
  cells_numbers = values$rowname
  #remove indexes from the values tibble
  pca = dplyr::select(values,-rowname) %>%
    #scale values, if necessary
    dplyr::do(if(scale_) as_tibble(scale(.)) else .) %>%
    #do the PCA
    princomp(cor=F)
  #save PCA results
  pca_list = list(princomp=pca, axes_importance = summary(pca))
  # choose pca axes
  if(is.numeric(choose_)){
    axes = choose_
  }else if(choose_ == "brokenstick" || choose_ == "mean"){
    axes = choose_axes(pca$sdev^2, choose_) 
  }else{
    warning("Invalid 'choose_' value, pass a number, a numeric vector, or 'brokenstick' and 'mean' string")
    axes = F  
  }
  
  if(is.numeric(axes)){
    #create the raster for the PCA axes scores
    brick_ = brick(extent(layers),ncol=ncol(layers), nrow=nrow(layers), crs=crs(layers), nl=length(axes))
    #rasterize selected axes
    pca_raster = rasterize(xyFromCell(brick_,cells_numbers),brick_,pca$scores[,axes])
    #export results
    list(
      pca = pca_list,
      rasters = pca_raster
    )
  }
}

