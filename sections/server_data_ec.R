data_ec <- reactive({
  
  # selectie unitate
  admin_spat <- ec
  data_sub <- # select dataset
    switch(
      input$temp_res_ec,
      halfhourly = hhourly_ec,
      daily = daily_ec
    )
  
  data_sel <- 
    data_sub |> 
    filter(
      variable == input$parameter_ec,
      time_eet %in% input$datetime_ec,
      !is.na(values)
    ) |> collect()
  
  
  # join cu datele spatiale
  admin_spat <- admin_spat |> mutate(Name = tolower(Name)) |> inner_join(data_sel, by = c("Name" = "id"))
  
  list(
    admin_spat = admin_spat,   data_sel =   data_sel
  )
  
})

observe({
  print(data_ec()$admin_spat)
  print(data_ec()$data_sel)
})