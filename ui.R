library(shiny)

shinyUI(fluidPage(
  titlePanel("Dynamically generated user interface components"),
  fluidRow(
    
    column(3, wellPanel(
      selectInput("input_type", "Option",
                  c("descriptive", "oneway", "twoway"
                  )
      ),
      submitButton("Select type")
    )),
    
    column(3, wellPanel(
      # This outputs the dynamic UI component
      uiOutput("ui"),
      submitButton("Select variables")
    )),
    
    column(6, wellPanel(
           h4("Output"),
           verbatimTextOutput("summary")
    )
    )
  )
))
