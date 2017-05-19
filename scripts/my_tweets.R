library(rtweet)

#' Get user stream data
#' 
#' For the user you are authenticated under, gets data
#' 
#' @seealso \url{https://dev.twitter.com/streaming/reference/get/user}
#' 
get_userstream <- function(username){
  
  rtweet::get_timeline(username, home = TRUE)
}