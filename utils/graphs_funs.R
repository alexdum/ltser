# https://www.tmbish.me/lab/highcharter-cookbook/#tidy-data
hc_plot <- function(input, xaxis_series, filename_save, cols, names, ytitle, title = NULL) {
  hh <- highchart(type = "stock")  |>
   # hc_xAxis(type = "date") |>
    hc_add_series(input,type = "line", hcaes("date", "value"), color = cols[1], name = names[1])
  # if (length(xaxis_series) == 2) {
  #   hh <- hh |> hc_add_series(input,type = "line", hcaes_string("date", xaxis_series[2]), color = cols[2], name = names[2]) 
  # }
  hh <- hh|> hc_legend(enabled = T) |>
    hc_exporting(
      enabled = TRUE, # always enabled
      filename =  filename_save) |>
    hc_yAxis(title = list(text = ytitle),
             opposite = TRUE,
             minorTickInterval = "auto",
             minorGridLineDashStyle = "LongDashDotDot",
             showFirstLabel = FALSE,
             showLastLabel = FALSE
    ) |>
    hc_rangeSelector(selected = 4)
  if (!is.null(title))  hh <- hh |> hc_title(text = title)
  
  
  return(hh)
}