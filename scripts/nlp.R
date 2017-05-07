library(topicmodels)
library(rtweet)
library(dplyr)
library(googleLanguageR)

input_source1 <- "https://www.theguardian.com/technology/2017/may/07/the-great-british-brexit-robbery-hijacked-democracy?CMP=twt_gu"

input_source2 <- "http://www.thedailybeast.com/articles/2017/05/06/did-macron-outsmart-campaign-hackers"

input_source3 <- "https://milo.yiannopoulos.net/2017/05/macron-gay-bitcoin/"

url_sources <- c(input_source1, input_source2, input_source3)

# search_data <- search_tweets(input_source, n = 1000)
# users_data <- users_data(search_data)
## gather data on source/resharer
tweet_history <- function(userId){
  
  req <- try(get_timeline(userId, n = 200))
  if(assertthat::is.error(req)){
    warning("Twitter API error")
    return(NULL)
  }
}

get_source_data <- function(url_source){
  
  search_data <- search_tweets(url_source, n = 1000)
  users_data <- users_data(search_data)
  
  ## get users mentioned, they may include originator
  tweet_search_mentions_id <- unique(
    Reduce(c, strsplit(search_data$mentions_user_id, split = " ")))
  
  tweet_search_mentions_id <- tweet_search_mentions_id[!is.na(tweet_search_mentions_id)]
  
  
  first_tweeters <- search_data[search_data$created_at == min(search_data$created_at),]
  ## some user_ids are bots that have less retweets
  orignal <- first_tweeters[first_tweeters$retweet_count == max(first_tweeters$retweet_count), ]
  
  first_userId <- orignal[!duplicated(orignal$user_id),"user_id"]
  
  list(first_userId = first_userId,
       search_data = search_data,
       users_data = users_data)
}

url_sources_data <- lapply(url_sources, get_source_data)
url_sources_data <- setNames(url_sources_data, url_sources)


## just for one for now
timeline_source <- tweet_history(url_sources_data[[1]]$first_userId)

## lots of API calls
sharers_source <- lapply(url_sources_data[[1]]$search_data$user_id[1:5], tweet_history)

## analyse timeline_source for topics, sentiment
gl_auth(json_file = "~/dev/auth/Mark Edmondson GDE-5c293af6adf9.json")

# lots of API calls to find entity and sentiment
nlp_source_tweet_history <- lapply(timeline_source$text, gl_nlp)
saveRDS(nlp_source_tweet_history, file = "data/source_tweet_history_example.rds")
## analyse sharers_source for topics, sentiment