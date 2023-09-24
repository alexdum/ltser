subset_param  <- function(input) {
  subset_param <- switch(
    which(c("tm", "ws", "ps", "hu") %in% substr(input, 1, 2)),
    c("tm", "ws"),
    c("tm", "ws"),
    c("ps", "hu"),
    c("ps", "hu")
  )
  return(subset_param)
}