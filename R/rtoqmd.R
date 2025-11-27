#' Convert R Script to Quarto Markdown
#'
#' This function converts an R script to Quarto markdown format.
#' It recognizes RStudio code sections with different levels:
#' - ## Title #### creates a level 2 header
#' - ### Title ==== creates a level 3 header
#' - #### Title ---- creates a level 4 header
#' Regular comments are converted to plain text.
#' Code blocks are wrapped in non-executable code chunks (\code{\{.r\}} syntax)
#' for static documentation purposes.
#'
#' @param input_file Path to the input R script file
#' @param output_file Path to the output Quarto markdown file (optional, defaults to same name with .qmd extension)
#' @param title Title for the Quarto document (default: "My title")
#' @param author Author name (default: "Damien Dotta")
#' @param format Output format (default: "html")
#' @param render Logical, whether to render the .qmd file to HTML after creation (default: TRUE)
#' @param open_html Logical, whether to open the HTML file in browser after rendering (default: TRUE, only used if render = TRUE)
#' @return Invisibly returns NULL. Creates a .qmd file and optionally renders it to HTML.
#' @importFrom utils browseURL
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
                   author = "Damien Dotta",
                   format = "html",
                   render = TRUE,
                   open_html = TRUE) {
  
  # Check if input file exists
  if (!file.exists(input_file)) {
    stop("Input file does not exist: ", input_file)
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
  output <- c(output, paste0('format: ', format))
  output <- c(output, "toc: true")
  output <- c(output, "toc-title: Sommaire")
  output <- c(output, "toc-depth: 4")
  output <- c(output, "toc-location: left")
  output <- c(output, "output:")
  output <- c(output, "  html_document:")
  output <- c(output, "  number_sections: TRUE")
  output <- c(output, paste0('  output-file: ', sub("\\.qmd$", ".html", basename(output_file))))
  output <- c(output, "---")
  output <- c(output, "")
  
  # Process lines
  i <- 1
  code_block <- character()
  
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
        output <- c(output, "```{.r}")
        output <- c(output, code_block)
        output <- c(output, "```")
        output <- c(output, "")
        code_block <- character()
      }
      
      # Extract title and create level 2 header
      title_text <- sub("^##\\s+(.+?)\\s+#{4,}\\s*$", "\\1", line)
      output <- c(output, paste0("## ", title_text))
      output <- c(output, "")
      
    } else if (grepl("^###\\s+.+\\s+={4,}\\s*$", line)) {
      # Level 3: ### Title ====
      # Flush any accumulated code
      if (length(code_block) > 0) {
        output <- c(output, "```{.r}")
        output <- c(output, code_block)
        output <- c(output, "```")
        output <- c(output, "")
        code_block <- character()
      }
      
      # Extract title and create level 3 header
      title_text <- sub("^###\\s+(.+?)\\s+={4,}\\s*$", "\\1", line)
      output <- c(output, paste0("### ", title_text))
      output <- c(output, "")
      
    } else if (grepl("^####\\s+.+\\s+-{4,}\\s*$", line)) {
      # Level 4: #### Title ----
      # Flush any accumulated code
      if (length(code_block) > 0) {
        output <- c(output, "```{.r}")
        output <- c(output, code_block)
        output <- c(output, "```")
        output <- c(output, "")
        code_block <- character()
      }
      
      # Extract title and create level 4 header
      title_text <- sub("^####\\s+(.+?)\\s+-{4,}\\s*$", "\\1", line)
      output <- c(output, paste0("#### ", title_text))
      output <- c(output, "")
      
    } else if (grepl("^#", line)) {
      # Regular comment
      # Flush any accumulated code
      if (length(code_block) > 0) {
        output <- c(output, "```{.r}")
        output <- c(output, code_block)
        output <- c(output, "```")
        output <- c(output, "")
        code_block <- character()
      }
      
      # Convert to plain text
      comment_text <- sub("^#\\s*", "", line)
      if (nzchar(comment_text)) {
        output <- c(output, comment_text)
        output <- c(output, "")
      }
      
    } else if (grepl("^\\s*$", line)) {
      # Empty line - just skip it in code accumulation
      if (length(code_block) > 0) {
        # Don't add empty lines within code blocks
      }
      
    } else {
      # Code line - accumulate
      code_block <- c(code_block, line)
    }
    
    i <- i + 1
  }
  
  # Flush any remaining code
  if (length(code_block) > 0) {
    output <- c(output, "```{.r}")
    output <- c(output, code_block)
    output <- c(output, "```")
  }
  
  # Write output file
  writeLines(output, output_file)
  
  message("Quarto markdown file created: ", output_file)
  
  # Render to HTML if requested
  if (render) {
    message("Rendering Quarto document to HTML...")
    
    # Check if quarto is available
    quarto_available <- tryCatch({
      system("quarto --version", intern = TRUE, ignore.stderr = TRUE)
      TRUE
    }, error = function(e) {
      FALSE
    })
    
    if (!quarto_available) {
      warning("Quarto is not installed or not available in PATH. Skipping rendering.\n",
              "Install Quarto from https://quarto.org/docs/get-started/")
      return(invisible(NULL))
    }
    
    # Render the document
    html_file <- sub("\\.qmd$", ".html", output_file)
    
    tryCatch({
      system2("quarto", args = c("render", shQuote(output_file)), 
              stdout = TRUE, stderr = TRUE)
      
      message("HTML file created: ", html_file)
      
      # Open HTML file if requested
      if (open_html && file.exists(html_file)) {
        message("Opening HTML file in browser...")
        browseURL(html_file)
      }
      
    }, error = function(e) {
      warning("Failed to render Quarto document: ", e$message)
    })
  }
  
  invisible(NULL)
}
