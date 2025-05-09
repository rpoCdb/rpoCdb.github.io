library(shiny)
library(DT)
library(readr)
library(httr)

ui <- fluidPage(
  titlePanel("Browse TSV Data from GitHub"),
  sidebarLayout(
    sidebarPanel(
      helpText("Data is loaded directly from GitHub repository."),
      numericInput("rows", "Rows per page", 10, min = 1),
      selectizeInput("columns", "Columns to display", choices = NULL, multiple = TRUE),
      textInput("filter", "Filter (dplyr syntax)", placeholder = "e.g., price > 100"),
      downloadButton("download", "Download Filtered Data")
    ),
    mainPanel(
      DTOutput("table"),
      verbatimTextOutput("summary")
    )
  )
)

server <- function(input, output, session) {
  # Function to load data from GitHub
  load_github_data <- function() {
    # Replace with your actual GitHub raw TSV file URL
    github_url <- "https://raw.githubusercontent.com/username/repository/main/data.tsv"
    
    tryCatch({
      # Download and read the TSV file
      response <- GET(github_url)
      stop_for_status(response)
      
      # Read TSV content
      data <- read_tsv(content(response, as = "text"))
      return(data)
    }, error = function(e) {
      showNotification(paste("Error loading data:", e$message), type = "error")
      return(NULL)
    })
  }
  
  # Reactive value to store the loaded data
  data <- reactiveVal(NULL)
  
  # Load data when app starts
  observe({
    showNotification("Loading data from GitHub...", duration = NULL)
    loaded_data <- load_github_data()
    removeNotification()
    
    if (!is.null(loaded_data)) {
      data(loaded_data)
      updateSelectizeInput(session, "columns", choices = names(loaded_data), selected = names(loaded_data))
    }
  })
  
  # Filtered data based on user inputs
  filtered_data <- reactive({
    df <- data()
    req(df)
    
    # Apply column selection
    if (!is.null(input$columns)) {
      df <- df %>% select(all_of(input$columns))
    }
    
    # Apply filter if provided
    if (input$filter != "") {
      filter_expr <- try(parse(text = input$filter), silent = TRUE)
      if (!inherits(filter_expr, "try-error")) {
        df <- df %>% filter(!!filter_expr)
      }
    }
    
    return(df)
  })
  
  # Render the data table
  output$table <- renderDT({
    req(filtered_data())
    datatable(
      filtered_data(),
      extensions = c('Buttons', 'Scroller'),
      options = list(
        pageLength = input$rows,
        scrollX = TRUE,
        scrollY = 500,
        scroller = TRUE,
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel', 'print')
      )
    )
  })
  
  # Render summary statistics
  output$summary <- renderPrint({
    req(filtered_data())
    summary(filtered_data())
  })
  
  # Download handler
  output$download <- downloadHandler(
    filename = function() {
      paste0("filtered_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(filtered_data(), file, row.names = FALSE)
    }
  )
}

shinyApp(ui, server)