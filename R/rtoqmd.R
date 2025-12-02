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
#' @section Metadata Detection:
#' The function automatically extracts metadata from special comment lines in your R script:
#' \itemize{
#'   \item \strong{Title}: Use \code{# Title : Your Title} or \code{# Titre : Votre Titre}
#'   \item \strong{Author}: Use \code{# Author : Your Name} or \code{# Auteur : Votre Nom}
#'   \item \strong{Date}: Use \code{# Date : YYYY-MM-DD}
#'   \item \strong{Description}: Use \code{# Description : Your description} (also accepts \code{# Purpose} or \code{# Objectif})
#' }
#' If metadata is found in the script, it will override the corresponding function parameters.
#' These metadata lines are removed from the document body and only appear in the YAML header.
#' 
#' The Description field supports multi-line content. Continuation lines should start with \code{#}
#' followed by spaces and the text. The description ends at an empty line or a line without \code{#}.
#'
#' @section Callouts:
#' The function converts special comment patterns into Quarto callouts.
#' Callouts are special blocks that highlight important information.
#' Supported callout types: \code{note}, \code{tip}, \code{warning}, \code{caution}, \code{important}.
#' 
#' Syntax:
#' \itemize{
#'   \item \strong{With title}: \code{# callout-tip - Your Title}
#'   \item \strong{Without title}: \code{# callout-tip}
#' }
#' 
#' All subsequent comment lines become the callout content until an empty line or code is encountered.
#' 
#' Example in R script:
#' \preformatted{
#' # callout-note - Important Note
#' # This is the content of the note.
#' # It can span multiple lines.
#' 
#' x <- 1
#' }
#' 
#' Becomes in Quarto:
#' \preformatted{
#' ::: {.callout-note title="Important Note"}
#' This is the content of the note.
#' It can span multiple lines.
#' :::
#' }
#'
#' @param input_file Path to the input R script file
#' @param output_file Path to the output Quarto markdown file (optional, defaults to same name with .qmd extension)
#' @param title Title for the Quarto document (default: "My title"). Can be overridden by \code{# Title :} or \code{# Titre :} in the script
#' @param author Author name (default: "Your name"). Can be overridden by \code{# Author :} or \code{# Auteur :} in the script
#' @param format Output format - always "html" (parameter kept for backward compatibility)
#' @param theme Quarto theme for HTML output (default: NULL uses Quarto's default). See \url{https://quarto.org/docs/output-formats/html-themes.html} for available themes (e.g., "cosmo", "flatly", "darkly", "solar", "united")
#' @param render Logical, whether to render the .qmd file to HTML after creation (default: TRUE)
#' @param open_html Logical, whether to open the HTML file in browser after rendering (default: FALSE, only used if render = TRUE)
#' @param code_fold Logical, whether to fold code blocks in HTML output (default: FALSE)
#' @param number_sections Logical, whether to number sections automatically in the output (default: TRUE)
#' @param lang Language for interface elements like table of contents title - "en" or "fr" (default: "en")
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
#' 
#' # Example with metadata in the R script:
#' # Create a script with metadata
#' script_with_metadata <- tempfile(fileext = ".R")
#' writeLines(c(
#'   "# Title : My Analysis",
#'   "# Author : Jane Doe", 
#'   "# Date : 2025-11-28",
#'   "# Description : Analyze iris dataset",
#'   "",
#'   "library(dplyr)",
#'   "iris %>% head()"
#' ), script_with_metadata)
#' 
#' # Convert - metadata will override function parameters
#' rtoqmd(script_with_metadata, "output_with_metadata.qmd")
#' }
rtoqmd <- function(input_file, output_file = NULL, 
                   title = "My title", 
                   author = "Your name",
                   format = "html",
                   theme = NULL,
                   render = TRUE,
                   open_html = FALSE,
                   code_fold = FALSE,
                   number_sections = TRUE,
                   lang = "en") {
  
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
  
  # Extract metadata from comments in the script
  metadata <- list(
    title = title,
    author = author,
    date = NULL,
    description = NULL
  )
  
  # Track which lines contain metadata (to skip them later)
  metadata_lines <- integer()
  in_description <- FALSE
  
  for (j in seq_along(lines)) {
    line <- lines[j]
    
    # Check for Title / Titre
    if (grepl("^#\\s*(Title|Titre)\\s*:\\s*(.+)$", line, ignore.case = TRUE)) {
      extracted <- sub("^#\\s*(Title|Titre)\\s*:\\s*(.+)$", "\\2", line, ignore.case = TRUE)
      metadata$title <- trimws(extracted)
      metadata_lines <- c(metadata_lines, j)
      in_description <- FALSE
    }
    # Check for Author / Auteur
    else if (grepl("^#\\s*(Author|Auteur)\\s*:\\s*(.+)$", line, ignore.case = TRUE)) {
      extracted <- sub("^#\\s*(Author|Auteur)\\s*:\\s*(.+)$", "\\2", line, ignore.case = TRUE)
      metadata$author <- trimws(extracted)
      metadata_lines <- c(metadata_lines, j)
      in_description <- FALSE
    }
    # Check for Date
    else if (grepl("^#\\s*Date\\s*:\\s*(.+)$", line, ignore.case = TRUE)) {
      extracted <- sub("^#\\s*Date\\s*:\\s*(.+)$", "\\1", line, ignore.case = TRUE)
      metadata$date <- trimws(extracted)
      metadata_lines <- c(metadata_lines, j)
      in_description <- FALSE
    }
    # Check for Description / Objectif / Purpose
    else if (grepl("^#\\s*(Description|Objectif|Purpose)\\s*:\\s*(.+)$", line, ignore.case = TRUE)) {
      extracted <- sub("^#\\s*(Description|Objectif|Purpose)\\s*:\\s*(.+)$", "\\2", line, ignore.case = TRUE)
      metadata$description <- trimws(extracted)
      metadata_lines <- c(metadata_lines, j)
      in_description <- TRUE
    }
    # Check if we're continuing a description on the next line
    else if (in_description && grepl("^#\\s+(.+)$", line)) {
      # This is a continuation of the description
      continuation <- sub("^#\\s+(.+)$", "\\1", line)
      metadata$description <- paste(metadata$description, trimws(continuation))
      metadata_lines <- c(metadata_lines, j)
    }
    # Empty comment line or line without # stops description continuation
    else if (in_description && (grepl("^#\\s*$", line) || !grepl("^#", line))) {
      in_description <- FALSE
    }
  }
  
  # Initialize output
  output <- character()
  
  # Add YAML header
  output <- c(output, "---")
  output <- c(output, paste0('title: "', metadata$title, '"'))
  output <- c(output, paste0('author: "', metadata$author, '"'))
  if (!is.null(metadata$date)) {
    output <- c(output, paste0('date: "', metadata$date, '"'))
  }
  if (!is.null(metadata$description)) {
    output <- c(output, paste0('description: "', metadata$description, '"'))
  }
  output <- c(output, paste0('format:'))
  output <- c(output, paste0('  ', format, ':'))
  if (!is.null(theme) && format == "html") {
    output <- c(output, paste0("    theme: ", theme))
  }
  output <- c(output, "    embed-resources: true")
  output <- c(output, paste0("    code-fold: ", tolower(as.character(code_fold))))
  output <- c(output, paste0("    number-sections: ", tolower(as.character(number_sections))))
  output <- c(output, "toc: true")
  toc_title <- if (lang == "fr") "Sommaire" else "Table of contents"
  output <- c(output, paste0("toc-title: ", toc_title))
  output <- c(output, "toc-depth: 4")
  output <- c(output, "toc-location: left")
  output <- c(output, "execute: ")
  output <- c(output, "  eval: false")
  output <- c(output, "  echo: true")
  output <- c(output, "output:")
  output <- c(output, "  html_document:")
  output <- c(output, paste0('  output-file: ', sub("\\.qmd$", ".html", basename(output_file))))
  output <- c(output, "---")
  output <- c(output, "")
  
  # Process lines
  i <- 1
  code_block <- character()
  comment_block <- character()
  in_callout <- FALSE
  callout_content <- character()
  callout_type <- ""
  callout_title <- ""
  
  while (i <= length(lines)) {
    line <- lines[i]
    
    # Skip metadata lines
    if (i %in% metadata_lines) {
      # Ignore metadata lines - do nothing
      
    # Skip roxygen comments completely
    } else if (grepl("^#'", line)) {
      # Ignore roxygen comments - do nothing
      
    # Check if line is a RStudio code section
    } else if (grepl("^##\\s+.+\\s+[#=-]{4,}\\s*$", line)) {
      # Level 2: ## Title #### or ## Title ==== or ## Title ----
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
      
      # Extract title and create level 2 header (remove trailing symbols)
      title_text <- sub("^##\\s+(.+?)\\s+[#=-]{4,}\\s*$", "\\1", line)
      output <- c(output, paste0("## ", title_text))
      output <- c(output, "")
      
    } else if (grepl("^###\\s+.+\\s+[#=-]{4,}\\s*$", line)) {
      # Level 3: ### Title ==== or ### Title ---- or ### Title ####
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
      
      # Extract title and create level 3 header (remove trailing symbols)
      title_text <- sub("^###\\s+(.+?)\\s+[#=-]{4,}\\s*$", "\\1", line)
      output <- c(output, paste0("### ", title_text))
      output <- c(output, "")
      
    } else if (grepl("^####\\s+.+\\s+[#=-]{4,}\\s*$", line)) {
      # Level 4: #### Title ---- or #### Title ==== or #### Title ####
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
      
      # Extract title and create level 4 header (remove trailing symbols)
      title_text <- sub("^####\\s+(.+?)\\s+[#=-]{4,}\\s*$", "\\1", line)
      output <- c(output, paste0("#### ", title_text))
      output <- c(output, "")
      
    } else if (grepl("^#\\s*callout-(note|tip|warning|caution|important)(?:\\s*-\\s*(.+))?\\s*$", line, ignore.case = TRUE)) {
      # Callout start: # callout-tip - Title
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
      
      # Extract callout type and optional title
      callout_match <- regmatches(line, regexec("^#\\s*callout-(note|tip|warning|caution|important)(?:\\s*-\\s*(.+))?\\s*$", line, ignore.case = TRUE))[[1]]
      callout_type <- tolower(callout_match[2])
      callout_title <- if (length(callout_match) >= 3 && nzchar(callout_match[3])) trimws(callout_match[3]) else ""
      
      in_callout <- TRUE
      callout_content <- character()
      
    } else if (grepl("^#", line)) {
      # Regular comment
      if (in_callout) {
        # If we're in a callout, accumulate the content
        comment_text <- sub("^#\\s*", "", line)
        if (nzchar(comment_text)) {
          callout_content <- c(callout_content, comment_text)
        } else {
          # Empty comment line in callout - add blank line
          callout_content <- c(callout_content, "")
        }
      } else {
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
        } else {
          # Empty comment line - add blank line
          comment_block <- c(comment_block, "")
        }
      }
      
    } else if (grepl("^\\s*$", line)) {
      # Empty line
      if (in_callout) {
        # End of callout - write it out
        if (nzchar(callout_title)) {
          output <- c(output, paste0("::: {.callout-", callout_type, ' title="', callout_title, '"}'))
        } else {
          output <- c(output, paste0("::: {.callout-", callout_type, "}"))
        }
        output <- c(output, callout_content)
        output <- c(output, ":::")
        output <- c(output, "")
        
        # Reset callout state
        in_callout <- FALSE
        callout_content <- character()
        callout_type <- ""
        callout_title <- ""
      } else {
        # Flush any accumulated comments
        if (length(comment_block) > 0) {
          output <- c(output, comment_block)
          output <- c(output, "")
          comment_block <- character()
        }
      }
      
    } else {
      # Code line
      if (in_callout) {
        # End callout before code
        if (nzchar(callout_title)) {
          output <- c(output, paste0("::: {.callout-", callout_type, ' title="', callout_title, '"}'))
        } else {
          output <- c(output, paste0("::: {.callout-", callout_type, "}"))
        }
        output <- c(output, callout_content)
        output <- c(output, ":::")
        output <- c(output, "")
        
        # Reset callout state
        in_callout <- FALSE
        callout_content <- character()
        callout_type <- ""
        callout_title <- ""
      }
      
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
  
  # Flush any remaining callout
  if (in_callout) {
    if (nzchar(callout_title)) {
      output <- c(output, paste0("::: {.callout-", callout_type, ' title="', callout_title, '"}'))
    } else {
      output <- c(output, paste0("::: {.callout-", callout_type, "}"))
    }
    output <- c(output, callout_content)
    output <- c(output, ":::")
    output <- c(output, "")
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
