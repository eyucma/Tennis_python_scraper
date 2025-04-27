source("setup.R")

library(dplyr)    

index=c("tourney_id", "tourney_name","surface","tourney_level","winner_name","loser_name",'winner_rank','loser_rank',"score","minutes","year", 'Retirement')
df=atp_matches[,index]



#Removing entries with retirements walkovers:


fclean <- function(X){
  df=X[!is.na(X$score),]
  df=df[!grepl("W/O", df$score),]
  avg_time=40 #average time of set
  t=strsplit(df$score,split=" ")
  y<-df$minutes
  ret=as.integer(df$Retirement)
  for (i in 1:length(y)) {
    n<-length(t[[i]])-ret[i]*1.5
    m<-y[i]
    if (is.na(m)){
      y[i]=n*avg_time
    } else if (n<=0){
      if (m==0){
          next
      } else {
        stop()
      }
    } else if (n*10>m){
      y[i]=avg_time*n
    } else if ((n<4)&(m>300)) {
      y[i]=avg_time*n
    }
  }
  df$minutes<-y
  return(df)
}

df=fclean(df)


# #above copied from setup_clean, see original file for more explanation in comments
# ########----------------######



y=integer(nrow(df))
z=integer(nrow(df))

current_tourney='RandomString' 
current_ind=0
for (i in 1:nrow(df)){
  if (df$tourney_id[i] == current_tourney){
    for (j in current_ind:(i-1)){
      if (df$winner_name[j]==df$winner_name[i]){
        y[i]<-y[i]+df$minutes[j]
      } else if (df$winner_name[j]==df$loser_name[i]){
        z[i]<-z[i]+df$minutes[j]
      }
    }
  }
  else {
    current_tourney=df$tourney_id[i]
    current_ind=i
  }
}
df$winner_time=y
df$loser_time=z

df$outcome=1

df=df[!is.na(df$winner_rank),]
df=df[!is.na(df$loser_rank),]
df=df[(df$winner_rank < 101)|(df$loser_rank<101),]
#rank filter which filters out matches of too low rank and hence deemed insignificant.
#this column is a 1 if winner is the first player and 0 otherwise.
