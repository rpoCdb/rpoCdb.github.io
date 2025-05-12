library(shiny)
library(DT)
library(readr)
library(httr)
library(dplyr)
library(memoise)
library(cachem)
library(shinycssloaders)
library(plotly)
library(RColorBrewer)

# Cache setup
load_github_data <- memoise(function() {
  github_url <- "https://raw.githubusercontent.com/rpoCdb/rpoCdb.github.io/main/rpoCdb_tax_browser/mock_tax.txt"
  
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
  title = "rpoCdb Taxonomy Browser",
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
      textInput("filter", "Filter Taxonomy", placeholder = "e.g., Streptococcus"),
      actionButton("reset_filters", "Reset All Filters", icon = icon("refresh")),
      downloadButton("download", "Download Filtered Data"),
      
      # Visualization controls
      tags$hr(),
      h4("Bar Chart Options"),
      selectInput("tax_level", "Taxonomic Level to Visualize:",
                  choices = c("Phylum", "Class", "Order", "Family", "Genus", "Species"),
                  selected = "Genus"),
      sliderInput("top_n", "Number of Top Taxa to Show:",
                  min = 5, max = 50, value = 15),
      checkboxInput("show_others", "Group Others", value = TRUE),
      selectInput("palette", "Color Palette:",
                  choices = c("Set1", "Set2", "Set3", "Paired", "Dark2", "Accent"),
                  selected = "Set2")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Data Table", withSpinner(DTOutput("table"))),
        tabPanel("Taxonomic Distribution", 
                 plotlyOutput("taxaBarChart", height = "600px"),
                 verbatimTextOutput("summary"))
      )
    )
  )
)

server <- function(input, output, session) {
  # Load raw data
  raw_data <- reactive({
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message = "Loading data", value = 0.3)
    
    df <- load_github_data()
    req(df)
    
    # Convert character columns to factors
    df <- df %>%
      mutate(across(where(is.character), as.factor)) %>%
      droplevels()
    
    progress$set(value = 1)
    return(df)
  })
  
  # Create DT proxy
  dt_proxy <- DT::dataTableProxy("table")
  
  # Apply filters
  filtered_data <- reactive({
    df <- raw_data()
    req(df)
    
    # Apply text filter if provided
    if (input$filter != "") {
      # Search all character/factor columns for the filter text
      df <- df %>%
        filter(if_any(where(~is.character(.) | is.factor(.)), 
               ~grepl(input$filter, as.character(.), ignore.case = TRUE)))
    }
    
    return(df)
  })
  
  # Render data table
  output$table <- renderDT({
    df <- filtered_data()
    req(df)
    
    # Show message if no data after filtering
    if (nrow(df) == 0) {
      showNotification("No records match your filter criteria", type = "warning")
    }
    
    datatable(
      df,
      extensions = c('Buttons', 'Scroller'),
      options = list(
        serverSide = FALSE,
        processing = TRUE,
        pageLength = input$rows,
        scrollX = TRUE,
        scrollY = 500,
        deferRender = TRUE,
        scroller = TRUE,
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel', 'print'),
        stateSave = TRUE,
        search = list(search = ifelse(input$filter == "", "", input$filter))
      ),
      selection = 'none',
      rownames = FALSE,
      filter = 'top'
    )
  })
  
  # Bar chart visualization
  output$taxaBarChart <- renderPlotly({
    df <- filtered_data()
    req(df, input$tax_level)
    
    # Check if selected taxonomic level exists
    if (!input$tax_level %in% names(df)) {
      return(plot_ly() %>%
               add_annotations(text = paste("Selected taxonomic level not available in data"),
                              xref = "paper", yref = "paper",
                              x = 0.5, y = 0.5, showarrow = FALSE))
    }
    
    # Prepare data for visualization
    plot_data <- df %>%
      count(!!sym(input$tax_level), name = "Count") %>%
      arrange(desc(Count))
    
    # Handle "Others" grouping
    if (input$show_others && nrow(plot_data) > input$top_n) {
      top_data <- plot_data %>% slice(1:input$top_n)
      others <- plot_data %>% slice((input$top_n+1):n()) %>% 
        summarize(!!sym(input$tax_level) := "Others",
                  Count = sum(Count))
      plot_data <- bind_rows(top_data, others)
    } else {
      plot_data <- plot_data %>% slice(1:min(input$top_n, n()))
    }
    
    # Create color palette
    n_colors <- nrow(plot_data)
    color_pal <- colorRampPalette(brewer.pal(min(8, n_colors), input$palette))(n_colors)
    
    # Create bar chart
    plot_ly(plot_data,
            x = ~reorder(get(input$tax_level), -Count), 
            y = ~Count,
            type = 'bar',
            marker = list(color = color_pal),
            text = ~paste0("<b>", get(input$tax_level), "</b><br>",
                          "Count: ", Count),
            hoverinfo = 'text') %>%
      layout(title = paste("Distribution of", input$tax_level),
             xaxis = list(title = input$tax_level, 
                          categoryorder = "total descending"),
             yaxis = list(title = "Number of Sequences"),
             margin = list(b = 150),  # Increase bottom margin for long labels
             showlegend = FALSE)
  })
  
  # Reset filters handler
  observeEvent(input$reset_filters, {
    updateTextInput(session, "filter", value = "")
    DT::updateSearch(dt_proxy, keywords = list(global = "", columns = rep("", ncol(raw_data()))))
    showNotification("All filters have been reset", type = "message")
  })
  
  # Debug output
  output$debug <- renderPrint({
    df <- raw_data()
    req(df)
    cat("Available columns:", names(df), "\n")
  })
  
  # Summary output
  output$summary <- renderPrint({
    df <- filtered_data()
    req(df)
    summary(df)
  })
  
  # Download handler
  output$download <- downloadHandler(
    filename = function() {
      paste0("rpoCdb_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(filtered_data(), file, row.names = FALSE)
    }
  )
  
  # Update table when filter changes
  observeEvent(input$filter, {
    DT::updateSearch(dt_proxy, 
                    keywords = list(global = input$filter, 
                                   columns = rep("", ncol(raw_data()))))
  })
}

shinyApp(ui, server)