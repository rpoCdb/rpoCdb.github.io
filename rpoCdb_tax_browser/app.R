library(shiny)
library(DT)
library(readr)
library(httr)
library(dplyr)
library(memoise)
library(cachem)
library(shinycssloaders)

# Cache setup
load_github_data <- memoise(function() {
  github_url <- "https://raw.githubusercontent.com/rpoCdb/rpoCdb.github.io/main/taxonomy_browser_shinyApp/mock_tax.txt"
  
  tryCatch({
    response <- GET(github_url)
    stop_for_status(response)
    read_tsv(content(response, as = "text"))
  }, error = function(e) {
    showNotification(paste("Error loading data:", e$message), type = "error")
    NULL
  })
}, cache = cachem::cache_mem(max_age = 3600))

ui <- fluidPage(
  titlePanel(
    div(
      img(src = "https://raw.githubusercontent.com/rpoCdb/rpoCdatabase/main/img/rpocdb_logo.png",
          height = 55, width = 145, style = "margin-right: 15px;"),
      " Taxonomy Browser"
    )
  ),
  sidebarLayout(
    sidebarPanel(
      numericInput("rows", "Rows per page", 10, min = 1),
      selectizeInput("columns", "Columns to display", choices = NULL, multiple = TRUE),
      textInput("filter", "Filter (dplyr syntax)", placeholder = "e.g., price > 100"),
      downloadButton("download", "Download Filtered Data")
    ),
    mainPanel(
      withSpinner(DTOutput("table")),
      verbatimTextOutput("summary")
    )
  )
)

server <- function(input, output, session) {
  data <- reactive({
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message = "Loading data", value = 0.3)
    
    df <- load_github_data()
    
    if (!is.null(df)) {
      df <- df %>%
        mutate(across(where(is.character), as.factor)) %>%
        droplevels()
    }
    
    progress$set(value = 1)
    df
  })
  
  filtered_data <- reactive({
    df <- data()
    req(df)
    
    if (!is.null(input$columns)) {
      df <- df %>% select(all_of(input$columns))
    }
    
    if (input$filter != "") {
      filter_expr <- try(parse(text = input$filter), silent = TRUE)
      if (!inherits(filter_expr, "try-error")) {
        df <- df %>% filter(!!filter_expr)
      }
    }
    
    return(df)
  })
  
  output$table <- renderDT({
    req(filtered_data())
    datatable(
      filtered_data(),
      extensions = c('Buttons', 'Scroller'),
      options = list(
        serverSide = TRUE,
        processing = TRUE,
        pageLength = input$rows,
        scrollX = TRUE,
        scrollY = 500,
        deferRender = TRUE,
        scroller = TRUE,
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel', 'print'),
        stateSave = TRUE
      ),
      selection = 'none',
      rownames = FALSE,
      filter = 'top'
    )
  })
  
  output$summary <- renderPrint({
    req(filtered_data())
    summary(filtered_data())
  })
  
  output$download <- downloadHandler(
    filename = function() {
      paste0("rpoCdb_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(filtered_data(), file, row.names = FALSE)
    }
  )
}

shinyApp(ui, server)