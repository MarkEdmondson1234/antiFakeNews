# library(rtweet)
# ## name assigned to created app
# appname <- "rtweet_tokens_for_mark"
# ## api key 
# key <- "ta4XSfRTVkuTPbnVuFleec07L"
# ## api secret 
# secret <- "Bw15F7h9wZGJkfAtHZ53u6HjZd53tHqBjlexQfSmfiXyYNl9mk"
# twitter_token <- create_token(
#   app = appname,
#   consumer_key = key,
#   consumer_secret = secret)
# 
# ## path of home directory
# home_directory <- path.expand("~/dev/auth/")
# 
# ## combine with name for token
# file_name <- file.path(home_directory, "twitter_token.rds")
# 
# ## save token to home directory
# saveRDS(twitter_token, file = file_name)