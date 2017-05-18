# search_data <- search_tweets(input_source, n = 1000)
# users_data <- users_data(search_data)
## gather data on source/resharer
tweet_history <- function(userId){

  req <- try(get_timeline(userId, n = 2000))
  if(assertthat::is.error(req)){
    warning("Twitter API error")
    return(NULL)
  }
  req
}

get_timeline_sources <- function(url_sources_data){
  assertthat::assert_that(!is.null(names(url_sources_data)))
  
  out <- lapply(names(url_sources_data), function(x) tweet_history(url_sources_data[[x]]$first_userId))
  
  saveRDS(out, file = "data/timeline_sources.rds")
  setNames(out, names(url_sources_data))
}
## find the users who are the sources
get_source_data_one <- function(url_source, n){
  
  search_data <- rtweet::search_tweets(url_source, n = n, type = "recent", include_rts = FALSE)
  users_data <- users_data(search_data)
  
  ## we want most RTs
  most_rt <- search_data %>% 
    filter(retweet_count > (max(retweet_count) - mean(retweet_count))) %>% 
    filter(created_at == min(created_at)) %>% 
    distinct()
  
  first_userId <- most_rt$user_id
  
  list(first_userId = first_userId,
       search_data = search_data,
       users_data = users_data)
}

get_source_data <- function(x, n = 1000){
  url_sources_data <- lapply(x, get_source_data_one, n = n)
  out <- setNames(url_sources_data, x)
  saveRDS(out, file = paste0("data/",Sys.Date(),"url_sources_data.rds"))
  out
}

## entity nlp
extract_entities <- function(names, source) {
  library(dplyr)

  x <- source[[names]]
  obj <- x$entities
  keep <- data.frame(
    name = obj$name,
    type = obj$type,
    # wikipedia_url = if(!is.null(obj$metadata$wikipedia_url)) obj$metadata$wikipedia_url else "",
    # mid = if(!is.null(obj$metadata$midm)) obj$metadata$midm else "",
    salience = obj$salience,
    sentiment_mag = obj$sentiment$magnitude,
    sentiment_score = obj$sentiment$score,
    stringsAsFactors = FALSE
  )

  source_entity_score <- keep %>% 
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

plot_entities <- function(x, source_name, freq_lower = 0, top_results = 30){
  
  plot_me <- x %>% 
    filter(freq > freq_lower, grepl("^[[:upper:]]", name)) %>%
    arrange(desc(sum_sentiment_mag)) %>% 
    head(top_results)

  message(source_name)
  ## visualise source topics sentiment
  gg <- ggplot(plot_me, aes(x = sum_sentiment_score, y = sum_sentiment_mag, label = name)) + theme_bw()
  gg <- gg + geom_label()
  gg <- gg + ggtitle(source_name, 
                     subtitle = paste("Frequency > ", freq_lower, ", Top ", top_results, "results"))

  # pdf(file.path("plots",basename(tempfile(fileext = ".pdf"))))
  print(gg)
  # dev.off()

}


get_nlp_api <- function(timeline_sources){
  
  out <- lapply(names(timeline_sources), function(x) {
    obj <- timeline_sources[[x]]
    googleLanguageR::gl_nlp(paste(obj$text, collapse = " || "), 
                            version = "v1beta2", 
                            nlp_type = "analyzeEntitySentiment")
  })
  
  setNames(out, names(timeline_sources))
}