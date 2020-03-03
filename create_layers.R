# *** Cria as variáveis bioclimáticas, dentro de um recorte específico, ***
# *** a partir de dados mensais do WorldClim.                           ***
# *** Author: Odilon Vieira da Fonseca                                  ***
# *** Date: 22/February/2020                                            ***

# BIBLIOTÉCAS NECESSÁRIAS:

library("dismo")
library("dplyr")

# VARIÁVEIS CUJO OS VALORES PODEM SER ALTERADOS:

# diretório das camadas mensais de temperatura máxima
tmax_dir = "~/Downloads/camadas_worldclim2/temperatura_máxima_30s"
# diretório das camadas mensais de temperatura mínima
tmin_dir = "~/Downloads/camadas_worldclim2/temperatura_mínima_30s"
# diretório das camadas mensais de precipitação
prec_dir = "~/Downloads/camadas_worldclim2/precipitação_30s"
# formato (extensão) das camadas mensais
clim_format = "tif"
# URL do shapefile que será utilizado para recortar as camadas
shapefile_url = "~/Documentos/chamaezaR/shapefile/RJ/rj.shp" 
# tipo de arquivo em que as camadas recortadas devem ser salvas, mais opções em: writeFormats()
cuts_format = "GTiff"
# tipo de arquivo em que as variáveis climáticas devem ser salvas, mais opções em: writeFormats()
biovars_format = "GTiff"
# diretório onde as camadas devem ser salvas
save_in = "~/Documentos/chamaezaR/camadas/"

# FUNÇÕES NECESSÁRIAS:

read_rasters = function(directory,pattern="tif"){
  # lê as camadas de variáveis
  list.files(directory,pattern,full.names = T) %>%
    stack()
}
cut_raster = function(r,ext){
  # faz o recorte das camadas de variáveis
  r %>%
    crop(ext) %>%
    mask(ext)
}
make_dir = function(dir_name,base_name){
  # confere se o diretório passado é válido, se necessário, o cria. 
  d = paste(dir_name,base_name,sep = "/")
  if(!dir.exists(d)){
    dir.create(d)
  }
  d
}

# VARIÁVEIS QUE NÃO PODEM SER ALTERADAS:

# carrega as camadas de variáveis mensais
tmax = read_rasters(tmax_dir,clim_format)
tmin = read_rasters(tmin_dir,clim_format)
prec = read_rasters(prec_dir,clim_format)

# carrega o arquivo shapefile
shp = shapefile(shapefile_url)

# faz o recorte das camadas
tmax_cutted = cut_raster(tmax,shp)
tmin_cutted = cut_raster(tmin,shp)
prec_cutted = cut_raster(prec,shp)

# cria, se necessário, os diretórios onde as camadas de recortes serão salvas
save_cuts_in = make_dir(save_in,"mvars")
save_tmax_in = make_dir(save_cuts_in,"tmax")
save_tmin_in = make_dir(save_cuts_in,"tmin")
save_prec_in = make_dir(save_cuts_in,"prec")
#salva os recortes
writeRaster(tmax_cutted,save_tmax_in,format=cuts_format,bylayer=T,suffix="numbers")
writeRaster(tmin_cutted,save_tmin_in,format=cuts_format,bylayer=T,suffix="numbers")
writeRaster(prec_cutted,save_prec_in,format=cuts_format,bylayer=T,suffix="numbers")

# cria, se necessário, o diretório onde as camadas de variáveis climáticas serão salvas
save_biovars_in = make_dir(save_in,"biovars")
#cria e salva as variáveis climáticas
biovars(prec_cutted,tmin_cutted,tmax_cutted) %>%
  writeRaster(paste(save_biovars_in,"bio",sep="/"),format=biovars_format,bylayer=T,suffix="numbers")