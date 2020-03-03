# *** Limpa um conjunto de coordenadas, retornando um conjunto sem duplicátas,  ***
# *** dentro de uma área geogŕafica.                                            ***
# *** Author: Odilon Vieira da Fonseca                                          ***
# *** Date: 01/March/2020                                                       ***

# BIBLIOTÉCAS NECESSÁRIAS:

# responsável por manipular arquivos raster
library("raster")
# responsável por criar conexões (pipes) entre comandos
library("dplyr")
# responsável pela leitura dos arquivos de dados
library("data.table")

# VARIÁVEIS CUJO OS VALORES PODEM SER ALTERADOS:

# caminho para o conjunto (arquivo) de dados:
dataset_url = "registros/ruficauda/coordinates.csv"
# o nome das colunas a serem lidas. Altere o valores, mas manhtena a Longitude e a Latitude na primeira e segunda posição, respectivamente.
cols = c("x","y","alt","cnt","yr","src")
# caminho para o arquivo raster com a área (polígono) onde as coordenadas devem estar sobre 
raster_url = "camadas/Mata Atlântica/biovars/bio_1.tif" 
# shp_url = "shapefile/mata_atlântica/muylaert2018/limite_integrador.shp"
# pasta onde o arquivo de dados deve ser salvo:
save_in = "registros/ruficauda"
# [opcional] Se deseja renomear as colunas no arquivo salvo, mude o valor para um vetor, de mesmo tamanho e ordem que as colunas originais, caso contrário não altere
rename_cols = c("x","y","alt","cnt","yr","src")
# [opcional] Se deseja sobrescrever o arquivo, mude o valor para F ou FALSE:
add = F

# VARIÁVEIS CUJO OS VALORES NÃO PODEM SER ALTERADOS:

# o nome das colunas de Longitude e Latitude
long_col = cols[1]
lat_col = cols[2]
coords_names = c(long_col,lat_col)
# cria simbolos com os nomes das colunas
long_s = as.symbol(long_col)
lat_s = as.symbol(lat_col)

dataset = fread(dataset_url,integer64 = "character") %>%   # * carrega o arquivo de dados, somente as colunas indicadas 
  select(all_of(cols)) %>%
  distinct_at(vars(long_s,lat_s),.keep_all = T) %>%   # * exclui coordenadas duplicadas
  filter(!is.na(!!long_s) & !is.na(!!lat_s))  # * exclui coordenadas em branco
dataset[,c(long_col,lat_col)] <- sapply(dataset[,c(long_col,lat_col)], as.numeric) # força as colunas de coordenadas a serem de tipo numérico

# renomeia as colunas, se for o caso
if(T %in% c(cols != rename_cols) && length(cols) == length(rename_cols)){
  names(dataset) <- rename_cols
  long_col <- rename_cols[1]
  lat_col <- rename_cols[2]
  coords_names <- c(long_col,lat_col)
}

rst = raster(raster_url)  # carrega o arquivo raster

valid_coords_index = extract(rst,dataset[,coords_names],df=T) %>%   # extrai os valores através das coordenadas
  na.exclude() %>%   # remove coordenadas fora da área de interesse, inválidas
  rownames()  # pega o index das coordenadas válidas

# seleciona a porção válida do conjunto de dados, com base nas coordenadas válidas
dataset_over_rst = dataset[valid_coords_index,]

# pega as células que possuem pontos de ocorrência
dataset_cells = cellFromXY(rst,dataset_over_rst[,coords_names])
# pega os centroides das células
dataset_centroides = xyFromCell(rst,dataset_cells)
# insere o centroide no conjunto de dados válidos; pode ser usado para conseguir coordenadas únicas para cada célula
dataset_over_rst <- cbind(dataset_over_rst, centroide=dataset_centroides)
# * salva o resultados em um arquivo .csv, na pasta indicada em "save_in"
fwrite(dataset_over_rst, file=paste(save_in,"coordinates.csv",sep="/"), na='', append = add)

# carrega o arquivo shapefile
#shp = shapefile(shp_url)
# exclui coordenadas que não estão sobre a área indicada no shapefile
# coords_over_shp = SpatialPoints(dataset[,c(long_col,lat_col)], proj4string = CRS(proj4string(shp)))[shp] %>%
  # coordinates() %>%
  # as.data.frame() %>%
  # inner_join(dataset,by=c(long_col,lat_col))

