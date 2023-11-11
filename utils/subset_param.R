subset_param  <- function(input) {
  subset_param <- switch(
    which(c("tm", "ws", "ps", "hu", "ts", "ir", "tr", "sh") %in% substr(input, 1, 2)),
    c("tm", "ws"),
    c("tm", "ws"),
    c("ps", "hu"),
    c("ps", "hu"),
    c("ts", "ir"),
    c("ts", "ir"),
    c("tr", "sh"),
    c("tr", "sh"),
  )
  return(subset_param)
}