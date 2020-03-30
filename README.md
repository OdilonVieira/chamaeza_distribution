# **chamaeza_distribution**

The genus Chamaeza is compose for five species of neotropical birds, where 3 of that have populations in the Atlantic Forest, *C. campanisona*, *C. meruloides* and *C. ruficauda*. In the state of the Rio de Janeiro (Brazil), this species occur in partial simpatry, tending to occur separetadely in specific altitudinals range. My study investigates this pattern, questioning if this is more relate to competitive exclusion or with ecological specialization. Here I expose the scripts used to conduce the experiment.

## **Functions**

### clean_coords(**xy** = tibble-like, **region** = raster::RasterLayer or raster::SpatialPolygonDataFrame, **remove_duplicates** = Logical , **get_centroids** = Logical)

#### **Description**
Get a coordinate dataset, remove duplicated points and also those outside a desire region, and get centroids (case region is a RasterLayer), returning a more geographically distributed dataset.

#### **Arguments**

**xy** - The coordinates dataset; a object capable to be coarsed to a tibble object, with <u>`longitude` and `latitude` in the first and second columns respectively</u>.

**region** - The region where the coordinates should match over; a `raster::RasterLayer` object or a `raster:SpatialPolygonDataFrame` (polygon shapefile).

**remove_duplicates** - Should duplicated values be removed from result? `TRUE` removes, `FALSE` remains those. This argument is affected by the *get_centroids* and *region* arguments, if *get_centroids* is `TRUE` and *region* is a `RasterLayer`, the return value will be the unique values from centroids columns, case *get_centroids* is `FALSE`, the return value will be the unique values from coordinates in *xy*, what also happen if *region* is a `SpatialPolygonDataFrame`.

**get_centroids** - If *region* is a `RasterLayer`, should get the centroids of the cells with occurrence points? `TRUE` gets, `FALSE` ignore.

#### **Result**
A tibble object with two or five columns, depending of the type of the *region* and the choose in *get_centroids*. Returned columns could be, in this order: *cells* (repective cells in the RasterLayer); *long* (longitude); *lat* (latitude); *center.x* (centroid related to longitude) and *center.y* (centroid related to latitude).

### create_distribution(**xy** = tibble-like, **layers** = raster::Raster(Layer, Brick or Stack), **kfold_count** = Integer , **algorithm_name** = Character, **threshold_name** =  Character)

#### **Description**
Create the distribution model, using k-fold cross validation, returning also -dependent and -independent threshold evaluation.

#### **Arguments**

**xy** - A data.frame, matrix or tibble with the occurrence points.

**layers** - The layers of variables to create the model.

**kfold_count** - The number of subgroups to perform a k-fold cross validation, the minimum are 2.

**algorithm_name** - What algorithm to use, options are: "domain","bioclim","mahal","maxent". <u>***In moment, working well only for maxent :(***</u>.

**threshold_name** - One of the dismo::threshold options: "kappa", "spec_sens", "no_omission", "prevalence", "equal_sens_spec", "sensitivity". See help(dismo::threshold) for details.

#### **Result**
A named list with a distribution model (`$model`), a evaluation model (`$evaluation`), a predicted distribution (`$distribution`), a threshold value (`$threshold_value`) and a binary map of occurrence absence based in the threshold (`$threshold_map`).
