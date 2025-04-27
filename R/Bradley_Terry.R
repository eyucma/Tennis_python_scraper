source('setup_cleanr.R')
#
index=c("tourney_name","surface","tourney_level","winner_name","loser_name","score","minutes","winner_time",
        "loser_time","year")
df=df[,index]
df$outcome=1

names(df)[names(df) %in% c('winner_name','loser_name', 'winner_time', 'loser_time')] <- c('player','opponent','ptime','otime')
df$number=(1:dim(df)[1])

df_flip<-df
df_flip[, c("player", "opponent", 'ptime','otime')] <- df_flip[, c("opponent", "player",'otime','ptime')] 
df_flip$outcome=0
df=rbind(df,df_flip)
df <- df[order(df$number, df$outcome),]





# Following is an attempt to one hot encode by hand, but runs into memory issues:
#players=sort(unique(df$player))
# 
# get_players <- function(player, opponent, players){
#   v=rep(0,length(players))
#   v[players==player]<- 1
#   v[players==opponent]<- -1
#   v
#   
# }
# 
# X <- apply(df, 1,function(row) get_players(row["player"], row["opponent"],players))

#Can try to mitigate the issue by removing Challenger Tour matches and some years, thus removing about 14/40:
df=df[df$tourney_level!='Challenger',]


#However we still have a lot of entries left. We should also probably remove players with too few matches played,
#note moreover at the bare minimum we need to remove players who only appear a single time in the database otherwise
#their parameter would be optimized at infinity or negative infinity (in fact we need to ensure that players that appear
#can't only win or only lose). Let's try first with insisting at least 3  matches played:
while ((df %>% group_by(player)%>%filter(n()<3)%>%dim)[1]>0) {
  df <- df %>% group_by(player) %>% filter(n()>2)
  df <- df %>% group_by(opponent) %>% filter(n()>2)
}
#We seem to have managed to reduce the number of players down by roughly 50%. This number is still too large.
#For now, let's try to filter results after 2000, and only take players who played at least 5 matches at the atp level:

df=df[df$year>2000,]
while ((df %>% group_by(player)%>%filter(n()<6)%>%dim)[1]>0) {
  df <- df %>% group_by(player) %>% filter(n()>5)
  df <- df %>% group_by(opponent) %>% filter(n()>5)
}

players=sort(unique(df$player))
variables<-gsub(" ","_",players)
X1=model.matrix(~0+df$player)
colnames(X1)=variables
X2=model.matrix(~0+df$opponent)
colnames(X2)=variables

#to check memory consumption of all objects, divide by 10e6 to get it in MB, 10e9 for GB
sort( sapply(ls(),function(x){object.size(get(x))}))/10^9

X=X1-X2
remove(X2)
remove(X1)

sample <- sample(c(TRUE,FALSE), nrow(X),  replace=TRUE, prob=c(0.7,0.3)) 

train=X[sample,]
y_train=df$outcome[sample]
val=X[!sample,]
y_val=df$outcome[!sample]

df_train<-data.frame(cbind(y_train,train))
names(df_train)[1] <-"outcome"

model=glm(outcome~.+0,family=binomial(link='logit'), data=df_train)
#split train test and val (old method):

# spec = c(train = .6, test = .2, validate = .2)
# g = sample(cut(seq(nrow(df)), nrow(df)*cumsum(c(0,spec)),labels = names(spec)))
# res = split(X, g)
# out = split(df$outcome,g)
# # 
# df_train=res$train
# y_train=out$train
# df_val=res$validate
# y_val=out$validate
# df_test=res$test
df_val=data.frame(val)
y_pred <- predict(model,df_val,type="response")

library(pROC)
roc_obj <- roc(y_val, y_pred)
auc(roc_obj)

#Adding the contribution of game_time
delta <- df$ptime-df$otime

df1_train<-df_train
df1_val<-df_val

df1_train$tdelta<-delta[sample]
df1_val$tdelta<-delta[!sample]
model1=glm(outcome~.+0,family=binomial(link='logit'), data=df1_train)

#improvement is marginal (auc only goes up from 0.731 to 0.7317. Note removing all player variables results in auc of 0.5941)