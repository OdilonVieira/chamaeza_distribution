# *** Author: Odilon Vieira da Fonseca                                          ***
# *** Date: 30/March/2020                                                       ***

create_distribution = function(xy,layers,kfold_count=2,algorithm_name="maxent",threshold_name="kappa"){
  #Create the distribution model, using k-fold cross validation, 
  #returning also -dependent and -independent threshold evaluation
  library("dplyr")
  library("dismo")
  library("doParallel")
  
  # the algorithm to use
  algorithm = switch (algorithm_name,
                      "domain" = dismo::domain,
                      "bioclim" = dismo::bioclim,
                      "mahal" = dismo::mahal,
                      "maxent" = dismo::maxent
  )
  # force use two or more kfolds
  kfold_count = ifelse(is.numeric(kfold_count) && kfold_count > 1, kfold_count, 2)
  # create folds with the occurrence points
  kfolds = kfold(xy,kfold_count)
  # take, randomly, the test group
  test = sample(kfold_count,1)
  test_group = xy[kfolds == test,]
  # take the train group
  train_group = xy[kfolds != test,]
  # create the background points (only used by MaxEnt)
  bg_points = randomPoints(layers,nrow(xy))
  # create folds with the background points
  bg_kfolds = kfold(bg_points,kfold_count)
  # take, randomly, the background test group
  bg_test = sample(kfold_count,1)
  bg_test_group = bg_points[bg_kfolds == bg_test,]
  # take the background train group
  bg_train_group = bg_points[bg_kfolds != bg_test,]
  # create a cluster
  beginCluster(type = "SOCK")
  #create the distribution model
  model = algorithm(layers,p=as.matrix(train_group),a=bg_train_group) # Working well only for MaxEnt
  # validate the model
  validate = evaluate(model,p=test_group,x=layers,a=bg_test_group)
  # project distribution in the layers
  distribution = clusterR(layers,raster::predict,args=list(model=model),verbose=T)
  # ends the cluster
  endCluster()
  # get the threshold
  threshold_value = threshold(validate, threshold_name)
  #export results
  list(
    model = model,
    evaluation = validate,
    distribution = distribution,
    threshold_value = threshold_value,
    # create the binary map, based in the threshold
    threshold_map = distribution >= threshold_value
  )
}
