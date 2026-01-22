library(shiny)
library(tidyr)
library(dplyr)
library(DT)

ui <- fluidPage(
  titlePanel("Data Format Converter: Wide ⟷ Long"),
  
  sidebarLayout(
    sidebarPanel(
      h4("1. Upload Data"),
      fileInput("file", "Choose CSV File",
                accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      
      checkboxInput("header", "First row is header", TRUE),
      
      hr(),
      
      h4("2. Select Conversion"),
      radioButtons("conversion", "Convert:",
                   choices = c("Wide to Long" = "wide_to_long",
                              "Long to Wide" = "long_to_wide")),
      
      conditionalPanel(
        condition = "input.conversion == 'wide_to_long'",
        h5("Wide to Long Options"),
        textInput("id_cols_w2l", "ID Columns (comma-separated)", 
                  placeholder = "e.g., id, subject"),
        textInput("value_cols_w2l", "Value Columns (comma-separated)",
                  placeholder = "e.g., time1, time2, time3"),
        textInput("names_to", "New Variable Name Column", value = "variable"),
        textInput("values_to", "New Values Column", value = "value")
      ),
      
      conditionalPanel(
        condition = "input.conversion == 'long_to_wide'",
        h5("Long to Wide Options"),
        textInput("id_cols_l2w", "ID Columns (comma-separated)",
                  placeholder = "e.g., id, subject"),
        textInput("names_from", "Names From Column",
                  placeholder = "e.g., timepoint"),
        textInput("values_from", "Values From Column",
                  placeholder = "e.g., score")
      ),
      
      hr(),
      
      actionButton("convert", "Convert Data", class = "btn-primary"),
      
      hr(),
      
      downloadButton("download", "Download Converted Data")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Original Data",
                 h4("Uploaded Data Preview"),
                 DTOutput("original_table")),
        tabPanel("Converted Data",
                 h4("Converted Data Preview"),
                 DTOutput("converted_table")),
        tabPanel("Code Snippet",
                 h4("R Code to Reproduce Conversion"),
                 verbatimTextOutput("code_snippet"))
      )
    )
  )
)

server <- function(input, output, session) {
  
  # Store uploaded data
  data_original <- reactiveVal(NULL)
  data_converted <- reactiveVal(NULL)
  code_snippet <- reactiveVal("")
  
  # Load data
  observeEvent(input$file, {
    req(input$file)
    
    df <- read.csv(input$file$datapath, header = input$header,
                   stringsAsFactors = FALSE)
    data_original(df)
    data_converted(NULL)  # Reset converted data
  })
  
  # Display original data
  output$original_table <- renderDT({
    req(data_original())
    datatable(data_original(), options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Convert data
  observeEvent(input$convert, {
    req(data_original())
    
    df <- data_original()
    
    tryCatch({
      if (input$conversion == "wide_to_long") {
        # Parse inputs
        id_cols <- trimws(strsplit(input$id_cols_w2l, ",")[[1]])
        value_cols <- trimws(strsplit(input$value_cols_w2l, ",")[[1]])
        
        # Convert
        converted <- df %>%
          pivot_longer(
            cols = all_of(value_cols),
            names_to = input$names_to,
            values_to = input$values_to
          )
        
        # Generate code snippet
        code <- sprintf(
          "library(tidyr)\nlibrary(dplyr)\n\n# Convert wide to long\nlong_data <- wide_data %%>%%\n  pivot_longer(\n    cols = c(%s),\n    names_to = \"%s\",\n    values_to = \"%s\"\n  )",
          paste0("\"", value_cols, "\"", collapse = ", "),
          input$names_to,
          input$values_to
        )
        
      } else {
        # Long to Wide
        id_cols <- trimws(strsplit(input$id_cols_l2w, ",")[[1]])
        
        converted <- df %>%
          pivot_wider(
            id_cols = all_of(id_cols),
            names_from = input$names_from,
            values_from = input$values_from
          )
        
        # Generate code snippet
        code <- sprintf(
          "library(tidyr)\nlibrary(dplyr)\n\n# Convert long to wide\nwide_data <- long_data %%>%%\n  pivot_wider(\n    id_cols = c(%s),\n    names_from = \"%s\",\n    values_from = \"%s\"\n  )",
          paste0("\"", id_cols, "\"", collapse = ", "),
          input$names_from,
          input$values_from
        )
      }
      
      data_converted(converted)
      code_snippet(code)
      
    }, error = function(e) {
      showNotification(
        paste("Error:", e$message),
        type = "error",
        duration = 10
      )
    })
  })
  
  # Display converted data
  output$converted_table <- renderDT({
    req(data_converted())
    datatable(data_converted(), options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Display code snippet
  output$code_snippet <- renderText({
    req(code_snippet())
    code_snippet()
  })
  
  # Download converted data
  output$download <- downloadHandler(
    filename = function() {
      paste0("converted_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      req(data_converted())
      write.csv(data_converted(), file, row.names = FALSE)
    }
  )
}

shinyApp(ui = ui, server = server)
