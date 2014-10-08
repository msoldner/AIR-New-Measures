library(shiny)

# Rely on the 'WorldPhones' dataset in the datasets
# package (which generally comes preloaded).
library(datasets)

wd.datapath <- paste0(getwd(),"/data")
wd.init <- getwd()
setwd(wd.datapath)

d.in <- read.table("WorldPhones2.csv", head = TRUE)
setwd(wd.init)

# Define a server for the Shiny app
shinyServer(function(input, output) {
  
  output$ui <- renderUI({sidebarPanel(
    selectInput("region", "Region:", 
                choices=colnames(d.in)),
    
    hr(),
    
    helpText("Data from AT&T (1961) The World's Telephones."),
    
    submitButton("Update View")
    
  )
  })
    
  output$summary <- renderPrint({
  
    summary(d.in[, input$region]) 
  
    })
})