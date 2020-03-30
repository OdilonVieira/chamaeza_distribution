# chamaeza_distribution
Scripts utilizados no estudo da distribuição do gênero Chamaeza no estado do Rio de Janeiro, e na Mata Atlântica.

### clean_coords(**xy** = tibble-like, **region** = raster::RasterLayer or raster::SpatialPolygonDataFrame, **remove_duplicates** = Logical , **get_centroids** = Logical)

#### **Description**
Get a coordinate dataset, remove duplicated points and also those outside a desire region, and get centroids (case region is a RasterLayer), returning a more geographically distributed dataset.

#### **Arguments**

**xy** - The coordinates dataset; a object capable to be coarsed to a tibble object, with `longitude` and `latitude` in the first and second columns respectively.

**region** - The region where the coordinates should match over; a `raster::RasterLayer` object or a `raster:SpatialPolygonDataFrame` (polygon shapefile).

**remove_duplicates** - Should duplicated values be removed from result? `TRUE` removes, `FALSE` remains those. This argument is affected by the *get_centroids* and *region* arguments, if *get_centroids* is `TRUE` and *region* is a `RasterLayer`, the return value will be the unique values from centroids columns, case *get_centroids* is `FALSE`, the return value will be the unique values from coordinates in *xy*, what also happen if *region* is a `SpatialPolygonDataFrame`.

**get_centroids** - If *region* is a `RasterLayer`, should get the centroids of the cells with occurrence points? `TRUE` gets, `FALSE` ignore.

#### **Result**
A tibble object with two or five columns, depending of the type of the *region* and the choose in *get_centroids*. Returned columns could be, in this order: *cells* (repective cells in the RasterLayer); *long* (longitude); *lat* (latitude); *center.x* (centroid related to longitude) and *center.y* (centroid related to latitude).


