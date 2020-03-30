library(dismo)
library(dplyr)
library(tibble)
library(doParallel)

split_raster <- function(r, row, col, na.rm=T){
  a = aggregate(r,c(col,row), na.rm=na.rm)
  p = as(a,'SpatialPolygons')
  lapply(seq_along(p), function(i) crop(r,p[i]))
}

pca_stack <- function(layers,pca_axes=1:4,split_row=NULL,split_col=NULL,filename=NULL){
  #cria um cluster (multiprocessamento)
  cores=detectCores()-1
  cl = makeCluster(cores)
  registerDoParallel(cl)
  #divide as camadas em sub camadas, se necessário
  if(is.numeric(split_row) && is.numeric(split_col)){
    layers = split_raster(layers,split_row,split_col) 
  }else{
    layers = list(layers)
  }
  #variável onde os resultados da pca são guardados
  pca_list = list()
  #cria o raster com os scores da PCA
  pca_raster <- foreach(r=iter(layers),.packages = c("dplyr","tibble","raster"), .combine = merge) %do% {
    #extrai os valores das camadas, dentro de uma sub região, excluindo valores em branco, preservando os indexes
    values = getValues(r) %>%
      as_tibble() %>%
      rownames_to_column() %>%
      filter_all(all_vars(!is.na(.)))
    #extrai os números das células que não contém valores em branco
    cells_numbers = as.numeric(values$rowname)
    values$rowname <- NULL
    #normaliza os valores,faz a PCA com os valores normalizados
    pca = princomp(x=scale(values))
    #extrai a porcentagem de importância dos eixos (determinados por 'pca_axes') da PCA
    axes_importance = (pca$sdev^2/sum(pca$sdev^2))[pca_axes]
    #salva os resultados da PCA 
    pca_list = rbind(pca_list,c(princomp=pca, axes_importance = axes_importance, accumulate_importance=sum(axes_importance)))
    #cria uma pilha de rasters vazios
    brick_model = brick(extent(r),ncol=ncol(r), nrow=nrow(r), crs=crs(r), nl=length(pca_axes))
    #rasteriza os scores
    rasterize(xyFromCell(brick_model,cells_numbers),brick_model,pca$scores[,pca_axes])
  }
  #finaliza o cluster
  stopCluster(cl)
  #exporta os resultados
  list(
    pca = pca_list,
    rasters = pca_raster
  )
}
