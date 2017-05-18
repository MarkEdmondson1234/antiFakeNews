library(topicmodels)     ## Potential text analysis
library(rtweet)          ## Download Tweets
library(tidyverse)           ## ETL
library(googleLanguageR) ## Google NLP API
library(ggplot2)         ## Visualistion
library(ggrepel)         ## nice labels on ggplot
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
url_sources_data <- get_source_data(url_sources)

## Call Twitter API for the history of tweets for the source user
## get the history of the first user who tweets the story
timeline_sources <- get_timeline_sources(url_sources_data)
names(timeline_sources) <- url_sources
## lots of API calls - fails when you hit twitter API limits, not really useable
# sharers_source <- lapply(url_sources_data[[1]]$search_data$user_id[1:5], tweet_history)

# Concatenate all the tweets in one document, do NLP on all of them at same time per source
nlp_sources_tweet_history <- get_nlp_api(timeline_sources)
## save cache
saveRDS(nlp_sources_tweet_history, file = "data/nlp_sources_tweet_history.rds")

## extract the interesting entities from the source, ranked by sentiment magnitude
## these are the topics the source talks about the most and with most passion
source_entities <- lapply(names(nlp_sources_tweet_history), extract_entities, source = nlp_sources_tweet_history)
source_entities <- setNames(source_entities, names(nlp_sources_tweet_history))
## visualise source topics sentiment
lapply(names(source_entities), function(x) plot_entities(source_entities[[x]], source_name = x))

# http://tidytextmining.com/ngrams.html