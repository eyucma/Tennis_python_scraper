library(deuce)
source('utils.R')

### SUPPLY ROOT FOR LOCAL DEUCE PACKAGE
package_root <- "/Library/Frameworks/R.framework/Versions/4.3-x86_64/Resources/library/deuce"


### COLLECT MATCH, RANKINGS, AND PLAYER DATA
repo <- "https://github.com/JeffSackmann/tennis_atp"
master <-"JeffSackmann/tennis_atp/blob/master"
files <- html_parser(repo, dir=master)



#The following line bugs out, seems the scraper can't extract all the href on html (fixed):
atp_players <- fetch_repo_data(grep("players", files, val = T), stringsAsFactors = F, header = T)

atp_players <- tidy_player_data(atp_players)

save(atp_players, file = file.path(package_root, "data/atp_players.RData"))

atp_rankings <- do.call("rbind", lapply(grep("rankings_", files, val = T), function(x) fetch_repo_data(x, strings = FALSE, header = T, quote = "")))
# Deal with different format of ranking files (old code:)
# atp_rankings2 <- do.call("rbind", lapply(grep("rankings_[19c]", files, val = T), function(x) fetch_repo_data(x, strings = FALSE, header = T, quote = "")))
# 
# names(atp_rankings2) <- names(atp_rankings)
# 
# atp_rankings <- rbind(atp_rankings, atp_rankings2)

atp_rankings <- tidy_rankings_data(atp_rankings)

save(atp_rankings, file = file.path(package_root, "data/atp_rankings.RData"))

match_files <- grep("matches", files , val = T)
match_files <- match_files[!grepl("doubles", match_files)]



atp_matches <- do.call("rbind", lapply(match_files, function(x) fetch_repo_data(x, strings = FALSE, header = T)))
#manual adjustment
atp_matches[(atp_matches$tourney_id=='1963-580')&(atp_matches$match_num==22),'score']<-"6-3 6-4 4-6 6-3" 
atp_matches[(atp_matches$tourney_id=='1964-540')&(atp_matches$match_num==16),'score']<-"6-4 7-5 6-1" 
atp_matches <- tidy_match_data_patched(atp_matches)

save(atp_matches, file = file.path(package_root, "data/atp_matches.RData"))



