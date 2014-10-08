library(shiny)

# Rely on the 'WorldPhones' dataset in the datasets
# package (which generally comes preloaded).
library(datasets)

# Define the overall UI
shinyUI(
  
  # Use a fluid Bootstrap layout
  fluidPage(    
    
    # Give the page a title
    titlePanel("Telephones by region"),
    
    # Generate a row with a sidebar
    sidebarLayout(      
      
      # Define the sidebar with one input
     uiOutput("ui"),
      
      # Create a spot for the barplot
      mainPanel(
        h4("Summary"),
        verbatimTextOutput("summary")  
      )
      
    )
  )
)