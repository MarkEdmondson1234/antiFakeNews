library(tidytext)
library(stringr)
library(tidyverse)
library(scales)
library(broom)

## adapting http://tidytextmining.com/twitter.html

tweet_data <- url_sources_data[[1]]$search_data
tweet_data$data_source <- "source_sharers"
my_tweet_data <- my_tweets
my_tweet_data$data_source <- "me"
replace_reg <- "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|&amp;|&lt;|&gt;|RT|https"
unnest_reg <- "([^A-Za-z_\\d#@']|'(?![A-Za-z_\\d#@]))"

tidy_tweets <- tweet_data %>% 
  bind_rows(my_tweet_data) %>% 
  select(status_id, text, created_at, data_source, favorite_count, retweet_count) %>% 
  filter(!str_detect(text, "^RT")) %>%
  mutate(text = str_replace_all(text, replace_reg, "")) %>%
  unnest_tokens(word, text, token = "regex", pattern = unnest_reg) %>%
  filter(!word %in% stop_words$word,
         str_detect(word, "[a-z]"))

word_count <- tidy_tweets %>% 
  group_by(data_source) %>% 
  count(word, sort = TRUE) %>%
  left_join(tidy_tweets %>% group_by(data_source) %>% summarise(total = n())) %>% 
  mutate(freq = n / sum(n))

frequency <- word_count %>% 
  select(data_source, word, freq) %>% 
  spread(data_source, freq) %>%
  arrange(me, source_sharers)



ggplot(frequency, aes(me, source_sharers)) +
  geom_jitter(alpha = 0.1, size = 2.5, width = 0.25, height = 0.25) +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.5) +
  scale_x_log10(labels = percent_format()) +
  scale_y_log10(labels = percent_format()) +
  geom_abline(color = "red")

word_ratios <- tidy_tweets %>%
  filter(!str_detect(word, "^@")) %>%
  count(word, data_source) %>%
  # filter(sum(n) >= 10) %>%
  ungroup() %>%
  spread(data_source, n, fill = 0) %>%
  mutate_if(is.numeric, funs((. + 1) / sum(. + 1))) %>% 
  mutate(logratio = log(me / source_sharers)) %>%
  arrange(desc(logratio))

word_ratios %>% 
  arrange(abs(logratio))

word_ratios %>%
  group_by(logratio < 0) %>%
  top_n(15, abs(logratio)) %>%
  ungroup() %>%
  mutate(word = reorder(word, logratio)) %>%
  ggplot(aes(word, logratio, fill = logratio < 0)) +
  geom_col() +
  coord_flip() +
  ylab("log odds ratio (me/source_sharers)") +
  scale_fill_discrete(name = "", labels = c("me", "source_sharers"))


words_by_time <- tidy_tweets %>%
  filter(!str_detect(word, "^@")) %>%
  mutate(time_floor = floor_date(created_at, unit = "1 month")) %>%
  count(time_floor, data_source, word) %>%
  ungroup() %>%
  group_by(data_source, time_floor) %>%
  mutate(time_total = sum(n)) %>%
  group_by(word) %>%
  mutate(word_total = sum(n)) %>%
  ungroup() %>%
  rename(count = n) 
# %>%
  # filter(word_total > 30)

nested_data <- words_by_time %>%
  nest(-word, -data_source) 

nested_models <- nested_data %>%
  mutate(models = map(data, ~ glm(cbind(count, time_total) ~ time_floor, ., 
                                  family = "binomial")))

slopes <- nested_models %>%
  unnest(map(models, tidy)) %>%
  filter(term == "time_floor") %>%
  mutate(adjusted.p.value = p.adjust(p.value))

top_slopes <- slopes %>% 
  filter(adjusted.p.value < 0.1)

top_slopes

rt_totals <- tidy_tweets %>% 
  group_by(data_source, status_id) %>% 
  summarise(rts = sum(retweet_count)) %>% 
  group_by(data_source) %>% 
  summarise(total_rts = sum(rts))

rt_totals

word_by_rts <- tidy_tweets %>% 
  group_by(status_id, word, data_source) %>% 
  summarise(rts = first(retweet_count)) %>% 
  group_by(data_source, word) %>% 
  summarise(retweet_count = median(rts), uses = n()) %>%
  left_join(rt_totals) %>%
  filter(retweet_count != 0) %>%
  ungroup()

word_by_rts %>% 
  filter(uses >= 5) %>%
  arrange(desc(retweet_count))

word_by_rts %>%
  # filter(uses >= 5) %>%
  group_by(data_source) %>%
  top_n(10, retweet_count) %>%
  arrange(retweet_count) %>%
  ungroup() %>%
  mutate(word = factor(word, unique(word))) %>%
  ungroup() %>%
  ggplot(aes(word, retweet_count, fill = data_source)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ data_source, scales = "free", ncol = 2) +
  coord_flip() +
  labs(x = NULL, 
       y = "Median # of retweets for tweets containing each word")

fav_totals <- tidy_tweets %>% 
  group_by(data_source, status_id) %>% 
  summarise(favs = sum(favorite_count)) %>% 
  group_by(data_source) %>% 
  summarise(total_favs = sum(favs))

word_by_favs <- tidy_tweets %>% 
  group_by(status_id, word, data_source) %>% 
  summarise(favs = first(favorite_count)) %>% 
  group_by(data_source, word) %>% 
  summarise(favorites = median(favs), uses = n()) %>%
  left_join(fav_totals) %>%
  filter(favorites != 0) %>%
  ungroup()

word_by_favs %>%
  filter(uses >= 5) %>%
  group_by(data_source) %>%
  top_n(10, favorites) %>%
  arrange(favorites) %>%
  ungroup() %>%
  mutate(word = factor(word, unique(word))) %>%
  ungroup() %>%
  ggplot(aes(word, favorites, fill = data_source)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ data_source, scales = "free", ncol = 2) +
  coord_flip() +
  labs(x = NULL, 
       y = "Median # of favorites for tweets containing each word")
