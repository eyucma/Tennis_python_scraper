source("setup_clean.R")

#Begin with a simple Linear Model on minutes vs surface
SurfaceLM = lm(df$minutes ~ df$surface)
summary(SurfaceLM)

#In this case the model predicts that grass matches are longest (however there is a 
#possible bias in that a more significant portion of grass matches occur every year at Wimbledon, a best of 5 grand slam),
#followed by clay, hard and finally carpet. This agrees with conventional wisdom mostly. The p-value for the null
#hypothesis of intercept only is very small giving strong indication that surface is a good predictor.
#Note that this model is a very predictor as we are throwing away a lot of variables and so R squared is very very low.

#We can however adjust this by factoring in the number of sets played. This can be done in two fashions: either as a numerical
#or categorical. The advantage of numerical is of course that it is simple and preserves the monotonic relation. The advantage
#of the categorical is that it takes into consideration  that increase in time due to number of sets is not strictly linear,
#as the fifth set is potentially a lot longer due to how final set tiebreakers work in the history of tennis.

#Begin with a numeric approach:
t=strsplit(df$score,split=" ")
y=integer(dim(df)[1])

for (x in 1:length(y)) {
  y[x]=length(t[[x]])
}
df$sets=y

SurfaceLMimp=lm(df$minutes ~ df$surface + df$sets)
summary(SurfaceLMimp)
#We see that, by accounting for number of sets, the longest matches occur on clay followed by hard, carpet and finally grass. 
#This agrees strongly with conventional wisdom.

#Finally lets test F-statistic for the surface predictor.
RSS=sum(SurfaceLMimp$residuals**2)
lm1=lm(df$minutes ~ df$sets)
RSS0=sum(lm1$residuals**2)
Fstat=SurfaceLMimp$df.residual*(RSS0-RSS)/3/RSS

pf(Fstat,3,SurfaceLMimp$df.residual, lower.tail=FALSE)
