#' Convert R Script to Quarto Markdown
#'
#' This function converts an R script to Quarto markdown format (.qmd), enabling you to leverage
#' all modern Quarto features. Unlike \code{knitr::spin()} which generates R Markdown (.Rmd),
#' \code{rtoqmd()} creates Quarto documents with access to advanced publishing capabilities,
#' modern themes, native callouts, Mermaid diagrams, and the full Quarto ecosystem.
#' 
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
#' @section Mermaid Diagrams:
#' The function supports Mermaid diagrams for flowcharts, sequence diagrams, and visualizations.
#' Mermaid chunks start with a special comment, followed by options and diagram content.
#' Options use hash-pipe syntax and are converted to percent-pipe in the Quarto output.
#' Diagram content should not start with hash symbols. The chunk ends at a blank line or comment.
#' Supported types: flowchart, sequence, class, state, etc. See example file in inst/examples/example_mermaid.R.
#'
#' @section Tabsets:
#' Create tabbed content panels for interactive navigation between related content.
#' Use hash tabset to start a tabset container, then define individual tabs with hash tab - Title.
#' Each tab can contain text, code, and other content. The tabset closes automatically when a new section starts.
#' Example: hash tabset, hash tab - Plot A, code or text content, hash tab - Plot B, more content.
#'
#' @param input_file Path to the input R script file
#' @param output_file Path to the output Quarto markdown file (optional, defaults to same name with .qmd extension)
#' @param title Title for the Quarto document (default: "My title"). Can be overridden by \code{# Title :} or \code{# Titre :} in the script
#' @param author Author name (default: "Your name"). Can be overridden by \code{# Author :} or \code{# Auteur :} in the script
#' @param format Output format - always "html" (parameter kept for backward compatibility)
#' @param theme Quarto theme for HTML output (default: NULL uses Quarto's default). See \url{https://quarto.org/docs/output-formats/html-themes.html} for available themes (e.g., "cosmo", "flatly", "darkly", "solar", "united")
#' @param render_html Logical, whether to render the .qmd file to HTML after creation (default: TRUE)
#' @param output_html_file Path to the output HTML file (optional, defaults to same name as .qmd file with .html extension)
#' @param open_html Logical, whether to open the HTML file in browser after rendering (default: FALSE, only used if render_html = TRUE)
#' @param code_fold Logical, whether to fold code blocks in HTML output (default: FALSE)
#' @param number_sections Logical, whether to number sections automatically in the output (default: TRUE)
#' @param lang Language for interface elements like table of contents title - "en" or "fr" (default: "en")
#' @param show_source_lines Logical, whether to add comments indicating original line numbers from the source R script at the beginning of each code chunk (default: TRUE). This helps maintain traceability between the documentation and the source code.
#' @param use_styler Logical, whether to apply styler code formatting and show differences in tabsets (default: FALSE). Requires the styler package to be installed.
#' @param use_lintr Logical, whether to run lintr code quality checks and display issues in tabsets (default: FALSE). Requires the lintr package to be installed.
#' @param apply_styler Logical, whether to apply styler formatting directly to the source R script file (default: FALSE). If TRUE, the input file will be modified with styled code. Requires use_styler = TRUE to take effect.
#' @returns Invisibly returns NULL. Creates a .qmd file and optionally renders it to HTML.
#' @importFrom utils browseURL
#' @importFrom cli cli_alert_success cli_alert_info cli_alert_danger cli_alert_warning
#' @export
#' @examples
#' \donttest{
#' # Use example file included in package
#' example_file <- system.file("examples", "example.R", package = "quartify")
#' 
#' # Convert and render to HTML (output in temp directory)
#' output_qmd <- file.path(tempdir(), "output.qmd")
#' rtoqmd(example_file, output_qmd)
#' 
#' # Convert only, without rendering
#' rtoqmd(example_file, output_qmd, render_html = FALSE)
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
#' output_meta <- file.path(tempdir(), "output_with_metadata.qmd")
#' rtoqmd(script_with_metadata, output_meta)
#' 
#' # Example with code quality checks (requires styler and lintr packages)
#' script_with_style_issues <- tempfile(fileext = ".R")
#' writeLines(c(
#'   "# Script with style issues",
#'   "",
#'   "x = 3  # Should use <- instead of =",
#'   "y <- 2",
#'   "",
#'   "z <- 10"
#' ), script_with_style_issues)
#' 
#' # Convert with styler formatting
#' output_styled <- file.path(tempdir(), "output_styled.qmd")
#' rtoqmd(script_with_style_issues, output_styled, use_styler = TRUE)
#' 
#' # Convert with both styler and lintr
#' output_quality <- file.path(tempdir(), "output_quality.qmd")
#' rtoqmd(script_with_style_issues, output_quality, 
#'        use_styler = TRUE, use_lintr = TRUE)
#' }

