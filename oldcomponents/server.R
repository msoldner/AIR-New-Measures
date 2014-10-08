library(shiny)

# Rely on the 'WorldPhones' dataset in the datasets
# package (which generally comes preloaded).
library(datasets)

load("data.Rdata")
d.in <- d.in2

catvars.z <- subset(data.frame(val = sapply(d.in2, is.factor)), val == TRUE)
catvars <- row.names(catvars.z)

contvars.z <- subset(data.frame(val = sapply(d.in2, is.factor)), val == FALSE)
contvars <- row.names(contvars.z)

# Define a server for the Shiny app
shinyServer(function(input, output) {
  
  output$ui <- renderUI({sidebarPanel(
    selectInput("continuous", "Continuous variables:", 
                choices=contvars),
    
    hr(),
    
    selectInput("categorical", "Categorical variables:", 
                choices=catvars),
    
    hr(),
    
    
    helpText("Data from AT&T (1961) The World's Telephones.")  
  
  )
  })
    
  output$summary <- renderPrint({
  
    summary(d.in[, input$continuous]) 
    
   
    })
  
  output$table <- renderPrint({
    
    table(d.in[, input$categorical]) 
      
  })
  
  
})