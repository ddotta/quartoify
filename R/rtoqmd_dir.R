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
#' @param format Output format - always "html" (parameter kept for backward compatibility)
#' @param theme Quarto theme for HTML output (default: NULL uses Quarto's default). See \url{https://quarto.org/docs/output-formats/html-themes.html}
#' @param render Logical, whether to render the .qmd files after creation (default: FALSE)
#' @param output_html_dir Directory path for HTML output files (optional, defaults to same directory as .qmd files)
#' @param open_html Logical, whether to open the HTML files in browser after rendering (default: FALSE)
#' @param code_fold Logical, whether to fold code blocks in HTML output (default: FALSE)
#' @param number_sections Logical, whether to number sections automatically (default: TRUE)
#' @param recursive Logical, whether to search subdirectories recursively (default: TRUE)
#' @param pattern Regular expression pattern to filter R files (default: "\\.R$")
#' @param exclude_pattern Optional regular expression pattern to exclude certain files (default: NULL)
#' @param create_book Logical, whether to create a Quarto book structure with _quarto.yml (default: NULL, auto-enabled when output_html_dir is specified with render=TRUE)
#' @param book_title Title for the Quarto book (default: "R Scripts Documentation")
#' @param output_dir Output directory for the book (required if create_book=TRUE, default: NULL uses input_dir/output)
#' @param language Language for the documentation ("en" or "fr", default: "en")
#' @returns Invisibly returns a data frame with conversion results (file paths and status)
#' @note Existing .qmd and .html files will be automatically overwritten during generation to ensure fresh output.
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
#' # Create a Quarto book with automatic navigation
#' rtoqmd_dir(
#'   dir_path = "path/to/scripts",
#'   output_html_dir = "path/to/scripts/documentation",
#'   render = TRUE,
#'   author = "Your Name",
#'   book_title = "My R Scripts Documentation",
#'   open_html = TRUE
#' )
#' 
#' # Create a Quarto book in French
#' rtoqmd_dir(
#'   dir_path = "path/to/scripts",
#'   output_html_dir = "path/to/scripts/documentation",
#'   render = TRUE,
#'   author = "Votre Nom",
#'   book_title = "Documentation des Scripts R",
#'   language = "fr"
#' )
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
#' 
#' # Reproducible example with sample scripts
#' example_dir <- system.file("examples", "book_example", package = "quartify")
#' if (example_dir != "") {
#'   rtoqmd_dir(
#'     dir_path = example_dir,
#'     output_html_dir = file.path(example_dir, "documentation"),
#'     render = TRUE,
#'     open_html = TRUE
#'   )
#' }
#' }
rtoqmd_dir <- function(dir_path,
                       title_prefix = NULL,
                       author = "Your name",
                       format = "html",
                       theme = NULL,
                       render = FALSE,
                       output_html_dir = NULL,
                       open_html = FALSE,
                       code_fold = FALSE,
                       number_sections = TRUE,
                       recursive = TRUE,
                       pattern = "\\.R$",
                       exclude_pattern = NULL,
                       create_book = NULL,
                       book_title = "R Scripts Documentation",
                       output_dir = NULL,
                       language = "en") {
  
  # Check if directory exists
  if (!dir.exists(dir_path)) {
    cli::cli_alert_danger("Directory does not exist: {.file {dir_path}}")
    stop("Directory does not exist: ", dir_path, call. = FALSE)
  }
  
  # Get absolute path
  dir_path <- normalizePath(dir_path, winslash = "/")
  
  # Auto-enable book creation if output_html_dir is specified and render is TRUE
  if (is.null(create_book)) {
    create_book <- !is.null(output_html_dir) && render
  }
  
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
  
  # Create HTML output directory if specified and doesn't exist
  if (!is.null(output_html_dir) && !dir.exists(output_html_dir)) {
    dir.create(output_html_dir, recursive = TRUE, showWarnings = FALSE)
    if (!dir.exists(output_html_dir)) {
      cli::cli_alert_danger("Failed to create HTML output directory: {.file {output_html_dir}}")
      return(invisible(data.frame(
        file = character(),
        status = character(),
        output = character(),
        stringsAsFactors = FALSE
      )))
    }
  }
  
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
    
    # Delete existing .qmd file to ensure fresh generation
    if (file.exists(qmd_file)) {
      file.remove(qmd_file)
    }
    
    # Calculate HTML output path if directory specified
    html_file <- if (!is.null(output_html_dir)) {
      html_filename <- sub("\\.qmd$", ".html", basename(qmd_file))
      html_path <- file.path(output_html_dir, html_filename)
      # Delete existing .html file to ensure fresh generation
      if (file.exists(html_path)) {
        file.remove(html_path)
      }
      html_path
    } else {
      NULL
    }
    
    # Convert the file
    # Skip rendering individual files if creating a book (book will render all files)
    render_individual <- render && !create_book
    
    tryCatch({
      rtoqmd(
        input_file = r_file,
        output_file = qmd_file,
        title = title,
        author = author,
        format = format,
        theme = theme,
        render = render_individual,
        output_html_file = html_file,
        open_html = FALSE,  # Never open individual files when creating a book
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
  
  # Create Quarto book if requested
  if (create_book && n_success > 0) {
    cli::cli_h2("Creating Quarto Book")
    
    # Determine book output directory
    book_output_dir <- if (!is.null(output_dir)) {
      output_dir
    } else if (!is.null(output_html_dir)) {
      output_html_dir
    } else {
      file.path(dir_path, "_book")
    }
    
    # Create book output directory if needed
    if (!dir.exists(book_output_dir)) {
      dir.create(book_output_dir, recursive = TRUE, showWarnings = FALSE)
    }
    
    # Get successfully converted qmd files relative to dir_path
    successful_qmd <- results$output[results$status == "success"]
    
    # Build chapter structure respecting directory hierarchy
    chapters <- list()
    for (qmd_file in successful_qmd) {
      rel_path <- gsub(paste0("^", dir_path, "/?"), "", qmd_file)
      rel_path <- gsub("\\\\", "/", rel_path)  # Normalize path separators
      
      # Extract directory structure
      path_parts <- strsplit(rel_path, "/")[[1]]
      
      if (length(path_parts) == 1) {
        # Root level file
        chapters[[length(chapters) + 1]] <- rel_path
      } else {
        # Nested file - create section structure
        dir_name <- path_parts[1]
        
        # Find or create section for this directory
        section_idx <- NULL
        for (i in seq_along(chapters)) {
          if (is.list(chapters[[i]]) && !is.null(names(chapters[[i]])) && 
              names(chapters[[i]])[1] == "part") {
            if (chapters[[i]]$part == dir_name) {
              section_idx <- i
              break
            }
          }
        }
        
        if (is.null(section_idx)) {
          # Create new section
          chapters[[length(chapters) + 1]] <- list(
            part = dir_name,
            chapters = list(rel_path)
          )
        } else {
          # Add to existing section
          chapters[[section_idx]]$chapters[[length(chapters[[section_idx]]$chapters) + 1]] <- rel_path
        }
      }
    }
    
    # Create index.qmd (required for Quarto books)
    index_path <- file.path(dir_path, "index.qmd")
    
    # Navigation text based on language
    nav_text <- if (language == "fr") {
      "Naviguez entre les chapitres en utilisant la barre latérale."
    } else {
      "Navigate through the chapters using the sidebar."
    }
    
    index_content <- paste0(
      "---\n",
      "title: \"Documentation\"\n",
      "author: \"", author, "\"\n",
      "---\n\n",
      "# ", book_title, "\n\n",
      nav_text, "\n"
    )
    writeLines(index_content, index_path)
    cli::cli_alert_success("Created: {.file {index_path}}")
    
    # Create _quarto.yml
    # Calculate relative path from dir_path to book_output_dir
    output_dir_for_yml <- if (startsWith(book_output_dir, dir_path)) {
      # If book_output_dir is inside dir_path, use relative path
      gsub(paste0("^", dir_path, "/?"), "", book_output_dir)
    } else {
      # If outside, use absolute path
      book_output_dir
    }
    
    # Build _quarto.yml content manually to avoid yaml package boolean formatting issues
    quarto_yml_path <- file.path(dir_path, "_quarto.yml")
    
    # Convert booleans to proper YAML literals
    code_fold_yaml <- if (code_fold) "true" else "false"
    number_sections_yaml <- if (number_sections) "true" else "false"
    
    # Build chapters YAML - start with index.qmd
    chapters_yaml <- "    - index.qmd\n"
    for (chapter in chapters) {
      if (is.character(chapter)) {
        chapters_yaml <- paste0(chapters_yaml, "    - ", chapter, "\n")
      } else if (is.list(chapter) && !is.null(chapter$part)) {
        chapters_yaml <- paste0(chapters_yaml, "    - part: \"", chapter$part, "\"\n")
        chapters_yaml <- paste0(chapters_yaml, "      chapters:\n")
        for (subchapter in chapter$chapters) {
          chapters_yaml <- paste0(chapters_yaml, "        - ", subchapter, "\n")
        }
      }
    }
    
    # Build complete YAML
    yaml_content <- paste0(
      "project:\n",
      "  type: book\n",
      "  output-dir: ", output_dir_for_yml, "\n",
      "\n",
      "book:\n",
      "  title: \"", book_title, "\"\n",
      "  author: \"", author, "\"\n",
      "  chapters:\n",
      chapters_yaml,
      "\n",
      "format:\n",
      "  html:\n",
      "    theme: ", if (!is.null(theme)) theme else "cosmo", "\n",
      "    code-fold: ", code_fold_yaml, "\n",
      "    number-sections: ", number_sections_yaml, "\n"
    )
    
    writeLines(yaml_content, quarto_yml_path)
    cli::cli_alert_success("Created: {.file {quarto_yml_path}}")
    
    # Render book if requested
    if (render) {
      cli::cli_alert_info("Rendering Quarto book...")
      tryCatch({
        old_wd <- getwd()
        setwd(dir_path)
        
        # Render with quiet mode to suppress warnings
        quarto::quarto_render(quiet = TRUE)
        
        setwd(old_wd)
        
        cli::cli_alert_success("Book rendered to: {.file {book_output_dir}}")
        
        # Open index.html if requested
        if (open_html) {
          index_html <- file.path(book_output_dir, "index.html")
          if (file.exists(index_html)) {
            utils::browseURL(index_html)
          }
        }
      }, error = function(e) {
        setwd(old_wd)
        cli::cli_alert_danger("Failed to render book: {e$message}")
      })
    }
  }
  
  invisible(results)
}
