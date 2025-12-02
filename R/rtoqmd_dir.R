#' Convert All R Scripts in a Directory to Quarto Markdown
#'
#' This function recursively searches for all R script files (.R) in a directory
#' and its subdirectories, and converts each one to a Quarto markdown document (.qmd).
#' The output files are created in the same directories as the input files.
#' 
#' Supports all features of \code{\link{rtoqmd}}, including:
#' \itemize{
#'   \item Metadata detection (Title, Author, Date, Description)
#'   \item RStudio section headers
#'   \item Callouts (note, tip, warning, caution, important)
#'   \item Code blocks and comments
#' }
#' 
#' See \code{\link{rtoqmd}} for details on callout syntax and metadata detection.
#'
#' @param dir_path Path to the directory containing R scripts
#' @param title_prefix Optional prefix to add to all document titles (default: NULL)
#' @param author Author name for all documents (default: "Your name")
#' @param format Output format - "html" or "pdf" (default: "html")
#' @param theme Quarto theme for HTML output (default: NULL uses Quarto's default). See \url{https://quarto.org/docs/output-formats/html-themes.html}
#' @param render Logical, whether to render the .qmd files after creation (default: FALSE)
#' @param open_html Logical, whether to open the HTML files in browser after rendering (default: FALSE)
#' @param code_fold Logical, whether to fold code blocks in HTML output (default: FALSE)
#' @param number_sections Logical, whether to number sections automatically (default: TRUE)
#' @param recursive Logical, whether to search subdirectories recursively (default: TRUE)
#' @param pattern Regular expression pattern to filter R files (default: "\\.R$")
#' @param exclude_pattern Optional regular expression pattern to exclude certain files (default: NULL)
#' @return Invisibly returns a data frame with conversion results (file paths and status)
#' @importFrom cli cli_alert_success cli_alert_info cli_alert_warning cli_alert_danger cli_h1 cli_h2
#' @export
#' @examples
#' \dontrun{
#' # Convert all R scripts in a directory
#' rtoqmd_dir("path/to/scripts")
#' 
#' # Convert and render all scripts
#' rtoqmd_dir("path/to/scripts", render = TRUE)
#' 
#' # Convert with custom author and title prefix
#' rtoqmd_dir("path/to/scripts", 
#'            title_prefix = "Analysis: ",
#'            author = "Data Team")
#' 
#' # Exclude certain files (e.g., test files)
#' rtoqmd_dir("path/to/scripts", 
#'            exclude_pattern = "test_.*\\.R$")
#' 
#' # Non-recursive (only current directory)
#' rtoqmd_dir("path/to/scripts", recursive = FALSE)
#' }
rtoqmd_dir <- function(dir_path,
                       title_prefix = NULL,
                       author = "Your name",
                       format = "html",
                       theme = NULL,
                       render = FALSE,
                       open_html = FALSE,
                       code_fold = FALSE,
                       number_sections = TRUE,
                       recursive = TRUE,
                       pattern = "\\.R$",
                       exclude_pattern = NULL) {
  
  # Check if directory exists
  if (!dir.exists(dir_path)) {
    cli::cli_alert_danger("Directory does not exist: {.file {dir_path}}")
    stop("Directory does not exist: ", dir_path, call. = FALSE)
  }
  
  # Get absolute path
  dir_path <- normalizePath(dir_path, winslash = "/")
  
  cli::cli_h1("Converting R Scripts to Quarto Markdown")
  cli::cli_alert_info("Searching directory: {.file {dir_path}}")
  cli::cli_alert_info("Recursive: {recursive}")
  
  # Find all R files
  r_files <- list.files(
    path = dir_path,
    pattern = pattern,
    recursive = recursive,
    full.names = TRUE,
    ignore.case = TRUE
  )
  
  # Apply exclusion pattern if provided
  if (!is.null(exclude_pattern)) {
    excluded <- grepl(exclude_pattern, r_files, ignore.case = TRUE)
    if (any(excluded)) {
      cli::cli_alert_info("Excluding {sum(excluded)} file{?s} matching pattern: {exclude_pattern}")
      r_files <- r_files[!excluded]
    }
  }
  
  # Check if any files found
  if (length(r_files) == 0) {
    cli::cli_alert_warning("No R script files found in directory")
    return(invisible(data.frame(
      file = character(),
      status = character(),
      output = character(),
      stringsAsFactors = FALSE
    )))
  }
  
  cli::cli_alert_success("Found {length(r_files)} R script{?s} to convert")
  cli::cli_h2("Converting files...")
  
  # Initialize results tracking
  results <- data.frame(
    file = character(length(r_files)),
    status = character(length(r_files)),
    output = character(length(r_files)),
    stringsAsFactors = FALSE
  )
  
  # Convert each file
  for (i in seq_along(r_files)) {
    r_file <- r_files[i]
    
    # Generate output filename
    qmd_file <- sub("\\.R$", ".qmd", r_file, ignore.case = TRUE)
    
    # Extract title from filename if no prefix
    base_title <- tools::file_path_sans_ext(basename(r_file))
    title <- if (!is.null(title_prefix)) {
      paste0(title_prefix, base_title)
    } else {
      base_title
    }
    
    # Store file info
    results$file[i] <- r_file
    results$output[i] <- qmd_file
    
    # Convert the file
    tryCatch({
      rtoqmd(
        input_file = r_file,
        output_file = qmd_file,
        title = title,
        author = author,
        format = format,
        theme = theme,
        render = render,
        open_html = open_html,
        code_fold = code_fold,
        number_sections = number_sections
      )
      
      results$status[i] <- "success"
      
    }, error = function(e) {
      cli::cli_alert_danger("Failed to convert: {.file {basename(r_file)}}")
      cli::cli_alert_info("Error: {e$message}")
      results$status[i] <- paste0("error: ", e$message)
    })
  }
  
  # Summary
  cli::cli_h2("Conversion Summary")
  n_success <- sum(results$status == "success")
  n_failed <- length(r_files) - n_success
  
  cli::cli_alert_success("Successfully converted: {n_success} file{?s}")
  if (n_failed > 0) {
    cli::cli_alert_danger("Failed: {n_failed} file{?s}")
  }
  
  invisible(results)
}
