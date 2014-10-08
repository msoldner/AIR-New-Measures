library(shiny)

shinyUI(fluidPage(
  titlePanel("Dynamically generated user interface components"),
  fluidRow(
    
    column(3, wellPanel(
      selectInput("input_type", "Option",
                  c("descriptive", "tabular"
                  )
      )
    )),
    
    column(3, wellPanel(
      # This outputs the dynamic UI component
      uiOutput("ui")
    )),
    
    column(3, wellPanel(
           h4("Output"),
           verbatimTextOutput("summary")
    )
    )
  )
))
