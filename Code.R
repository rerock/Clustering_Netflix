setwd("/Users/Wen/Dropbox/MIT/files")
#load the data into R
movies = read.table("movie.txt", header=FALSE, sep="|",quote="\"")

str(movies)

# Add column names
colnames(movies) = c("ID", "Title", "ReleaseDate", "VideoReleaseDate", "IMDB", "Unknown", "Action", "Adventure", "Animation", "Childrens", "Comedy", "Crime", "Documentary", "Drama", "Fantasy", "FilmNoir", "Horror", "Musical", "Mystery", "Romance", "SciFi", "Thriller", "War", "Western")

str(movies)

# Remove unnecessary variables
movies$ID = NULL
movies$ReleaseDate = NULL
movies$VideoReleaseDate = NULL
movies$IMDB = NULL

# Remove duplicates
movies = unique(movies)

# Take a look at the data again:
str(movies)
summary(movies)

# Compute distances
distances = dist(movies[2:20], method = "euclidean")

# Hierarchical clustering, the ward method cares about the distance between clusters using centroid distance, and also the variance in each cluster
clusterMovies = hclust(distances, method = "ward") 

# Plot the dendrogram
plot(clusterMovies)

# Assign points to clusters
clusterGroups = cutree(clusterMovies, k = 10)


# Use the tapply function to compute the percentage of movies in each genre and cluster
tapply(movies$Action, clusterGroups, mean)
tapply(movies$Romance, clusterGroups, mean)

# repeat this for each genre

# Find which cluster Men in Black is in.

subset(movies, Title=="Men in Black (1997)")
clusterGroups[257]

# Create a new data set with just the movies from cluster 2
cluster2 = subset(movies, clusterGroups==2)

# Look at the first 10 titles in this cluster:
cluster2$Title[1:10]

########################################################################K mean clustering 
# Specify number of clusters
k =10

# Run k-means
set.seed(1000)
KMC = kmeans(movies[-1], centers = k, iter.max = 1000)

# Assign observations to clusters
cluster = KMC$cluster

# Extract clusters
table(KMC$cluster)
kcluster = split (movies[-1],KMC$cluster)
for (i in 1:10)
{
  cat(i, sep = "\n\n")
  print(tail(sort(colMeans(kcluster[[i]]))))
}

# Find which cluster Men in Black is in
subset(movies, Title=="Men in Black (1997)")  ## [1] The 257 observation 
cluster[257]    ## [1] cluster 7
origin_k_cluster = split(movies, KMC$cluster)
(origin_k_cluster[[7]]$Title)[1:10]

#########################################################comparing the clusters between two algorithms
table(clusterGroups,KMC$cluster)


#######################################################Cluster- then -predict future stock prices 
setwd("/Users/Wen/Dropbox/MIT/files")
stocks = read.csv ("StocksCluster.csv", header = T)
str(stocks)

a = table(stocks$PositiveDec)
a[2]/sum(a)

cor(stocks)
sort(as.vector(cor(stocks)[1:11,1:11]))

b = rep(0,11)
for (i in 1:11)
{
  b[i]=mean(stocks[,i])
}

which(b==max(b))
which(b==min(b))


####################################################################Logistic Regression Model
library(caTools)
set.seed(144)
spl = sample.split(stocks$PositiveDec,SplitRatio = 0.7)
stocksTrain = subset(stocks, spl==T)
stockTest = subset(stocks, spl==F)

StocksModel = glm(stocksTrain$PositiveDec ~., data = stocksTrain, family = binomial)

# Make predictions on training set
predictModel = predict(StocksModel,type="response")

# Analyze predictions
summary(predictModel)
tapply(predictModel, stocksTrain$PositiveDec, mean)

# Confusion matrix for threshold of 0.5
a=table(stocksTrain$PositiveDec, predictModel>0.5)
sum(diag(a))/sum(a)

# Make predictions on testing set
predictTest = predict(StocksModel, type="response", newdata=stockTest)

# Confusion matrix for threshold of 0.5
a=table(stockTest$PositiveDec, predictTest > 0.5)
accuracy=sum(diag(a))/sum(a)
accuracy

a=table(stockTest$PositiveDec)
a[2]/sum(a)

###########################################################################K-means Clustering

# Remove the dependent variable, In cluster-then-predict, the goal is to predict the dependent variable, which is unknown at the time of prediction
limitedTrain = stocksTrain
limitedTrain$PositiveDec = NULL

limitedTest = stockTest
limitedTest$PositiveDec = NULL

summary(limitedTrain)
summary(limitedTest)

# Normalized the data
library(caret)
preproc = preProcess(limitedTrain)
normTrain = predict(preproc,limitedTrain)
normTest = predict(preproc,limitedTest)
summary(normTrain)
summary(normTest)

# Decide the number of clusters for K-means clustering
k = 3

# Run K-means
set.seed(144)
km = kmeans(normTrain, centers =k)
str(km)

# Assign the observations to different clusters
table(km$cluster)

library(flexclust)
km.kcca = as.kcca(km, normTrain)
clusterTrain = predict(km.kcca)
clusterTest = predict(km.kcca, newdata = normTest)

table(clusterTest)

db_Train_Cluster = split(stocksTrain,clusterTrain)
db_Test_Cluster = split(stockTest,clusterTest)

tapply(stocksTrain$PositiveDec,clusterTrain,mean)

##################################################################Cluster-Specific Predictions

StockModel1 = glm(PositiveDec ~., data = db_Train_Cluster[[1]], family = binomial )
StockModel2 = glm(PositiveDec ~., data = db_Train_Cluster[[2]], family = binomial )
StockModel3 = glm(PositiveDec ~., data = db_Train_Cluster[[3]], family = binomial )

S = NULL
for (i in 1:3)
{
  S[[i]] = glm(PositiveDec ~., data = db_Train_Cluster[[i]], family = binomial )
}


a = NULL
for (i in 1:3)
{
  a[[i]] = as.vector(coefficients(S[[i]]))
}


b = cbind(a[[1]],a[[2]],a[[3]], seq(1,12))

apply(b,1,function(x) min(x[1:3]))<0 
apply(b,1,function(x) max(x[1:3]))>0
apply(b,1,function(x) min(x[1:3]))<0 & apply(b,1,function(x) max(x[1:3]))>0
subset(b, apply(b,1,function(x) min(x[1:3]))<0 & apply(b,1,function(x) max(x[1:3]))>0)

PredictTest = NULL
Table = NULL
Accuracy = NULL

for (i in 1:3)
{
  PredictTest[[i]] = predict(S[[i]], newdata = db_Test_Cluster[[i]], type = "response")
  Table[[i]] = table(db_Test_Cluster[[i]]$PositiveDec,PredictTest[[i]]>0.5)
  Accuracy[[i]] = sum(diag(Table[[i]]))/sum(Table[[i]]) 
}
Accuracy

AllPredictions = c(PredictTest[[1]], PredictTest[[2]], PredictTest[[3]])
AllOutcomes = c(db_Test_Cluster[[1]]$PositiveDec,db_Test_Cluster[[2]]$PositiveDec,db_Test_Cluster[[3]]$PositiveDec)

a = table(AllPredictions>0.5, AllOutcomes)
Accuracy = sum(diag(a))/sum(a)
Accuracy


