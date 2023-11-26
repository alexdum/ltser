# 
# # filename_save <- "plot.png"

#data1 <- hhourly_ec |> filter(variable == "LE",  id == "enisala") |> collect()
# data1$time <- as.numeric(data1$time) * 1000
# data2 <- hourly |> filter(substr(variable,1,2) %in% "ws", id == "AG-Mih") |> collect()
# data2$time <- as.numeric(data2$time) * 1000
# title <- "test"
# param <- "tmin_01h"
# # #
# graph_meteo(data1, data2, title = "test", "plot.png", param, cols)

graph_ec <- function(data1, title, filename_save, y1lab ) {
  
  
  
  
  highchart(type = "stock") |>
    hc_add_series(data = data1, "line", hcaes(x = datetime_to_timestamp(time_eet), y = values)) |>
    hc_yAxis(
      title = list(text = y1lab)) |>
    hc_legend(enabled = F) |>
    hc_add_theme(hc_theme(chart = list(backgroundColor = '#FAFAF8'))) |>
    hc_rangeSelector(buttons = list(
      list(type = 'all', text = 'All'),
      list(type = 'day', count = 5, text = '7 Days')
    )) |>
    hc_exporting(
      enabled = TRUE,
      filename = filename_save
    ) |>
    hc_title(text = title)
  
  
  
}


