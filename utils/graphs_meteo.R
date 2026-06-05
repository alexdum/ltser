# 
# # filename_save <- "plot.png"
# y1lab <- "Air temperature [°C]"
# y2lab <- "Wind speed [m/s]"
# cols <- c("#e34a33", "#fdbb84", "#fee8c8", "#980043", "#e7298a")
# data1 <- hourly |> filter(substr(variable,1,2) %in% "tm", id == "AG-Mih") |> collect()
# data1$time <- as.numeric(data1$time) * 1000
# data2 <- hourly |> filter(substr(variable,1,2) %in% "ws", id == "AG-Mih") |> collect()
# data2$time <- as.numeric(data2$time) * 1000
# title <- "test"
# param <- "tmin_01h"
# # #
# graph_meteo(data1, data2, title = "test", "plot.png", param, cols)

graph_meteo <- function(data1, data2, title, filename_save, param, cols = NULL) {
  
  #type series 1
  type_series1 <- ifelse(substr(param, 1, 2) %in% "tr", "column", "line")
  
  # axes labels
  axes_labels <- switch(
    which(c("tm", "ws", "ps", "hu", "ts","ir","tr", "sh") %in% substr(param, 1, 2)),
    c("Air temperature [°C]",  "Wind speed [m/s]"),
    c("Air temperature [°C]",  "Wind speed [m/s]"),
    c("Air Pressure [hPa]", "Air humidity [%]"),
    c("Air Pressure [hPa]", "Air humidity [%]"),
    c("Soil temperature [°C]", "Global irradiance [W/m²]"),
    c("Soil temperature [°C]", "Global irradiance [W/m²]"),
    c("Total precipitation [l/m²]", "Soil humidity [m³/m³]"),
    c("Total precipitation [l/m²]", "Soil humidity [m³/m³]"),
  )
  
  y1lab  <- axes_labels[1]
  y2lab  <- axes_labels[2]
  
  hc <- highchart(type = "stock") |>
    hc_yAxis_multiples(
      list(title = list(text = y1lab), opposite = FALSE),
      list(showLastLabel = FALSE, opposite = TRUE, title = list(text = y2lab))
    )
  
  # Add each variable from data1 as a separate series (yAxis 0)
  if (nrow(data1) > 0) {
    for (var_name in unique(data1$variable)) {
      d <- data1[data1$variable == var_name, ] |> dplyr::arrange(time)
      hc <- hc |> hc_add_series(
        data = d,
        type = type_series1,
        hcaes(x = time, y = values),
        name = var_name,
        yAxis = 0
      )
    }
  }
  
  # Add each variable from data2 as a separate series (yAxis 1)
  if (nrow(data2) > 0) {
    for (var_name in unique(data2$variable)) {
      d <- data2[data2$variable == var_name, ] |> dplyr::arrange(time)
      hc <- hc |> hc_add_series(
        data = d,
        type = "line",
        dashStyle = "longdash",
        hcaes(x = time, y = values),
        name = var_name,
        yAxis = 1
      )
    }
  }
  
  hc <- hc |>
    hc_legend(enabled = TRUE) |>
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
  
  hc
}

