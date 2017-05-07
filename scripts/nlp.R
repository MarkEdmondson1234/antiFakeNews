library(topicmodels)
library(rtweet)
library(dplyr)

input_source <- "https://www.theguardian.com/technology/2017/may/07/the-great-british-brexit-robbery-hijacked-democracy?CMP=twt_gu"

input_source2 <- "http://www.thedailybeast.com/articles/2017/05/06/did-macron-outsmart-campaign-hackers"

input_source3 <- "https://milo.yiannopoulos.net/2017/05/macron-gay-bitcoin/"

search_data <- search_tweets(input_source, n = 1000)
users_data <- users_data(search_data)

## gather data on source/resharer
tweet_history <- function(userId){
  
  req <- try(get_timeline(userId, n = 200))
  if(assertthat::is.error(req)){
    return(NULL)
  }
}

first_tweeters <- search_data[search_data$created_at == min(search_data$created_at),]

## some user_ids are bots that have less retweets
orignal <- first_tweeters[first_tweeters$retweet_count == max(first_tweeters$retweet_count), ]

first_userId <- orignal[!duplicated(orignal$user_id),"user_id"]

timeline_source <- tweet_history(first_userId)

## lots of API calls
sharers_source <- Reduce(dplyr::bind_rows, lapply(search_data$user_id, tweet_history))

## analyse timeline_source for topics, sentiment

## analyse sharers_source for topics, sentiment