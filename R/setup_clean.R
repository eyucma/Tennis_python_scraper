source("setup.R")

library(dplyr)    

index=c("tourney_id", "tourney_name","surface","tourney_level","winner_name","loser_name", "score","minutes","year")
df=atp_matches[,index]

df=df[!is.na(df$minutes),]

#Removing entries with retirements and walkovers:
df=df[!grepl("RET", df$score),]
df=df[!grepl("W/O", df$score),]

#However even after filtering for those, looking at some of the minutes of the matches are suspicious
#for example, the 1st round match of Bevker v Reneberg at the 1993 USO lasted 25 minutes yet
#was seemingly a five set match including a tiebreaker. This issue seems to stem from the source,
#i.e the ATP website, where if you look at the 1993 USO, there are a lot of suspicious times. This issue seems to exist 
#even as late as 1996. However not all match times seem to be erroneous, for example at the 1996 USO Hlasek v Gumy
#seems to be accurately listed as a 1 hour 32 minute match and yet Edberg v Haarhuis was only a 2 minute match.
#We can begin by filtering out matches less than 10 minutes as it's safe to say these are either walkover
#or erroneous listings.
df=df[df$minutes > 10,]
min(df$minutes)

#df[df$minutes==min(df$minutes),]
#We see there are 8 matches which have gone the duration of 25 minutes. Two of them are best of two matches
#ending in double bagels and thus are feasible, the rest are all minimum 4 set matches and thus it's safe 
#to say are erroneous. 

df=df[!(df$minutes==min(df$minutes))|!(df$tourney_level=="Grand Slams"),]

#Unfortunately that doesn't quite solve the issue:
#df[df$minutes<30,]
#reveals there are numerous five set matches with only 30 ish minutes elasped, some featuring tiebreaks.
#We need a more robust solution, we can observe that a set should take at least 12 minutes and so a n set match should
#take at least n*12

t=strsplit(df$score,split=" ")
y=integer(dim(df)[1])

for (x in 1:length(y)) {
  y[x]=length(t[[x]])
  }

df=df[df$minutes>11*y,]
#This looks a lot better, but now we have the opposite issue. There are five matches who supposedly lasted longer than 1000
#minutes. This is literally impossible as the world record is the Isner v Mahut match which lasted around 670 minutes.

#Let's begin by looking at all matches elapsing longer than 700 minutes.
df[df$minutes>700,]
#There doesn't seem to be a pattern here. Only possible suggestion is that the match with 4756 minutes elapsed
#might be misformatted in the sense the true number of minutes is 47.56. However for the rest, it is hard to say,
#and ultimately it's probably more prudent to remove them all.

#In fact we can remove all three set matches with more than 5 hours ie 300 minutes.
t=strsplit(df$score,split=" ")
y=logical(dim(df)[1])

for (x in 1:length(y)) {
  if (length(t[[x]]) < 4 & df$minutes[x] > 300 ) {
    y[x]=FALSE
  } #else if (nchar(tail(t[[x]],n=1) > 4)){
    #y[x]=TRUE
  else {
    y[x]=TRUE
  }
}

df=df[y,]

