# 
# # filename_save <- "plot.png"
# y1lab <- "Air temperature [°C]"
# y2lab <- "Wind speed [m/s]"
# cols <- c("#e34a33", "#fdbb84", "#fee8c8", "#980043", "#e7298a")
# data1 <- hourly |> filter(substr(variable,1,2) %in% "tm", id == "AG-Mih") |> collect()
# data1$time <- as.numeric(data1$time) * 1000
# data2 <- hourly |> filter(substr(variable,1,2) %in% "ws", id == "AG-Mih") |> collect()
# data2$time <- as.numeric(data2$time) * 1000
# #
# graph_meteo(data1, data2, "test", y1lab, y2lab, cols)

graph_meteo <- function(data1, data2, title, filename_save, param, cols) {
  
  # axes labels
  
  axes_labels <- switch(
    which(c("tm", "ws", "ps", "hu") %in% substr(param, 1, 2)),
    c("Air temperature [°C]",  "Wind speed [m/s]"),
    c("Air temperature [°C]",  "Wind speed [m/s]"),
    c("Air_Pressure [hPa]", "Air_Humidity [%]"),
    c("Air_Pressure [hPa]", "Air_Humidity [%]")
  )
  
  y1lab  <- axes_labels[1]
  y2lab  <- axes_labels[2]
  
  highchart(type = "stock") |>
    hc_yAxis_multiples(
      list(title = list(text = y1lab), opposite = FALSE),
      list(showLastLabel = FALSE, opposite = TRUE, title = list(text = y2lab))
    ) |>
    hc_add_series(data1, type = "line", hcaes(x = "time", y = "values", group = "variable"), yAxis = 0) |>
    hc_add_series(data2, type = "line", dashStyle = "longdash", hcaes(x = "time", y = "values", group = "variable"), yAxis = 1) |>
    hc_legend(enabled = TRUE) |>
    #hc_colors(cols) |>
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

