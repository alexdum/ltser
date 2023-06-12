insitu_sel <- reactive({
  net <- input$network
  # selectie unitate
  switch( # alege nume indicator care să fie afișat
    which(c("ws", "ec") %in%  net),
    admin_spat <- ws,
    admin_spat <- ec
  )
  
  list(
    admin_spat = admin_spat
  )
})

# harta leaflet -----------------------------------------------------------
output$map_insitu <- renderLeaflet ({
  print(insitu_sel()$admin_spat)
  leaflet_fun_in(
    data = insitu_sel()$admin_spat
  )

})
