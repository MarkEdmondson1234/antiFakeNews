library(topicmodels)     ## Potential text analysis
library(rtweet)          ## Download Tweets
library(dplyr)           ## ETL
library(googleLanguageR) ## Google NLP API
library(ggplot2)         ## Visualistion
library(ggrepel)
source("scripts/functions.R")

## authentication for googleLanguageR via auth JSON you download from Google Project
gl_auth(json_file = "~/dev/auth/Mark Edmondson GDE-5c293af6adf9.json")

## the inputs, these a news stories you want to verify reputation for
input_source1 <- "https://www.theguardian.com/technology/2017/may/07/the-great-british-brexit-robbery-hijacked-democracy?CMP=twt_gu"
input_source2 <- "http://www.thedailybeast.com/articles/2017/05/06/did-macron-outsmart-campaign-hackers"
input_source3 <- "https://milo.yiannopoulos.net/2017/05/macron-gay-bitcoin/"

url_sources <- c(input_source1, input_source2, input_source3)

## call twitter API to seach for tweets carrying the URL
## output includes $first_userId
url_sources_data <- lapply(url_sources, get_source_data)
url_sources_data <- setNames(url_sources_data, url_sources)

## Call Twitter API for the history of tweets for the source user
## get the history of the first user who tweets the story
timeline_source <- rtweet::tweet_history(url_sources_data[[1]]$first_userId)
saveRDS(timeline_source, file = "data/timeline_source.rds")

## lots of API calls - fails when you hit twitter API limits, not really useable
# sharers_source <- lapply(url_sources_data[[1]]$search_data$user_id[1:5], tweet_history)

# For each tweet of the source user, analyse via NLP (2000 API calls)
nlp_source_tweet_history <- lapply(timeline_source$text, googleLanguageR::gl_nlp, version = "v1beta2")
nlp_source_tweet_history <- setNames(nlp_source_tweet_history, timeline_source$status_id)

## save cache
saveRDS(nlp_source_tweet_history, file = "data/source_tweet_history_example.rds")

## extract the interesting entities from the source, ranked by sentiment magnitude
## these are the topics the source talks about the most and with most passion
source_entities <- extract_entities(nlp_source_tweet_history)

## visualise source topics sentiment
plot_entities(source_entities)
