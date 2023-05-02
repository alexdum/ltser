#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
fluidPage(
  theme = my_theme,
  
  # Application title
  titlePanel("Old Faithful Geyser Data"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins",
                  "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30)
    ),
    
    # https://rstudio.github.io/bslib/articles/cards.html
    mainPanel(
      card(
        height = 450, 
        full_screen = TRUE,
        card_header("Histogram of waiting times"),
        card_body(
          plotOutput("distPlot")
        )
      )
    )
  )
)
