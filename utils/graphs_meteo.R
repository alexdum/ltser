
# filename_save <- "plot.png"
# graph_temp <- # Your graph_temp data
#   graph_ws <- # Your graph_ws data
#   y1lab <- "Air temperature [°C]"
# y2lab <- "Wind speed [m/s]"
# cols <- c("#e34a33", "#fdbb84", "#fee8c8", "#980043", "#e7298a")
# data1 <- graph_temp
# data2 <- graph_ws
# 
# graph_meteo(data1, data2, filename_save, graph_temp, graph_ws, y1lab, y2lab, cols)

graph_meteo <- function(data1, data2, filename_save, graph_temp, graph_ws, y1lab, y2lab, cols) {
  highchart(type = "stock") |>
    hc_yAxis_multiples(
      list(title = list(text = y1lab), opposite = FALSE),
      list(showLastLabel = FALSE, opposite = TRUE, title = list(text = y2lab))
    ) |>
    hc_add_series(data1, type = "line", hcaes(x = "time", y = "values", group = "variable"), yAxis = 0) |>
    hc_add_series(data2, type = "line", dashStyle = "longdash", hcaes(x = "time", y = "values", group = "variable"), yAxis = 1) |>
    hc_legend(enabled = TRUE) |>
    hc_colors(cols) |>
    hc_add_theme(hc_theme(chart = list(backgroundColor = '#FAFAF8'))) |>
    hc_rangeSelector(buttons = list(
      list(type = 'all', text = 'All'),
      list(type = 'day', count = 5, text = '7 Days')
    )) |>
    hc_exporting(
      enabled = TRUE,
      filename = filename_save
    )
}

