observe({
  if (input$tabs == "Social indicators") { # activate when only selected
    # subset indicator
    switch( 
      which(c("pop106a", "pop108d", "pop309e") %in%  input$social_indicator),
      soc_ind <- pop106a,
      soc_ind <- pop108d,
      soc_ind <- pop309e
    )
    # actualizare ani in functie de indicator
    
    print(head(soc_ind))
    
    updateSelectInput(
      session, "social_years",
      choices = sort(soc_ind[, unique(an)], decreasing = T),
      selected = soc_ind[, unique(an)]  
    )
    
  }
  # indic <- input$industrie_ind_det
  # if (indic %in% c("tasmaxAdjust", "hurs")) {
  #   # luni/sezona/an
  #   updateSelectInput(
  #     session, "industrie_perio_det",
  #     choices = select_interv,
  #     selected = select_interv[1]
  #   )
  # } else { # doara anuala cand nu le ai pe celelalte
  #   updateSelectInput(
  #     session, "industrie_perio_det",
  #     choices = select_interv[17],
  #     selected = select_interv[17]
  #   )
  # }
})
