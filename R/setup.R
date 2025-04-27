#Commands to deal with packages, uncomment if needed:

#library(devtools)
#library command loads the package, devtools is needed to install the deuce from github:
#install_github("skoval/deuce")

library(deuce)
data(atp_matches)
#this loads the atp_matches dataframe

#colnames(atp_matches)
#type source("Name_Of_R_script.R") to execute in Console  

fetch_t <- function(df,tourney,year){
  df[df$tourney_name==tourney & df$year==year,]
}

fetch_por <- function(df, p1,p2){
  m<-c(p1,p2)
  df[(df$winner_name %in% m )| (df$loser_name %in% m),]
}