data_ec <- reactive({
  
  # selectie unitate
  admin_spat <- ec
  data_sub <- # select dataset
    switch(
      input$temp_res_ec,
      halfhourly = halfhourly,
      daily = daily
    )
  
  print(input$temp_res_ec)
  
  
})