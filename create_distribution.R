# *** Cria o modelo de distribuição, baseado em pontos de ocorrência e camadas de variáveis.  ***
# *** Author: Odilon Vieira da Fonseca                                          ***
# *** Date: 03/March/2020                                                       ***

# responsável por criar conexões (pipes) entre comandos
library("dplyr")
# responsável pela leitura dos arquivos de dados
library("data.table")
# responsável por criar o modelo de distribuição
library("dismo")

occurrences_url = "~/Documentos/chamaezaR/registros/meruloides/coordinates.csv"
variables_url = "~/Documentos/chamaezaR/camadas/Mata Atlântica/biovars"
lat_col = "y"
long_col = "x"
kfold_count = 20
algorithm_name = "maxent"
threshold_name = "spec_sens"
save_in = "~/Documentos/chamaeza_distribution"
rasters_format = "GTiff"

# carrega os pontos de ocorrência, assumindo que não são duplicados, e estão dentro da área de interesse
occurrences = fread(occurrences_url,select=c(long_col,lat_col))
# carrega todos os arquivos raster na pasta de variáveis
variables = list.files(variables_url,full.names = T) %>%
  stack()
# cria subgrupos no conjunto de pontos de ocorrência
kfolds = kfold(occurrences,kfold_count)
# determina aleatóriamente qual será o subgrupo de teste
test = sample(kfold_count,1)
# determina o subgrupo de teste
test_group = occurrences[kfolds == test,]
# determina o grupo de treino, que são os pontos de ocorrência que não estão no grupo de teste
train_group = occurrences[kfolds != test,]
# cria os pontos de pseudo-ausência [é utilizado pelo MaxEnt]
bg_points = randomPoints(variables,nrow(occurrences))
# cria subgrupos no conjunto de pontos de pseudo-ausência
bg_kfolds = kfold(bg_points,kfold_count)
# determina aleatóriamente qual será o subgrupo de pseudo-ausências para teste
bg_test = sample(kfold_count,1)
# determina o grupo de pseudo-ausências para teste
bg_test_group = bg_points[bg_kfolds == bg_test,]
# determina o grupo de pseudo-ausências para treino
bg_train_group = bg_points[bg_kfolds != bg_test,]
# determina qual algoritmo será utilizado
algorithm = switch (algorithm_name,
  "maxent" = maxent,
  "bioclim" = bioclim,
  "domain" = domain,
  "mahal" = mahal
)
# ****** SLOW AREA *****
beginCluster(type="SOCK")
#cria o modelo de distribuição
model = algorithm(variables,p=as.matrix(train_group),a=bg_train_group)
# avalia o modelo gerado
validate = evaluate(model,p=test_group,x=variables,a=bg_test_group)
# cria o mapa de distribuição
distribution = clusterR(variables,raster::predict,args=list(model=model), verbose=T)
endCluster()
# **********************

# pega um valor de corte especifico
threshold_values = threshold(validate)
# cria o mapa binário (presença, ausência), baseado no valor de corte
binary_map = distribution >= threshold_values[,threshold_name]
# move os resultados do modelo de distribuição para a pasta especificada
file.copy(model@path,save_in,recursive = T)
# renomeia a pasta com os resultados
file.rename(file.path(save_in,basename(model@path)),file.path(save_in,"model_results"))
# cria (ou não) o diretório onde salvar os arquivos raster
rasters_dir = file.path(save_in,"model_results","rasters")
dir.create(rasters_dir)
# salva o mapa de distribuição, como raster
writeRaster(distribution,file.path(rasters_dir,"distribution_map"),format=rasters_format)
# salva o mapa binário de distribuição, como raster
writeRaster(binary_map,file.path(rasters_dir,"binary_map"),format=rasters_format)
# write(validate,file.path(save_in,"validation.txt"))
