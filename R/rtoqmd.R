#' Convert R Script to Quarto Markdown
#'
#' This function converts an R script to Quarto markdown format.
#' It recognizes RStudio code sections with different levels:
#' - ## Title #### creates a level 2 header
#' - ### Title ==== creates a level 3 header
#' - #### Title ---- creates a level 4 header
#' Regular comments are converted to plain text.
#' Code blocks are wrapped in standard R code chunks. The YAML header includes
#' \code{execute: eval: false} and \code{execute: echo: true} options for static
#' documentation purposes, and \code{embed-resources: true} to create self-contained
#' HTML files. See \url{https://quarto.org/docs/output-formats/html-basics.html#self-contained}.
#'
#' @param input_file Path to the input R script file
#' @param output_file Path to the output Quarto markdown file (optional, defaults to same name with .qmd extension)
#' @param title Title for the Quarto document (default: "My title")
#' @param author Author name (default: "Your name")
#' @param format Output format (default: "html")
#' @param render Logical, whether to render the .qmd file to HTML after creation (default: TRUE)
#' @param open_html Logical, whether to open the HTML file in browser after rendering (default: FALSE, only used if render = TRUE)
#' @param code_fold Logical, whether to fold code blocks in HTML output (default: FALSE)
#' @return Invisibly returns NULL. Creates a .qmd file and optionally renders it to HTML.
#' @importFrom utils browseURL
#' @importFrom cli cli_alert_success cli_alert_info cli_alert_danger cli_alert_warning
#' @export
#' @examples
#' \dontrun{
#' # Use example file included in package
#' example_file <- system.file("examples", "example.R", package = "quartify")
#' 
#' # Convert and render to HTML
#' rtoqmd(example_file, "output.qmd")
#' 
#' # Convert only, without rendering
#' rtoqmd(example_file, "output.qmd", render = FALSE)
#' }
rtoqmd <- function(input_file, output_file = NULL, 
                   title = "My title", 
                   author = "Your name",
                   format = "html",
                   render = TRUE,
                   open_html = FALSE,
                   code_fold = FALSE) {
  
  # Check if input file exists
  if (!file.exists(input_file)) {
    cli::cli_alert_danger("Input file does not exist: {.file {input_file}}")
    stop("Input file does not exist: ", input_file, call. = FALSE)
  }
  
  # Set output file if not provided
  if (is.null(output_file)) {
    output_file <- sub("\\.R$", ".qmd", input_file)
  }
  
  # Read the R script
  lines <- readLines(input_file, warn = FALSE)
  
  # Initialize output
  output <- character()
  
  # Add YAML header
  output <- c(output, "---")
  output <- c(output, paste0('title: "', title, '"'))
  output <- c(output, paste0('author: "', author, '"'))
  output <- c(output, paste0('format:'))
  output <- c(output, paste0('  ', format, ':'))
  output <- c(output, "    embed-resources: true")
  output <- c(output, paste0("    code-fold: ", tolower(as.character(code_fold))))
  output <- c(output, "toc: true")
  output <- c(output, "toc-title: Sommaire")
  output <- c(output, "toc-depth: 4")
  output <- c(output, "toc-location: left")
  output <- c(output, "execute: ")
  output <- c(output, "  eval: false")
  output <- c(output, "  echo: true")
  output <- c(output, "output:")
  output <- c(output, "  html_document:")
  output <- c(output, "  number_sections: TRUE")
  output <- c(output, paste0('  output-file: ', sub("\\.qmd$", ".html", basename(output_file))))
  output <- c(output, "---")
  output <- c(output, "")
  
  # Process lines
  i <- 1
  code_block <- character()
  comment_block <- character()
  
  while (i <= length(lines)) {
    line <- lines[i]
    
    # Skip roxygen comments completely
    if (grepl("^#'", line)) {
      # Ignore roxygen comments - do nothing
      
    # Check if line is a RStudio code section
    } else if (grepl("^##\\s+.+\\s+#{4,}\\s*$", line)) {
      # Level 2: ## Title ####
      # Flush any accumulated code
      if (length(code_block) > 0) {
        output <- c(output, "```{r}")
        output <- c(output, code_block)
        output <- c(output, "```")
        output <- c(output, "")
        code_block <- character()
      }
      
      # Flush any accumulated comments
      if (length(comment_block) > 0) {
        output <- c(output, comment_block)
        output <- c(output, "")
        comment_block <- character()
      }
      
      # Extract title and create level 2 header
      title_text <- sub("^##\\s+(.+?)\\s+#{4,}\\s*$", "\\1", line)
      output <- c(output, paste0("## ", title_text))
      output <- c(output, "")
      
    } else if (grepl("^###\\s+.+\\s+={4,}\\s*$", line)) {
      # Level 3: ### Title ====
      # Flush any accumulated code
      if (length(code_block) > 0) {
        output <- c(output, "```{r}")
        output <- c(output, code_block)
        output <- c(output, "```")
        output <- c(output, "")
        code_block <- character()
      }
      
      # Flush any accumulated comments
      if (length(comment_block) > 0) {
        output <- c(output, comment_block)
        output <- c(output, "")
        comment_block <- character()
      }
      
      # Extract title and create level 3 header
      title_text <- sub("^###\\s+(.+?)\\s+={4,}\\s*$", "\\1", line)
      output <- c(output, paste0("### ", title_text))
      output <- c(output, "")
      
    } else if (grepl("^####\\s+.+\\s+-{4,}\\s*$", line)) {
      # Level 4: #### Title ----
      # Flush any accumulated code
      if (length(code_block) > 0) {
        output <- c(output, "```{r}")
        output <- c(output, code_block)
        output <- c(output, "```")
        output <- c(output, "")
        code_block <- character()
      }
      
      # Flush any accumulated comments
      if (length(comment_block) > 0) {
        output <- c(output, comment_block)
        output <- c(output, "")
        comment_block <- character()
      }
      
      # Extract title and create level 4 header
      title_text <- sub("^####\\s+(.+?)\\s+-{4,}\\s*$", "\\1", line)
      output <- c(output, paste0("#### ", title_text))
      output <- c(output, "")
      
    } else if (grepl("^#", line)) {
      # Regular comment
      # Flush any accumulated code
      if (length(code_block) > 0) {
        output <- c(output, "```{r}")
        output <- c(output, code_block)
        output <- c(output, "```")
        output <- c(output, "")
        code_block <- character()
      }
      
      # Convert to plain text and accumulate in comment block
      comment_text <- sub("^#\\s*", "", line)
      if (nzchar(comment_text)) {
        comment_block <- c(comment_block, comment_text)
      }
      
    } else if (grepl("^\\s*$", line)) {
      # Empty line
      # Flush any accumulated comments
      if (length(comment_block) > 0) {
        output <- c(output, comment_block)
        output <- c(output, "")
        comment_block <- character()
      }
      
    } else {
      # Code line
      # Flush any accumulated comments
      if (length(comment_block) > 0) {
        output <- c(output, comment_block)
        output <- c(output, "")
        comment_block <- character()
      }
      # Accumulate code
      code_block <- c(code_block, line)
    }
    
    i <- i + 1
  }
  
  # Flush any remaining comments
  if (length(comment_block) > 0) {
    output <- c(output, comment_block)
  }
  
  # Flush any remaining code
  if (length(code_block) > 0) {
    output <- c(output, "```{r}")
    output <- c(output, code_block)
    output <- c(output, "```")
  }
  
  # Write output file
  writeLines(output, output_file)
  
  cli::cli_alert_success("Quarto markdown file created: {.file {output_file}}")
  
  # Render to HTML if requested
  if (render) {
    cat("Rendering Quarto document to HTML...\n")
    
    # Check if quarto is available
    quarto_available <- tryCatch({
      system("quarto --version", intern = TRUE, ignore.stderr = TRUE)
      TRUE
    }, error = function(e) {
      FALSE
    })
    
    if (!quarto_available) {
      cli::cli_alert_warning("Quarto is not installed or not available in PATH")
      cli::cli_alert_info("Install Quarto from {.url https://quarto.org/docs/get-started/}")
      return(invisible(NULL))
    }
    
    # Render the document
    html_file <- sub("\\.qmd$", ".html", output_file)
    
    tryCatch({
      system2("quarto", args = c("render", shQuote(output_file)), 
              stdout = TRUE, stderr = TRUE)
      
      cli::cli_alert_success("HTML file created: {.file {html_file}}")
      
      # Open HTML file if requested
      if (open_html && file.exists(html_file)) {
        cli::cli_alert_info("Opening HTML file in browser")
        browseURL(html_file)
      }
      
    }, error = function(e) {
      cli::cli_alert_danger("Failed to render Quarto document: {e$message}")
    })
  }
  
  invisible(NULL)
}
