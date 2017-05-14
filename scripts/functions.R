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

## find the users who are the sources
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

## entity nlp
extract_entities <- function(nlp_source_tweet_history) {
  library(dplyr)
  entity_sentiments <- Reduce(rbind, lapply(nlp_source_tweet_history, 
                                            function(x){
                                              obj <- x$entities
                                              data.frame(
                                                name = obj$name,
                                                type = obj$type,
                                                wikipedia_url = if(!is.null(obj$metadata$wikipedia_url)) obj$metadata$wikipedia_url else "",
                                                mid = if(!is.null(obj$metadata$midm)) obj$metadata$midm else "",
                                                salience = obj$salience,
                                                sentiment_mag = obj$sentiment$magnitude,
                                                sentiment_score = obj$sentiment$score,
                                                stringsAsFactors = FALSE
                                              )
                                            } ))
  
  source_entity_score <- entity_sentiments %>% 
    group_by(name, type) %>% 
    summarise(
      freq = n(),
      sum_sentiment_score = round(sum(sentiment_score),2),
      sum_sentiment_mag = round(sum(sentiment_mag),2),
      avg_sentiment_product = round(sum(sentiment_score)*sum(sentiment_mag)/freq,2),
      mean_sentiment_score = round(mean(sentiment_score),2),
      mean_sentiment_mag = round(mean(sentiment_mag),2),
      median_sentiment_score = median(sentiment_score),
      median_sentiment_mag = median(sentiment_mag),
      sum_salience = round(sum(salience), 2),
      mean_salience = round(mean(salience),2),
      median_salience = round(median(salience),2)
    ) %>% 
    filter(!is.na(name),
           sum_sentiment_mag > 0.3,
           type != "OTHER") %>% 
    arrange(desc(sum_sentiment_mag))
  
  source_entity_score
}

plot_entities <- function(x, freq_lower = 5, top_results = 20){
  
  plot_me <- x %>% 
    filter(freq > freq_lower, grepl("^[[:upper:]]", name)) %>%
    head(top_results)
  
  ## visualise source topics sentiment
  gg <- ggplot(plot_me, aes(x = sum_sentiment_score, y = sum_sentiment_mag, label = name)) + theme_bw()
  gg <- gg + geom_label_repel()
  gg + ggtitle("Top sentiment for entities", subtitle = paste("Frequency > ", freq_lower, ", Top ", top_results, "results"))
}