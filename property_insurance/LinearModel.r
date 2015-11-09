#read in all the input data
X.test <- read.csv("/Users/bikas/Desktop/kaggle_competitions/property_insurance/test.csv")
X <- read.csv("/Users/bikas/Desktop/kaggle_competitions/property_insurance/train.csv")


# extract id
id.test <- X.test$Id
X.test$Id <- NULL
X$Id <- NULL
n <- nrow(X)

# extarct target
y <- X$Hazard
X$Hazard <- NULL

# replace factors with level mean hazard
for (i in 1:ncol(X)) {
  if (class(X[,i])=="factor") {
    mm <- aggregate(y~X[,i], data=X, mean)
    levels(X[,i]) <- as.numeric(mm[,2]) 
    levels(X.test[,i]) <- mm[,2] 
    X[,i] <- as.numeric(as.character(X[,i]))  
    X.test[,i] <- as.numeric(as.character(X.test[,i]))
  }
}
X <- as.matrix(X)
X.test <- as.matrix(X.test)


#dropping some more variables

#train$Id  <- NULL 
#test$Id  <- NULL
#test$Hazard  <- NULL

train.lm <- lm(X~T1_V1+T1_V2+T1_V3+T1_V4+T1_V5+T1_V6+T1_V7+T1_V8+T1_V9+T1_V10+T1_V11+T1_V12+T1_V13+T1_V14+T1_V15+T1_V16+T1_V17+T2_V1+T2_V2+T2_V3+T2_V4+T2_V5+T2_V6+T2_V7+T2_V8+T2_V9+T2_V10+T2_V11+T2_V12+T2_V13+T2_V14+T2_V15, data=
                     train)