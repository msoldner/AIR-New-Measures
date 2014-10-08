library(shiny)

load("data.Rdata")
d.in <- d.in2

catvars.z <- subset(data.frame(val = sapply(d.in2, is.factor)), val == TRUE)
catvars <- row.names(catvars.z)

contvars.z <- subset(data.frame(val = sapply(d.in2, is.factor)), val == FALSE)
contvars <- row.names(contvars.z)

# Define a server for the Shiny app

shinyServer(function(input, output) {
  
  output$ui <- renderUI({
    if (is.null(input$input_type))
      return()
    
    
    # Depending on input$input_type, we'll generate a different
    # UI component and send it to the client.
    switch(input$input_type,
           "descriptive" = selectInput("dynamic", "Continuous variables:", 
                                         choices=contvars),
           
           "tabular" = selectInput("dynamic", "Categorical variables:", 
                                     choices=catvars)
    )
  })
  
  
  output$summary <- renderPrint({
  
      # goal here is to route the evaluation of the data based on input_type
    
      if (input$input_type == "descriptive") {
          summary(d.in[, input$dynamic]) 
      } else {
      table(d.in[, input$dynamic]) 
      }
      
      })
  
})