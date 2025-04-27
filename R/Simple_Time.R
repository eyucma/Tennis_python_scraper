source("setup_clean.R")

#removes matches where the amount of minutes are not recorded


#filtered_df <- df %>% 
#  group_by(UnionChr) %>% 
#  mutate(
#    same_start = UnionStart == lead(UnionStart) | UnionStart == lag(UnionStart),
#    same_end   = UnionEnd   == lead(UnionEnd)   | UnionEnd   == lag(UnionEnd),
# zero_overlap = (Overlap == 0 | lead(Overlap == 0) | lag(Overlap == 0)),
#    combined = !(same_start & same_end & zero_overlap)
#  ) %>% 
#  filter(combined) %>% 
#  select(-(same_start:combined))l?

#the above sequence is a googled way to define a filter, %>% says lhs is inserted as input into rhs

dfy=group_by(df,year)
#group by year, this command requires the dplyr package
summarize(dfy,minutes=mean(minutes))
#this command presents the mean number of minutes per year
plot(summarize(dfy,minutes=mean(minutes)))

#plot should yield nothing significant. Couple issues are notable:
#1. Some years have only one or two entries and thus the sample size is too small to take an average
#2. Over time the number of 5-set tournaments have changed. In general the tour has changed a lot, with the modern 240-500-1000 tournaments
#setup only emerging this century

#Remedy 1: Remove years where the amount of entries is fewer than 10:
dfy1=filter(dfy,n() >= 10)
plot(summarize(dfy1,minutes=mean(minutes)))
#can verify this only removes 3 years

#Even if we bump this up to 100, little changes:
dfy1=filter(dfy,n() >= 100)

#Remedy 2: Filter to only Grandslams:
dfy=ungroup(dfy)
dfy2=dfy[dfy$tourney_level=='Grand Slams',]
dfy2=group_by(dfy2,year)
plot(summarize(dfy2,minutes=mean(minutes)))

#upon talking a closer look it seems like certain data points are quite suspicious, for example an AO match
#in 1994 seems to have taken only 32 minutes even though it was a 5 setter. Moreover several matches with RET only have single digit match lengths.
#This may not be an issue however, if we assume this issue affects all years uniformly and equally randomly, it shouldn't affect the conclusion, as it 
#should just offset every years average by a similar value. However, if it is restricted to RET, this may be relevant as for example one could argue that 
#modern tennis matches are more physically demanding and hence results in more retirements.
#This should serve as a reminder that data cleaning is a good idea.
summary(df$minutes)
#We can see that there is a max of 4756, which is 79 hours or almost three days, yet we can see it is a BO2
#challenger match:
df[which.max(df$minutes),]

#Lets attempt to remove all matches which ended in RET:
dfr=df[!grepl('RET',df$score),]
dfry=group_by(dfr,year)
dfry=filter(dfry,n() >= 10)
plot(summarize(dfry,minutes=mean(minutes)))

#Remove to filter only for Wimbledon:
dfW=dfry[dfry$tourney_name=='Wimbledon',]

#Lets try to compute a moving average:
ma <- function(x,n){
  cx=c(0,cumsum(x))
  return((cx[(n+1):length(cx)] - cx[1:(length(cx)-n)])/n)
}
maW=ma(dfW$minutes,2000)
plot(maW)
#interesting it seems the average time is going down if anything

#Repeat the same for Roland Garros reveals an interesting fact in that matches arent really significantly much longer:
dfRG=dfry[dfry$tourney_name=='Roland Garros',]
plot(summarize(dfRG,minutes=mean(minutes)))
#Again if anything the playtime is going down over the years 
maRG=ma(dfRG$minutes,2000)
plot(maRG)

#A possible reason is that over the years, the top of the tennis has become more and more dominant. Another words the disparity between top 5 and top 100
#has increased leading to more one sided matches. Another reason is also the implementation of new rules which enforce faster play.

