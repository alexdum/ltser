# observeEvent(input$social_indicator, ignoreInit = T, {
#   
#   # update ani
#   updateSelectizeInput(
#     session, "social_years",
#     choices = socio_years[[input$social_indicator]],
#     selected = max(socio_years[[input$social_indicator]])
#   )
#   
# })

soc_df <- reactive({
  print(input$social_indicator)
  #if (input$tabs == "Social indicators") { # activate when only selected
  # subset indicator
  # switch(
  #   which(c("pop108d", "pop309e") %in% input$social_indicator),
  #   #soc_ind <- pop106a,
  #   soc_ind <- pop108d,
  #   soc_ind <- pop309e
  # )
  
  if (input$social_indicator == "pop108d") {
    soc_ind_sub <- 
      pop108d |> 
      filter(an %in% input$social_years_pop108d, varsta %in% input$social_agesyear, sex %in% input$social_gender) |>
      collect()
  } else {
    soc_ind_sub <- 
      pop309e |>
      filter(an %in% input$social_years_pop309e) |>
      collect()
  }
  
  list(tab = soc_ind_sub)
})

observe({
  
  #req(input$tab_socio)
  print(head(soc_df()$tab))
})








#observeEvent(list(input$social_years,input$social_indicator, input$tabs ),{

# observeEvent(input$social_years, {
#   # filtrare
#   print(head(df$soc_ind))
#   if (input$social_indicator == "pop108d") {
#    
#     print(summary(soc_ind_sub))
#   }
# })
