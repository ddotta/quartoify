#' Convert Active R Script to Quarto Markdown
#'
#' RStudio add-in that converts the currently active R script in the editor
#' to a Quarto markdown document.
#'
#' @export
rtoqmd_addin <- function() {
  # Get the active document context
  context <- rstudioapi::getSourceEditorContext()
  
  # Get the path of the active document
  input_path <- context$path
  
  # Check if the document has been saved
  if (input_path == "") {
    rstudioapi::showDialog(
      title = "Unsaved Document",
      message = "Please save your R script before converting it to Quarto markdown."
    )
    return(invisible())
  }
  
  # Check if it's an R file
  if (!grepl("\\.R$", input_path, ignore.case = TRUE)) {
    rstudioapi::showDialog(
      title = "Invalid File Type",
      message = "The active document is not an R script file (.R)."
    )
    return(invisible())
  }
  
  # Propose output filename
  output_path <- sub("\\.R$", ".qmd", input_path, ignore.case = TRUE)
  
  # Ask user for confirmation and customization
  result <- rstudioapi::showPrompt(
    title = "Convert to Quarto",
    message = "Output file path:",
    default = output_path
  )
  
  # If user cancelled
  if (is.null(result)) {
    return(invisible())
  }
  
  output_path <- result
  
  # Ask for title
  title <- rstudioapi::showPrompt(
    title = "Document Title",
    message = "Enter the document title:",
    default = "My Analysis"
  )
  
  if (is.null(title)) {
    title <- "My Analysis"
  }
  
  # Ask for author
  author <- rstudioapi::showPrompt(
    title = "Document Author",
    message = "Enter the author name:",
    default = Sys.getenv("USER")
  )
  
  if (is.null(author)) {
    author <- Sys.getenv("USER")
  }
  
  # Convert the file
  tryCatch({
    rtoqmd(
      input_file = input_path,
      output_file = output_path,
      title = title,
      author = author,
      format = "html"
    )
    
    # Ask if user wants to open the generated file
    open_file <- rstudioapi::showQuestion(
      title = "Conversion Complete",
      message = paste0("Quarto document created successfully:\n", output_path, "\n\nWould you like to open it?"),
      ok = "Yes",
      cancel = "No"
    )
    
    if (open_file) {
      rstudioapi::navigateToFile(output_path)
    }
    
  }, error = function(e) {
    rstudioapi::showDialog(
      title = "Conversion Error",
      message = paste0("An error occurred during conversion:\n", e$message)
    )
  })
  
  invisible()
}
