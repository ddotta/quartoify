#' Install quartify RStudio Snippets
#'
#' Installs useful RStudio snippets for working with quartify. These snippets
#' help you quickly insert common structures when writing R scripts that will
#' be converted to Quarto documents.
#'
#' The following snippets are installed:
#'
#' - **header**: Insert a standard R script header with Title, Author, Date, and Description
#' - **callout**: Insert a Quarto callout structure
#' - **mermaid**: Insert a Mermaid diagram chunk
#' - **tabset**: Insert a tabset structure
#'
#' @details
#' The snippets are installed in your RStudio snippets file for R
#' (`~/.R/snippets/r.snippets` on Unix/Mac or
#' `%APPDATA%/RStudio/snippets/r.snippets` on Windows).
#'
#' If you already have custom snippets, this function will append the quartify
#' snippets to your existing file, avoiding duplicates.
#'
#' After installation, restart RStudio or reload the window for the snippets
#' to become available. Then, simply type the snippet name (e.g., `header`)
#' and press Tab to insert the template.
#'
#' @param backup Logical. If TRUE (default), creates a backup of your existing
#'   snippets file before modifying it.
#'
#' @return Invisibly returns the path to the snippets file.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Install quartify snippets
#' install_quartify_snippets()
#'
#' # Install without backup
#' install_quartify_snippets(backup = FALSE)
#' }
install_quartify_snippets <- function(backup = TRUE) {
  
  # Define the snippets content
  snippets <- '
# quartify snippets

snippet header
	# Title : ${1:Title}
	#
	# Author : ${2:Author}
	#
	# Date : ${3:`r Sys.Date()`}
	#
	# Description : ${4:Description}
	#

snippet callout
	# callout-${1:note} - ${2:Title}
	# ${0}

snippet mermaid
	#| mermaid
	#| eval: true
	${0}

snippet tabset
	# tabset
	# tab - ${1:Tab Title}
	# ${0}
'
  
  # Get the RStudio snippets directory
  if (.Platform$OS.type == "windows") {
    snippets_dir <- file.path(Sys.getenv("APPDATA"), "RStudio", "snippets")
  } else {
    snippets_dir <- file.path(Sys.getenv("HOME"), ".R", "snippets")
  }
  
  # Create directory if it doesn't exist
  if (!dir.exists(snippets_dir)) {
    dir.create(snippets_dir, recursive = TRUE)
    message("Created snippets directory: ", snippets_dir)
  }
  
  snippets_file <- file.path(snippets_dir, "r.snippets")
  
  # Check if file exists and backup if requested
  if (file.exists(snippets_file)) {
    # Read existing content
    existing_content <- readLines(snippets_file, warn = FALSE)
    
    # Create backup if requested
    if (backup) {
      backup_file <- paste0(snippets_file, ".backup.", format(Sys.time(), "%Y%m%d_%H%M%S"))
      file.copy(snippets_file, backup_file)
      message("Created backup: ", backup_file)
    }
    
    # Check if quartify snippets already exist
    if (any(grepl("# quartify snippets", existing_content, fixed = TRUE))) {
      message("quartify snippets already installed in: ", snippets_file)
      message("To update, manually remove the existing quartify snippets section and run this function again.")
      return(invisible(snippets_file))
    }
    
    # Append new snippets after existing content
    # Add blank line separator if file doesn't end with blank line
    if (length(existing_content) > 0 && existing_content[length(existing_content)] != "") {
      cat("\n", file = snippets_file, append = TRUE)
    }
    cat(snippets, file = snippets_file, append = TRUE)
    message("Appended quartify snippets to existing file: ", snippets_file)
    
  } else {
    # Create new file
    cat(snippets, file = snippets_file)
    message("Created new snippets file: ", snippets_file)
  }
  
  message("\nSnippets installed successfully!")
  message("Please restart RStudio to use the new snippets.")
  message("\nAvailable snippets:")
  message("  - header  : R script header template")
  message("  - callout : Quarto callout structure")
  message("  - mermaid : Mermaid diagram chunk")
  message("  - tabset  : Tabset structure")
  message("\nType the snippet name and press Tab to use it.")
  
  invisible(snippets_file)
}
