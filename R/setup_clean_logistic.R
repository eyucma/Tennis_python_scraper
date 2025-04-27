source("setup_clean.R")
y=integer(dim(df)[1])
z=integer(dim(df)[1])

current_tourney='RandomString'
current_ind=0
for (x in 1:length(df$minutes)){
  if (df$tourney_id[x] == current_tourney){
    for (i in current_ind:x-1){
      if (df$winner_name[i]==df$winner_name[x]){
        y[x]=y[x]+df$minutes[i]
      } else if (df$winner_name[i]==df$loser_name[x]){
        z[x]=z[x]+df$minutes[i]
      }
    }
  }
  else {
    current_tourney=df$tourney_id[x]
    current_ind=x
  }
}
df$winner_time=y
df$loser_time=z

df$outcome=1
#this column is a 1 if winner is the first player and 0 otherwise.
