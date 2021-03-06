#read in all the input data
cpdtr <- read.csv("/Users/bikas/Desktop/kaggle_competitions/click_coupon/coupon_detail_train.csv")
cpltr <- read.csv("/Users/bikas/Desktop/kaggle_competitions/click_coupon/coupon_list_train.csv")
cplte <- read.csv("/Users/bikas/Desktop/kaggle_competitions/click_coupon/coupon_list_test.csv")
ulist <- read.csv("/Users/bikas/Desktop/kaggle_competitions/click_coupon/user_list.csv")

#making of the train set
train <- merge(cpdtr,cpltr)

#The other columns seems to be not good predictors.
train <- train[,c("COUPON_ID_hash","USER_ID_hash",
                  "GENRE_NAME","DISCOUNT_PRICE", "PRICE_RATE","DISPPERIOD","VALIDPERIOD","USABLE_DATE_MON","USABLE_DATE_TUE","USABLE_DATE_WED","USABLE_DATE_THU","USABLE_DATE_FRI","USABLE_DATE_SAT","USABLE_DATE_SUN","USABLE_DATE_HOLIDAY","USABLE_DATE_BEFORE_HOLIDAY",              
                  "ken_name","small_area_name")]
#combine the test set with the train
cplte$USER_ID_hash <- "dummyuser"
cpchar <- cplte[,c("COUPON_ID_hash","USER_ID_hash",
                   "GENRE_NAME","DISCOUNT_PRICE", "PRICE_RATE","DISPPERIOD","VALIDPERIOD","USABLE_DATE_MON","USABLE_DATE_TUE","USABLE_DATE_WED","USABLE_DATE_THU","USABLE_DATE_FRI","USABLE_DATE_SAT","USABLE_DATE_SUN","USABLE_DATE_HOLIDAY","USABLE_DATE_BEFORE_HOLIDAY",              
                   "ken_name","small_area_name")]

train <- rbind(train,cpchar)
#NA imputation
train[is.na(train)] <- 1
#feature engineering (binning the price into different buckets)
train$DISCOUNT_PRICE <- cut(train$DISCOUNT_PRICE,breaks=c(breaks-0.01,0,1000,10000,50000,100000,Inf),labels=c("free","cheap","moderate","expensive","high","luxury"))
train$PRICE_RATE <- cut(train$PRICE_RATE,breaks=8)
train$VALIDPERIOD <- cut(train$VALIDPERIOD,breaks=8)
train$DISPPERIOD <- cut(train$DISPPERIOD,breaks=8)

#convert the factors to columns of 0's and 1's
train <- cbind(train[,c(1,2)],model.matrix(~ -1 + .,train[,-c(1,2)]))

#separate the test from train
test <- train[train$USER_ID_hash=="dummyuser",]
test <- test[,-2]
train <- train[train$USER_ID_hash!="dummyuser",]

#data frame of user characteristics by user
uchar <- aggregate(.~USER_ID_hash, data=train[,-1],FUN=mean)

#Weight Matrix: GENRE_NAME DISCOUNT_PRICE PRICE_RATE DISP_Period VALIDPERIOD USABLEDATES ken_name small_area_name
require(Matrix)
W <- as.matrix(Diagonal(x=c(rep(4,13), rep(1,5), rep(0.2,7),rep(0.2,7),rep(1,7),rep(1,9), rep(1,45), rep(1,55))))

#calculation of cosine similairties of users and coupons
score = as.matrix(uchar[,2:ncol(uchar)]) %*% W %*% t(as.matrix(test[,2:ncol(test)]))
#order the list of coupons according to similairties and take only first 10 coupons
uchar$PURCHASED_COUPONS <- do.call(rbind, lapply(1:nrow(uchar),FUN=function(i){
  purchased_cp <- paste(test$COUPON_ID_hash[order(score[i,], decreasing = TRUE)][1:10],collapse=" ")
  return(purchased_cp)
}))

#make submission
uchar <- merge(ulist, uchar, all.x=TRUE)
submission <- uchar[,c("USER_ID_hash","PURCHASED_COUPONS")]
write.csv(submission, file="cosine_sim_4.csv", row.names=FALSE)