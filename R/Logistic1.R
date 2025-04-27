source('setup_clean_logistic.R')


#the problem if we attempt to fit a GLM naively now there will be an error as the algorithm will not converge as the minimal
#parameters would be achieved by just putting the intercept as large as possible and everything else zero.
#There are numerous ways to adjust this, one way would be to for example randomly flip to the inverse half of the data points.
#Another would be to adjust the problem at task so that the intercept corresponds to an intuitive value. For example if the
#intercept is fixed at 0 and we instead take relative time values, so that when time difference between players is 0, the probability 
#of win is precisely 1/2.

#It is worth exploring both options:
model <- glm(outcome ~ I(winner_time - loser_time)+0,family=binomial(link='logit'),data=df)
#the method of differences gives a significance p-value of 2e-16


df1=data.frame(df)
#names(df1)[(names(df1) == 'winner_name')|(names(df1) == 'loser_name')] <- c('player','opponent')
names(df1)[names(df1) %in% c('winner_name','loser_name', 'winner_time', 'loser_time')] <- c('player','opponent','ptime','otime')



rb=rbinom(dim(df1)[1],1,0.5)
#This section is probably not optimized as it is exceedingly slow, if done via python use apply:
# for (i in 1:length(rb)){
#   if (rb[i]==0){
#     df1$outcomes[i]=0
#     placeholder=df1$player[i]
#     df1$player[i]=df1$opponent[i]
#     df1$opponent[i]=placeholder
#     placeholder=df1$ptime[i]
#     df1$ptime[i]=df1$otime[i]
#     df1$otime[i]=placeholder
#   }
# }
df1[rb == 0, c("player", "opponent", 'ptime','otime')] <- df1[rb == 0, c("opponent", "player",'otime','ptime')] 
df1[rb == 0,"outcome"] <- 0

model1 <- glm(outcome ~ ptime + otime,family=binomial(link='logit'),data=df1)

#Will try to evaluate these models using AUC or ROC curve
libary(pROC)
roc_obj <- roc(df1$outcome, model1$fitted.values)
#par(mfrow=c(1,1)) reset mfrow if needed
plot(roc_obj)
#As far as a predictor goes, this is pretty terrible. This makes sense since if only game time was a predictor, life would be too easy.
