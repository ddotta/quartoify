#' Convert R Script to Quarto Markdown
#'
#' This function converts an R script to Quarto markdown format.
#' Comments starting with # ## to # ###### are converted to markdown headers (levels 2 to 6).
#' Regular comments are converted to plain text.
#' Code blocks are wrapped in code chunks.
#'
#' @param input_file Path to the input R script file
#' @param output_file Path to the output Quarto markdown file (optional, defaults to same name with .qmd extension)
#' @param title Title for the Quarto document (default: "My title")
#' @param author Author name (default: "Damien Dotta")
#' @param format Output format (default: "html")
#' @return NULL (creates output file)
#' @export
#' @examples
#' \dontrun{
#' # Use example file included in package
#' example_file <- system.file("examples", "example.R", package = "quartify")
#' rtoqmd(example_file, "output.qmd")
#' }
rtoqmd <- function(input_file, output_file = NULL, 
                   title = "My title", 
                   author = "Damien Dotta",
                   format = "html") {
  
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
  output <- c(output, "toc-depth: 6")
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
      
    # Check if line is a header comment (# ## or # ###)
    } else if (grepl("^#\\s*#{2,}", line)) {
      # Flush any accumulated code
      if (length(code_block) > 0) {
        output <- c(output, "```{.r}")
        output <- c(output, code_block)
        output <- c(output, "```")
        output <- c(output, "")
        code_block <- character()
      }
      
      # Convert header
      header <- sub("^#\\s*", "", line)
      output <- c(output, header)
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
  invisible(NULL)
}