rtoqmd <- function(input_file, output_file = NULL, 
                   title = "My title", 
                   author = "Your name",
                   format = "html",
                   theme = NULL,
                   render_html = TRUE,
                   output_html_file = NULL,
                   open_html = FALSE,
                   code_fold = FALSE,
                   number_sections = TRUE,
                   lang = "en",
                   show_source_lines = TRUE,
                   use_styler = FALSE,
                   use_lintr = FALSE,
                   apply_styler = FALSE) {
  
  # Check if input file exists
  if (!file.exists(input_file)) {
    cli::cli_alert_danger("Input file does not exist: {.file {input_file}}")
    stop("Input file does not exist: ", input_file, call. = FALSE)
  }
  
  # Apply styler to the source file if requested
  if (apply_styler && use_styler) {
    if (requireNamespace("styler", quietly = TRUE)) {
      cli::cli_alert_info("Applying styler to source file: {.file {input_file}}")
      tryCatch({
        styler::style_file(input_file)
        cli::cli_alert_success("Source file styled successfully")
      }, error = function(e) {
        cli::cli_alert_warning("Failed to style source file: {e$message}")
      })
    } else {
      cli::cli_alert_warning("styler package not available. Install it with: install.packages('styler')")
    }
  } else if (apply_styler && !use_styler) {
    cli::cli_alert_warning("apply_styler requires use_styler = TRUE to take effect")
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
  in_tabset <- FALSE
  in_tab <- FALSE
  tab_content <- character()
  tab_title <- ""
  tabs <- list()
  
  # Track line numbers for code chunks
  code_chunk_start <- NULL
  code_chunk_lines <- integer()
  
  # Helper function to create code chunk with optional line numbers and code quality checks
  flush_code_block <- function(code, chunk_lines, add_line_info) {
    if (length(code) == 0) return(character())
    
    # Check code quality if requested
    quality_check <- check_code_quality(code, use_styler, use_lintr, 
                                       chunk_id = paste(chunk_lines, collapse = "-"))
    
    # If apply_styler is TRUE, don't create tabsets (source file already modified)
    # If there are style changes or lint issues, create a tabset
    if (!apply_styler && (quality_check$has_style_changes || quality_check$has_lint_issues)) {
      # Build tabset with line info in original code tab
      result <- character()
      result <- c(result, "::: {.panel-tabset}")
      result <- c(result, "")
      
      # Original code tab
      result <- c(result, "## Original Code")
      result <- c(result, "")
      result <- c(result, "```{r}")
      if (add_line_info && length(chunk_lines) > 0) {
        line_label <- if (lang == "fr") "Lignes" else "Lines"
        line_range <- if (min(chunk_lines) == max(chunk_lines)) {
          paste0("# ", line_label, " ", min(chunk_lines))
        } else {
          paste0("# ", line_label, " ", min(chunk_lines), "-", max(chunk_lines))
        }
        result <- c(result, line_range)
      }
      result <- c(result, code)
      result <- c(result, "```")
      result <- c(result, "")
      
      # Styled code tab (if changes detected)
      if (quality_check$has_style_changes) {
        result <- c(result, "## Styled Code")
        result <- c(result, "")
        result <- c(result, "```{r}")
        if (add_line_info && length(chunk_lines) > 0) {
          line_label <- if (lang == "fr") "Lignes" else "Lines"
          line_range <- if (min(chunk_lines) == max(chunk_lines)) {
            paste0("# ", line_label, " ", min(chunk_lines))
          } else {
            paste0("# ", line_label, " ", min(chunk_lines), "-", max(chunk_lines))
          }
          result <- c(result, line_range)
        }
        result <- c(result, quality_check$styled_code)
        result <- c(result, "```")
        result <- c(result, "")
      }
      
      # Lint issues tab (if issues detected)
      if (quality_check$has_lint_issues) {
        result <- c(result, "## Lint Issues")
        result <- c(result, "")
        for (msg in quality_check$lint_messages) {
          result <- c(result, paste0("- ", msg))
        }
        result <- c(result, "")
      }
      
      # Close tabset
      result <- c(result, ":::")
      result <- c(result, "")
      
      return(result)
    } else {
      # No issues, generate standard chunk
      result <- "```{r}"
      if (add_line_info && length(chunk_lines) > 0) {
        line_label <- if (lang == "fr") "Lignes" else "Lines"
        line_range <- if (min(chunk_lines) == max(chunk_lines)) {
          paste0("# ", line_label, " ", min(chunk_lines))
        } else {
          paste0("# ", line_label, " ", min(chunk_lines), "-", max(chunk_lines))
        }
        result <- c(result, line_range)
      }
      result <- c(result, code, "```", "")
      return(result)
    }
  }
  
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
      
      # Close any open tabset first
      if (in_tabset) {
        if (in_tab) {
          # Flush code into last tab
          if (length(code_block) > 0) {
            tab_code_chunk <- flush_code_block(code_block, code_chunk_lines, show_source_lines)
            tab_content <- c(tab_content, "", tab_code_chunk)
            code_block <- character()
            code_chunk_start <- NULL
            code_chunk_lines <- integer()
          }
          if (length(tab_content) > 0) {
            tabs[[length(tabs) + 1]] <- list(title = tab_title, content = tab_content)
          }
        }
        
        if (length(tabs) > 0) {
          output <- c(output, "::: {.panel-tabset}")
          output <- c(output, "")
          for (tab in tabs) {
            output <- c(output, paste0("## ", tab$title))
            output <- c(output, "")
            output <- c(output, tab$content)
            output <- c(output, "")
          }
          output <- c(output, ":::")
          output <- c(output, "")
        }
        
        in_tabset <- FALSE
        in_tab <- FALSE
        tabs <- list()
        tab_content <- character()
        tab_title <- ""
      }
      
      # Flush any accumulated code
      if (length(code_block) > 0) {
        output <- c(output, flush_code_block(code_block, code_chunk_lines, show_source_lines))
        code_block <- character()
        code_chunk_start <- NULL
        code_chunk_lines <- integer()
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
        output <- c(output, flush_code_block(code_block, code_chunk_lines, show_source_lines))
        code_block <- character()
        code_chunk_start <- NULL
        code_chunk_lines <- integer()
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
        output <- c(output, flush_code_block(code_block, code_chunk_lines, show_source_lines))
        code_block <- character()
        code_chunk_start <- NULL
        code_chunk_lines <- integer()
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
      
    } else if (grepl("^#\\|\\s*mermaid\\s*$", line, ignore.case = TRUE)) {
      # Mermaid chunk start: #| mermaid
      # Flush any accumulated code
      if (length(code_block) > 0) {
        output <- c(output, flush_code_block(code_block, code_chunk_lines, show_source_lines))
        code_block <- character()
        code_chunk_start <- NULL
        code_chunk_lines <- integer()
      }
      
      # Flush any accumulated comments
      if (length(comment_block) > 0) {
        output <- c(output, comment_block)
        output <- c(output, "")
        comment_block <- character()
      }
      
      # Start collecting mermaid chunk
      # Look ahead for options and content
      i <- i + 1
      mermaid_options <- character()
      mermaid_content <- character()
      
      # Collect options (lines starting with #| )
      while (i <= length(lines) && grepl("^#\\|", lines[i])) {
        option_line <- sub("^#\\|\\s*", "", lines[i])
        # Convert #| eval:true to %%| eval: true
        mermaid_options <- c(mermaid_options, paste0("%%| ", option_line))
        i <- i + 1
      }
      
      # Collect mermaid content (non-comment, non-empty lines)
      while (i <= length(lines) && !grepl("^\\s*$", lines[i]) && !grepl("^#", lines[i])) {
        mermaid_content <- c(mermaid_content, lines[i])
        i <- i + 1
      }
      
      # Write mermaid chunk
      output <- c(output, "```{mermaid}")
      output <- c(output, mermaid_options)
      output <- c(output, mermaid_content)
      output <- c(output, "```")
      output <- c(output, "")
      
      # Continue from current position (don't increment i again)
      next
      
    } else if (grepl("^#\\s*tabset\\s*$", line, ignore.case = TRUE)) {
      # Tabset start: # tabset
      # Flush any accumulated code
      if (length(code_block) > 0) {
        output <- c(output, flush_code_block(code_block, code_chunk_lines, show_source_lines))
        code_block <- character()
        code_chunk_start <- NULL
        code_chunk_lines <- integer()
      }
      
      # Flush any accumulated comments
      if (length(comment_block) > 0) {
        output <- c(output, comment_block)
        output <- c(output, "")
        comment_block <- character()
      }
      
      in_tabset <- TRUE
      in_tab <- FALSE
      tabs <- list()
      tab_content <- character()
      tab_title <- ""
      
    } else if (grepl("^#\\s*tab\\s*-\\s*(.+)\\s*$", line, ignore.case = TRUE) && in_tabset) {
      # Tab definition: # tab - Title
      # Save previous tab if exists (with its content and code)
      if (in_tab) {
        # Flush any accumulated code into tab_content
        if (length(code_block) > 0) {
          tab_code_chunk <- flush_code_block(code_block, code_chunk_lines, show_source_lines)
          tab_content <- c(tab_content, "", tab_code_chunk)
          code_block <- character()
          code_chunk_start <- NULL
          code_chunk_lines <- integer()
        }
        
        if (length(tab_content) > 0) {
          tabs[[length(tabs) + 1]] <- list(title = tab_title, content = tab_content)
        }
      }
      
      # Extract tab title
      tab_match <- regmatches(line, regexec("^#\\s*tab\\s*-\\s*(.+)\\s*$", line, ignore.case = TRUE))[[1]]
      tab_title <- trimws(tab_match[2])
      tab_content <- character()
      in_tab <- TRUE
      
    } else if (grepl("^#\\s*callout-(note|tip|warning|caution|important)(?:\\s*-\\s*(.+))?\\s*$", line, ignore.case = TRUE)) {
      # Callout start: # callout-tip - Title
      # Flush any accumulated code
      if (length(code_block) > 0) {
        output <- c(output, flush_code_block(code_block, code_chunk_lines, show_source_lines))
        code_block <- character()
        code_chunk_start <- NULL
        code_chunk_lines <- integer()
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
      } else if (in_tab) {
        # If we're in a tab, accumulate the content
        comment_text <- sub("^#\\s*", "", line)
        if (nzchar(comment_text)) {
          tab_content <- c(tab_content, comment_text)
        } else {
          # Empty comment line in tab - add blank line
          tab_content <- c(tab_content, "")
        }
      } else if (in_tabset) {
        # If we're in a tabset but not in a tab yet, ignore comments
        # (waiting for # tab - Title declaration)
      } else {
        # Flush any accumulated code
        if (length(code_block) > 0) {
          output <- c(output, flush_code_block(code_block, code_chunk_lines, show_source_lines))
          code_block <- character()
          code_chunk_start <- NULL
          code_chunk_lines <- integer()
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
      } else if (in_tab) {
        # Empty line within a tab - just add blank line to tab content
        tab_content <- c(tab_content, "")
      } else if (in_tabset) {
        # Empty line in tabset but not in tab - ignore it (waiting for first tab)
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
      
      if (in_tab) {
        # If we're in a tab, accumulate code in code_block first
        # We'll flush it when we hit next tab or end of tabset
        if (length(code_block) == 0) code_chunk_start <- i
        code_chunk_lines <- c(code_chunk_lines, i)
        code_block <- c(code_block, line)
      } else if (in_tabset && !in_tab) {
        # Code before any tab starts = end tabset
        # End tabset before code
        if (length(tabs) > 0) {
          output <- c(output, "::: {.panel-tabset}")
          output <- c(output, "")
          for (tab in tabs) {
            output <- c(output, paste0("## ", tab$title))
            output <- c(output, "")
            output <- c(output, tab$content)
            output <- c(output, "")
          }
          output <- c(output, ":::")
          output <- c(output, "")
        }
        
        # Reset tabset state
        in_tabset <- FALSE
        in_tab <- FALSE
        tabs <- list()
        tab_content <- character()
        tab_title <- ""
        
        # Flush any accumulated comments
        if (length(comment_block) > 0) {
          output <- c(output, comment_block)
          output <- c(output, "")
          comment_block <- character()
        }
        # Accumulate code
        if (length(code_block) == 0) code_chunk_start <- i
        code_chunk_lines <- c(code_chunk_lines, i)
        code_block <- c(code_block, line)
      } else {
        # Normal code - not in tabset or callout
        # Flush any accumulated comments
        if (length(comment_block) > 0) {
          output <- c(output, comment_block)
          output <- c(output, "")
          comment_block <- character()
        }
        # Accumulate code
        if (length(code_block) == 0) code_chunk_start <- i
        code_chunk_lines <- c(code_chunk_lines, i)
        code_block <- c(code_block, line)
      }
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
  
  # Flush any remaining tabset
  if (in_tabset) {
    # Save last tab if exists
    if (in_tab) {
      # Flush any accumulated code into last tab
      if (length(code_block) > 0) {
        tab_code_chunk <- flush_code_block(code_block, code_chunk_lines, show_source_lines)
        tab_content <- c(tab_content, "", tab_code_chunk)
        code_block <- character()
        code_chunk_start <- NULL
        code_chunk_lines <- integer()
      }
      
      if (length(tab_content) > 0) {
        tabs[[length(tabs) + 1]] <- list(title = tab_title, content = tab_content)
      }
    }
    
    # Write tabset
    if (length(tabs) > 0) {
      output <- c(output, "::: {.panel-tabset}")
      output <- c(output, "")
      for (tab in tabs) {
        output <- c(output, paste0("## ", tab$title))
        output <- c(output, "")
        output <- c(output, tab$content)
        output <- c(output, "")
      }
      output <- c(output, ":::")
      output <- c(output, "")
    }
  }
  
  # Flush any remaining comments
  if (length(comment_block) > 0) {
    output <- c(output, comment_block)
  }
  
  # Flush any remaining code
  if (length(code_block) > 0) {
    output <- c(output, flush_code_block(code_block, code_chunk_lines, show_source_lines))
  }
  
  # Write output file
  writeLines(output, output_file)
  
  cli::cli_alert_success("Quarto markdown file created: {.file {output_file}}")
  
  # Render to HTML if requested
  if (render_html) {
    message("Rendering Quarto document to HTML...")
    
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
    
    # Determine HTML output file path and prepare render arguments
    if (is.null(output_html_file)) {
      html_file <- sub("\\.qmd$", ".html", output_file)
      render_args <- c("render", shQuote(output_file))
    } else {
      html_file <- output_html_file
      # Get absolute paths
      qmd_dir <- dirname(normalizePath(output_file, winslash = "/", mustWork = FALSE))
      output_dir_abs <- normalizePath(dirname(html_file), winslash = "/", mustWork = FALSE)
      output_name <- basename(html_file)
      
      # Create output directory if it doesn't exist
      if (!dir.exists(output_dir_abs)) {
        dir.create(output_dir_abs, recursive = TRUE, showWarnings = FALSE)
        if (!dir.exists(output_dir_abs)) {
          cli::cli_alert_danger("Failed to create output directory: {.file {output_dir_abs}}")
          return(invisible(NULL))
        }
      }
      
      # Quarto's --output-dir works best with relative paths from the .qmd location
      # Calculate relative path manually
      qmd_parts <- strsplit(qmd_dir, "/")[[1]]
      out_parts <- strsplit(output_dir_abs, "/")[[1]]
      
      # Find common prefix
      common_len <- 0
      for (i in seq_along(qmd_parts)) {
        if (i <= length(out_parts) && qmd_parts[i] == out_parts[i]) {
          common_len <- i
        } else {
          break
        }
      }
      
      # Build relative path
      if (common_len == length(qmd_parts)) {
        # Output dir is inside or same as qmd dir
        output_dir_rel <- paste(out_parts[(common_len + 1):length(out_parts)], collapse = "/")
        if (output_dir_rel == "") output_dir_rel <- "."
      } else {
        # Need to go up directories
        ups <- length(qmd_parts) - common_len
        downs <- out_parts[(common_len + 1):length(out_parts)]
        output_dir_rel <- paste(c(rep("..", ups), downs), collapse = "/")
      }
      
      # Update html_file to use absolute path for checking later
      html_file <- file.path(output_dir_abs, output_name)
      
      render_args <- c("render", shQuote(output_file), 
                      "--output-dir", shQuote(output_dir_rel),
                      "-o", output_name)
    }
    
    tryCatch({
      # Quarto needs to run from the directory where the .qmd file is located
      old_wd <- getwd()
      qmd_directory <- dirname(normalizePath(output_file, winslash = "/", mustWork = FALSE))
      setwd(qmd_directory)
      
      # Ensure we restore the working directory even if there's an error
      on.exit(setwd(old_wd), add = TRUE)
      
      result <- system2("quarto", args = render_args, 
                       stdout = TRUE, stderr = TRUE)
      
      # Debug: show what Quarto returned
      status_code <- attr(result, "status")
      if (is.null(status_code)) status_code <- 0
      
      # Check if render was successful
      if (status_code != 0) {
        cli::cli_alert_danger("Failed to render Quarto document (exit status: {status_code})")
        cli::cli_alert_info("Command: quarto {paste(render_args, collapse = ' ')}")
        if (length(result) > 0) {
          cli::cli_alert_info("Output:")
          message(paste(result, collapse = "\n"))
        }
        return(invisible(NULL))
      }
      
      # Wait a bit for file system to sync (especially on Windows)
      Sys.sleep(0.5)
      
      # Check if file exists at expected location
      if (!file.exists(html_file)) {
        cli::cli_alert_danger("HTML file was not created: {.file {html_file}}")
        cli::cli_alert_info("Command: quarto {paste(render_args, collapse = ' ')}")
        # Check if file was created elsewhere
        alt_location <- sub("\\.qmd$", ".html", output_file)
        if (file.exists(alt_location)) {
          cli::cli_alert_info("HTML file found at default location instead: {.file {alt_location}}")
        }
        return(invisible(NULL))
      }
      
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
