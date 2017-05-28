library(googleLanguageR)
source("scripts/functions.R")

## the inputs, these a news stories you want to verify reputation for
input_source1 <- "https://www.theguardian.com/technology/2017/may/07/the-great-british-brexit-robbery-hijacked-democracy?CMP=twt_gu"
input_source2 <- "http://www.thedailybeast.com/articles/2017/05/06/did-macron-outsmart-campaign-hackers"
input_source3 <- "https://milo.yiannopoulos.net/2017/05/macron-gay-bitcoin/"

url_sources <- c(input_source1, input_source2, input_source3)

source_html_nlp <- lapply(url_sources, do_source_nlp)
names(source_html_nlp) <- url_sources

saveRDS(source_html_nlp, file = "source_html_nlp.rds")

## extract the interesting entities from the source, ranked by sentiment magnitude
## these are the topics the source talks about the most and with most passion
html_source_entities <- lapply(names(source_html_nlp), extract_entities, source = source_html_nlp)
html_source_entities <- setNames(html_source_entities, names(source_html_nlp))
saveRDS(html_source_entities, file = "data/html_source_entities.rds")
## visualise source topics sentiment
lapply(names(html_source_entities), function(x) plot_entities(html_source_entities[[x]], source_name = x, upper_only=FALSE))
