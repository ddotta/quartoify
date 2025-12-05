#' Convert Active R Script to Quarto Markdown
#'
#' RStudio add-in that converts the currently active R script in the editor
#' to a Quarto markdown document. Uses a Shiny interface for parameter input.
#'
#' @importFrom shiny runGadget stopApp observeEvent reactive req textInput checkboxInput actionButton renderText reactiveVal tags
#' @importFrom miniUI miniPage gadgetTitleBar miniContentPanel miniTitleBarButton miniTitleBarCancelButton
#' @importFrom base64enc base64encode
#' @importFrom shinyFiles shinyFileChoose shinyFileSave parseFilePaths parseSavePath getVolumes
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
  
  # Get hex logo path
  hex_path <- system.file("man", "figures", "hex_quartify.png", package = "quartify")
  if (hex_path == "") {
    hex_path <- file.path("man", "figures", "hex_quartify.png")
  }
  
  # Create base64 encoded image if file exists
  logo_html <- if (file.exists(hex_path)) {
    img_base64 <- paste0("data:image/png;base64,", base64enc::base64encode(hex_path))
    shiny::tags$img(src = img_base64, width = "150px", style = "max-width: 150px;")
  } else {
    shiny::h3("quartify", style = "color: #0073e6; font-weight: bold;")
  }
  
  # Get flag images paths
  english_flag_path <- system.file("man", "figures", "english_flag.png", package = "quartify")
  if (english_flag_path == "") {
    english_flag_path <- file.path("man", "figures", "english_flag.png")
  }
  
  french_flag_path <- system.file("man", "figures", "french_flag.png", package = "quartify")
  if (french_flag_path == "") {
    french_flag_path <- file.path("man", "figures", "french_flag.png")
  }
  
  # Create flag images HTML
  english_flag_html <- if (file.exists(english_flag_path)) {
    flag_base64 <- paste0("data:image/png;base64,", base64enc::base64encode(english_flag_path))
    shiny::HTML(paste0('<img src="', flag_base64, '" width="20" style="margin-right: 5px; vertical-align: middle;"/> EN'))
  } else {
    "EN"
  }
  
  french_flag_html <- if (file.exists(french_flag_path)) {
    flag_base64 <- paste0("data:image/png;base64,", base64enc::base64encode(french_flag_path))
    shiny::HTML(paste0('<img src="', flag_base64, '" width="20" style="margin-right: 5px; vertical-align: middle;"/> FR'))
  } else {
    "FR"
  }
  
  # Define UI
  ui <- miniUI::miniPage(
    shiny::tags$head(
      shiny::tags$style(shiny::HTML("
        .loader {
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background-color: rgba(255, 255, 255, 0.9);
          display: none;
          justify-content: center;
          align-items: center;
          z-index: 9999;
        }
        .loader.active {
          display: flex;
        }
        .spinner {
          border: 8px solid #f3f3f3;
          border-top: 8px solid #0073e6;
          border-radius: 50%;
          width: 60px;
          height: 60px;
          animation: spin 1s linear infinite;
        }
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      ")),
      shiny::tags$script(shiny::HTML("
        Shiny.addCustomMessageHandler('toggleLoader', function(show) {
          var loader = document.getElementById('loader');
          if (show) {
            loader.classList.add('active');
          } else {
            loader.classList.remove('active');
          }
        });
      "))
    ),
    miniUI::gadgetTitleBar(
      "Convert R Script to Quarto",
      left = miniUI::miniTitleBarCancelButton("cancel", "\u21a9"),
      right = shiny::div(
        style = "display: flex; align-items: center; gap: 10px;",
        shiny::actionButton(
          "lang_en",
          english_flag_html,
          style = "padding: 5px 10px; font-size: 12px;",
          class = "btn-sm"
        ),
        shiny::actionButton(
          "lang_fr",
          french_flag_html,
          style = "padding: 5px 10px; font-size: 12px;",
          class = "btn-sm"
        ),
        miniUI::miniTitleBarButton("done", shiny::HTML("<span style='font-size: 16px; font-weight: bold;'>GENERATE \u25b6</span>"), primary = TRUE)
      )
    ),
    shiny::div(id = "loader", class = "loader", shiny::div(class = "spinner")),
    miniUI::miniContentPanel(
      shiny::fillCol(
        flex = c(NA, 1),
        shiny::fillRow(
          shiny::div(
            style = "padding: 20px; overflow-y: auto;",
            # Logo centered
            shiny::div(
              style = "text-align: center; margin-bottom: 20px;",
              logo_html
            ),
            # Mode selection
            shiny::fluidRow(
              shiny::column(12,
                shiny::div(
                  style = "margin-bottom: 20px;",
                  shiny::radioButtons("conversion_mode", 
                                    shiny::textOutput("label_mode", inline = TRUE),
                                    choices = c("Single file" = "single", "Directory" = "directory"),
                                    selected = "single",
                                    inline = TRUE)
                )
              )
            ),
            # Input selector (conditional based on mode)
            shiny::conditionalPanel(
              condition = "input.conversion_mode == 'single'",
              # Input and Output file selectors on same row
              shiny::fluidRow(
                # Input file
                shiny::column(6,
                shiny::div(
                  style = "margin-bottom: 15px;",
                  shiny::strong(shiny::textOutput("label_input_file")),
                  shiny::br(),
                  shiny::div(
                    style = "display: flex; align-items: center; margin-top: 5px;",
                    shiny::div(
                      style = "flex: 1; padding: 6px 12px; border: 1px solid #ddd; border-radius: 4px; background-color: #f9f9f9; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;",
                      shiny::textOutput("input_file_display", inline = TRUE)
                    ),
                    shiny::div(
                      style = "margin-left: 10px;",
                      shinyFiles::shinyFilesButton("input_file_btn", "Browse", "Select R script", multiple = FALSE, class = "btn-primary", style = "padding: 6px 12px;")
                    )
                  )
                )
              ),
              # Output file
              shiny::column(6,
                shiny::div(
                  style = "margin-bottom: 15px;",
                  shiny::strong(shiny::textOutput("label_output_file")),
                  shiny::br(),
                  shiny::div(
                    style = "display: flex; align-items: center; margin-top: 5px;",
                    shiny::div(
                      style = "flex: 1; padding: 6px 12px; border: 1px solid #ddd; border-radius: 4px; background-color: #f9f9f9; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;",
                      shiny::textOutput("output_file_display", inline = TRUE)
                    ),
                    shiny::div(
                      style = "margin-left: 10px;",
                      shinyFiles::shinySaveButton("output_file_btn", "Browse", "Save .qmd file", filetype = list(qmd = "qmd"), class = "btn-primary", style = "padding: 6px 12px;")
                    )
                  )
                )
              )
            ),
            # HTML Output file (optional - single mode only)
            shiny::fluidRow(
              shiny::column(12,
                shiny::div(
                  style = "margin-bottom: 15px; margin-top: 10px;",
                  shiny::strong(shiny::textOutput("label_html_file")),
                  shiny::span(
                    style = "margin-left: 5px; font-size: 0.9em; color: #666;",
                    shiny::textOutput("label_html_file_optional", inline = TRUE)
                  ),
                  shiny::br(),
                  shiny::div(
                    style = "display: flex; align-items: center; margin-top: 5px;",
                    shiny::div(
                      style = "flex: 1; padding: 6px 12px; border: 1px solid #ddd; border-radius: 4px; background-color: #f9f9f9; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;",
                      shiny::textOutput("html_file_display", inline = TRUE)
                    ),
                    shiny::div(
                      style = "margin-left: 10px;",
                      shinyFiles::shinySaveButton("html_file_btn", "Browse", "Save HTML file", filetype = list(html = "html"), class = "btn-primary", style = "padding: 6px 12px;")
                    )
                  )
                )
              )
            )
            ),  # End of single file conditional panel
            # Directory selection (for directory mode)
            shiny::conditionalPanel(
              condition = "input.conversion_mode == 'directory'",
              shiny::fluidRow(
                shiny::column(12,
                  shiny::div(
                    style = "margin-bottom: 15px;",
                    shiny::strong(shiny::textOutput("label_input_directory")),
                    shiny::br(),
                    shiny::div(
                      style = "display: flex; flex-direction: column; margin-top: 5px;",
                      shinyFiles::shinyDirButton("input_directory", 
                                                 shiny::textOutput("button_select_directory", inline = TRUE), 
                                                 "Select directory containing R scripts",
                                                 class = "btn-primary",
                                                 style = "margin-bottom: 10px; width: fit-content;"),
                      shiny::verbatimTextOutput("selected_directory", placeholder = TRUE)
                    )
                  )
                )
              )
            ),
            shiny::hr(),
            # Title, Author, Theme on same row
            shiny::fluidRow(
              shiny::column(4, shiny::textInput(
                "title",
                shiny::textOutput("label_title"),
                value = "My Analysis",
                width = "100%"
              )),
              shiny::column(4, shiny::textInput(
                "author",
                shiny::textOutput("label_author"),
                value = ifelse(Sys.getenv("USER") != "", Sys.getenv("USER"), "Your name"),
                width = "100%"
              )),
              shiny::column(4, shiny::selectInput(
                "theme",
                shiny::textOutput("label_theme"),
                choices = c(
                  "Default" = "",
                  "Cerulean" = "cerulean",
                  "Cosmo" = "cosmo",
                  "Flatly" = "flatly",
                  "Journal" = "journal",
                  "Litera" = "litera",
                  "Lumen" = "lumen",
                  "Lux" = "lux",
                  "Materia" = "materia",
                  "Minty" = "minty",
                  "Morph" = "morph",
                  "Pulse" = "pulse",
                  "Quartz" = "quartz",
                  "Sandstone" = "sandstone",
                  "Simplex" = "simplex",
                  "Sketchy" = "sketchy",
                  "Slate" = "slate",
                  "Solar" = "solar",
                  "Spacelab" = "spacelab",
                  "Superhero" = "superhero",
                  "United" = "united",
                  "Vapor" = "vapor",
                  "Yeti" = "yeti",
                  "Zephyr" = "zephyr",
                  "Darkly" = "darkly",
                  "Cyborg" = "cyborg"
                ),
                selected = "",
                width = "100%"
              ))
            ),
            shiny::hr(),
            # Checkboxes in 2 columns
            shiny::fluidRow(
              shiny::column(6,
                shiny::checkboxInput(
                  "render",
                  shiny::textOutput("label_render"),
                  value = TRUE
                ),
                shiny::checkboxInput(
                  "open_qmd",
                  shiny::textOutput("label_open_qmd"),
                  value = TRUE
                ),
                shiny::checkboxInput(
                  "number_sections",
                  shiny::textOutput("label_number_sections"),
                  value = TRUE
                )
              ),
              shiny::column(6,
                shiny::checkboxInput(
                  "code_fold",
                  shiny::textOutput("label_code_fold"),
                  value = FALSE
                ),
                shiny::checkboxInput(
                  "open_html",
                  shiny::textOutput("label_open_html"),
                  value = FALSE
                ),
                shiny::checkboxInput(
                  "show_source_lines",
                  shiny::textOutput("label_show_source_lines"),
                  value = TRUE
                )
              )
            )
          )
        )
      )
    )
  )
  
  # Define server logic
  server <- function(input, output, session) {
    
    # Stop app when session ends (browser closes)
    session$onSessionEnded(shiny::stopApp)
    
    # Detect user's R session language
    detect_lang <- function() {
      sys_lang <- Sys.getenv("LANG")
      if (sys_lang == "") {
        # Try alternative method
        sys_lang <- Sys.getlocale("LC_CTYPE")
      }
      # Check if language starts with "fr" or "FR"
      if (grepl("^fr", sys_lang, ignore.case = TRUE)) {
        return("fr")
      } else {
        return("en")
      }
    }
    
    # Reactive language - initialize with detected language
    lang <- shiny::reactiveVal(detect_lang())
    
    # Language switchers
    shiny::observeEvent(input$lang_en, {
      lang("en")
    })
    
    shiny::observeEvent(input$lang_fr, {
      lang("fr")
    })
    
    # Reactive values for file paths
    input_file_path <- shiny::reactiveVal(input_path)
    output_file_path <- shiny::reactiveVal(output_path)
    html_file_path <- shiny::reactiveVal(NULL)
    
    # File chooser for input file
    volumes <- shinyFiles::getVolumes()()
    shinyFiles::shinyFileChoose(input, "input_file_btn", roots = volumes, session = session, filetypes = c("", "R"))
    
    shiny::observeEvent(input$input_file_btn, {
      file_selected <- shinyFiles::parseFilePaths(volumes, input$input_file_btn)
      if (nrow(file_selected) > 0) {
        new_path <- as.character(file_selected$datapath)
        input_file_path(new_path)
        # Update output path suggestion
        output_file_path(sub("\\.R$", ".qmd", new_path, ignore.case = TRUE))
      }
    })
    
    # File saver for output file
    shinyFiles::shinyFileSave(input, "output_file_btn", roots = volumes, session = session, filetypes = c(qmd = "qmd"))
    
    shiny::observeEvent(input$output_file_btn, {
      file_selected <- shinyFiles::parseSavePath(volumes, input$output_file_btn)
      if (nrow(file_selected) > 0) {
        output_file_path(as.character(file_selected$datapath))
      }
    })
    
    # File saver for HTML file (optional)
    shinyFiles::shinyFileSave(input, "html_file_btn", roots = volumes, session = session, filetypes = c(html = "html"))
    
    shiny::observeEvent(input$html_file_btn, {
      file_selected <- shinyFiles::parseSavePath(volumes, input$html_file_btn)
      if (nrow(file_selected) > 0) {
        html_file_path(as.character(file_selected$datapath))
      }
    })
    
    # Display file paths
    output$input_file_display <- shiny::renderText({
      basename(input_file_path())
    })
    
    output$output_file_display <- shiny::renderText({
      basename(output_file_path())
    })
    
    output$html_file_display <- shiny::renderText({
      path <- html_file_path()
      if (is.null(path)) {
        if (lang() == "fr") "(emplacement par d\u00e9faut)" else "(default location)"
      } else {
        basename(path)
      }
    })
    
    # Reactive values for file paths and directory
    selected_dir <- shiny::reactiveVal(NULL)
    
    # Directory chooser
    shinyFiles::shinyDirChoose(input, "input_directory", roots = volumes)
    
    shiny::observeEvent(input$input_directory, {
      dir_path <- shinyFiles::parseDirPath(volumes, input$input_directory)
      if (length(dir_path) > 0) {
        selected_dir(as.character(dir_path))
      }
    })
    
    # Display selected directory
    output$selected_directory <- shiny::renderText({
      if (!is.null(selected_dir())) {
        if (lang() == "fr") {
          paste0("S\u00e9lectionn\u00e9 : ", selected_dir())
        } else {
          paste0("Selected: ", selected_dir())
        }
      } else {
        if (lang() == "fr") {
          "Aucun r\u00e9pertoire s\u00e9lectionn\u00e9"
        } else {
          "No directory selected"
        }
      }
    })
    
    # Translations
    translations <- list(
      en = list(
        mode = "Conversion mode:",
        input_file = "Input file:",
        input_directory = "Input directory:",
        button_select_directory = "Select Directory",
        output_file = "Output file path:",
        html_file = "HTML output file path:",
        html_file_optional = "(optional - leave blank for default location)",
        title = "Document title:",
        author = "Author name:",
        theme = "HTML theme:",
        render = "Render Html after conversion",
        open_html = "Open Html output file after rendering",
        open_qmd = "Open .qmd file in editor after conversion",
        code_fold = "Fold code blocks by default",
        number_sections = "Number sections automatically (not needed if sections already numbered)",
        show_source_lines = "Show original line numbers in code chunks"
      ),
      fr = list(
        mode = "Mode de conversion :",
        input_file = "Fichier d'entr\u00e9e :",
        input_directory = "R\u00e9pertoire d'entr\u00e9e :",
        button_select_directory = "S\u00e9lectionner un R\u00e9pertoire",
        output_file = "Chemin du fichier de sortie :",
        html_file = "Chemin du fichier HTML :",
        html_file_optional = "(optionnel - laisser vide pour l'emplacement par d\u00e9faut)",
        title = "Titre du document :",
        author = "Nom de l'auteur :",
        theme = "Th\u00e8me HTML :",
        render = "G\u00e9n\u00e9rer Html apr\u00e8s conversion",
        open_html = "Ouvrir le fichier Html apr\u00e8s rendu",
        open_qmd = "Ouvrir le fichier .qmd dans l'\u00e9diteur apr\u00e8s conversion",
        code_fold = "Replier les blocs de code par d\u00e9faut",
        number_sections = "Num\u00e9roter les sections automatiquement (pas utile si vos sections sont d\u00e9j\u00e0 num\u00e9rot\u00e9es)",
        show_source_lines = "Afficher les num\u00e9ros de ligne originaux dans les chunks"
      )
    )
    
    # Dynamic labels
    output$label_mode <- shiny::renderText({ translations[[lang()]]$mode })
    output$label_input_file <- shiny::renderText({ translations[[lang()]]$input_file })
    output$label_input_directory <- shiny::renderText({ translations[[lang()]]$input_directory })
    output$button_select_directory <- shiny::renderText({ translations[[lang()]]$button_select_directory })
    output$label_output_file <- shiny::renderText({ translations[[lang()]]$output_file })
    output$label_html_file <- shiny::renderText({ translations[[lang()]]$html_file })
    output$label_html_file_optional <- shiny::renderText({ translations[[lang()]]$html_file_optional })
    output$label_title <- shiny::renderText({ translations[[lang()]]$title })
    output$label_author <- shiny::renderText({ translations[[lang()]]$author })
    output$label_theme <- shiny::renderText({ translations[[lang()]]$theme })
    output$label_render <- shiny::renderText({ translations[[lang()]]$render })
    output$label_open_html <- shiny::renderText({ translations[[lang()]]$open_html })
    output$label_open_qmd <- shiny::renderText({ translations[[lang()]]$open_qmd })
    output$label_code_fold <- shiny::renderText({ translations[[lang()]]$code_fold })
    output$label_number_sections <- shiny::renderText({ translations[[lang()]]$number_sections })
    output$label_show_source_lines <- shiny::renderText({ translations[[lang()]]$show_source_lines })
    
    # When done button is pressed
    shiny::observeEvent(input$done, {
      
      # Show loader
      session$sendCustomMessage('toggleLoader', TRUE)
      
      # Get common values
      title <- shiny::req(input$title)
      author <- shiny::req(input$author)
      theme <- input$theme
      if (theme == "") theme <- NULL
      render <- input$render
      open_html <- input$open_html
      open_qmd <- input$open_qmd
      code_fold <- input$code_fold
      number_sections <- input$number_sections
      show_source_lines <- input$show_source_lines
      
      # Check mode
      is_directory_mode <- input$conversion_mode == "directory"
      
      # Convert based on mode
      tryCatch({
        if (is_directory_mode) {
          # Directory mode
          dir_path <- shiny::req(selected_dir())
          
          rtoqmd_dir(
            input_dir = dir_path,
            title_prefix = paste0(title, " - "),
            author = author,
            format = "html",
            theme = theme,
            render = render,
            code_fold = code_fold,
            number_sections = number_sections,
            lang = lang()
          )
          
        } else {
          # Single file mode
          input_file_final <- shiny::req(input_file_path())
          output_file_final <- shiny::req(output_file_path())
          html_file_final <- html_file_path()
          
          rtoqmd(
            input_file = input_file_final,
            output_file = output_file_final,
            title = title,
            author = author,
            format = "html",
            theme = theme,
            render = render,
            output_html_file = html_file_final,
            open_html = open_html && render,
            code_fold = code_fold,
            number_sections = number_sections,
            lang = lang(),
            show_source_lines = show_source_lines
          )
        }
        
        # Open QMD file if requested (single mode only)
        if (!is_directory_mode && open_qmd && file.exists(output_file_final)) {
          rstudioapi::navigateToFile(output_file_final)
        }
        
        # Hide loader
        session$sendCustomMessage('toggleLoader', FALSE)
        
        # Show success message based on language
        success_msg <- if (lang() == "fr") {
          "\u2714 Conversion termin\u00e9e avec succ\u00e8s ! Vous pouvez fermer cette fen\u00eatre."
        } else {
          "\u2714 Conversion completed successfully! You can close this window."
        }
        
        shiny::showModal(shiny::modalDialog(
          title = if (lang() == "fr") "Conversion termin\u00e9e" else "Conversion completed",
          success_msg,
          easyClose = TRUE,
          footer = shiny::actionButton("close_modal", 
                                      if (lang() == "fr") "Fermer" else "Close",
                                      onclick = "setTimeout(function(){window.close();}, 100);")
        ))
        
      }, error = function(e) {
        # Hide loader on error
        session$sendCustomMessage('toggleLoader', FALSE)
        shiny::showNotification(
          paste0("Error: ", e$message),
          type = "error",
          duration = 10
        )
      })
    })
    
    # When cancel button is pressed
    shiny::observeEvent(input$cancel, {
      shiny::stopApp()
    })
    
    # Close modal and stop app
    shiny::observeEvent(input$close_modal, {
      shiny::removeModal()
      shiny::stopApp()
    })
  }
  
  # Run the gadget
  viewer <- shiny::browserViewer()
  shiny::runGadget(ui, server, viewer = viewer, stopOnCancel = FALSE)
  
  invisible()
}

#' Launch Quartify Shiny Interface
#'
#' Opens the Quartify conversion interface in your default web browser.
#' This function provides the same interface as the RStudio add-in but works
#' in any R environment including Positron, VS Code, RStudio, or command line.
#' Unlike the add-in, this function requires you to manually select input files
#' using the file browser in the interface.
#'
#' @param launch.browser Logical, whether to open in browser (default: TRUE).
#'   Set to FALSE to run in RStudio Viewer pane if available.
#' @param port The port to run the app on (default: random available port)
#' @return Invisibly returns NULL when the app is closed
#' @importFrom shiny runApp fluidPage titlePanel sidebarLayout sidebarPanel mainPanel
#' @export
#' @examples
#' \dontrun{
#' # Launch the Shiny app in browser (works in any IDE)
#' quartify_app()
#' 
#' # Use in Positron or VS Code
#' library(quartify)
#' quartify_app()
#' 
#' # Specify a port
#' quartify_app(port = 3838)
#' }
quartify_app <- function(launch.browser = TRUE, port = NULL) {
  
  # Get resources for UI
  hex_path <- system.file("man", "figures", "hex_quartify.png", package = "quartify")
  if (hex_path == "" || !file.exists(hex_path)) {
    hex_path <- NULL
  }
  
  english_flag_path <- system.file("man", "figures", "english_flag.png", package = "quartify")
  if (english_flag_path == "" || !file.exists(english_flag_path)) {
    english_flag_path <- NULL
  }
  
  french_flag_path <- system.file("man", "figures", "french_flag.png", package = "quartify")
  if (french_flag_path == "" || !file.exists(french_flag_path)) {
    french_flag_path <- NULL
  }
  
  # Create UI elements
  logo_html <- if (!is.null(hex_path)) {
    img_base64 <- paste0("data:image/png;base64,", base64enc::base64encode(hex_path))
    shiny::tags$img(src = img_base64, width = "150px", style = "max-width: 150px;")
  } else {
    shiny::h3("quartify", style = "color: #0073e6; font-weight: bold;")
  }
  
  english_flag_html <- if (!is.null(english_flag_path)) {
    flag_base64 <- paste0("data:image/png;base64,", base64enc::base64encode(english_flag_path))
    shiny::HTML(paste0('<img src="', flag_base64, '" width="20" style="margin-right: 5px; vertical-align: middle;"/> EN'))
  } else {
    "EN"
  }
  
  french_flag_html <- if (!is.null(french_flag_path)) {
    flag_base64 <- paste0("data:image/png;base64,", base64enc::base64encode(french_flag_path))
    shiny::HTML(paste0('<img src="', flag_base64, '" width="20" style="margin-right: 5px; vertical-align: middle;"/> FR'))
  } else {
    "FR"
  }
  
  # Define UI (similar to add-in but using regular Shiny instead of miniUI)
  ui <- shiny::fluidPage(
    title = "Quartify - Convert R Scripts to Quarto",
    shiny::tags$head(
      shiny::tags$style(shiny::HTML("
        body { padding: 20px; }
        .title-bar {
          background-color: #0073e6;
          color: white;
          padding: 15px 20px;
          margin: -20px -20px 20px -20px;
          display: flex;
          justify-content: space-between;
          align-items: center;
        }
        .title-bar h2 { margin: 0; color: white; }
        .lang-buttons { display: flex; gap: 10px; }
        .loader {
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background-color: rgba(255, 255, 255, 0.9);
          display: none;
          justify-content: center;
          align-items: center;
          z-index: 9999;
        }
        .loader.active { display: flex; }
        .spinner {
          border: 8px solid #f3f3f3;
          border-top: 8px solid #0073e6;
          border-radius: 50%;
          width: 60px;
          height: 60px;
          animation: spin 1s linear infinite;
        }
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      ")),
      shiny::tags$script(shiny::HTML("
        Shiny.addCustomMessageHandler('toggleLoader', function(show) {
          var loader = document.getElementById('loader');
          if (show) {
            loader.classList.add('active');
          } else {
            loader.classList.remove('active');
          }
        });
      "))
    ),
    
    # Title bar
    shiny::div(
      class = "title-bar",
      shiny::h2("Convert R Script to Quarto"),
      shiny::div(
        class = "lang-buttons",
        shiny::actionButton("lang_en", english_flag_html, class = "btn-sm"),
        shiny::actionButton("lang_fr", french_flag_html, class = "btn-sm"),
        shiny::actionButton("done", shiny::HTML("<span style='font-size: 16px; font-weight: bold;'>GENERATE \u25B6</span>"), class = "btn-primary"),
        shiny::actionButton("quit_app", shiny::HTML("<span style='font-size: 16px; font-weight: bold;'>\u2715</span>"), class = "btn-danger btn-sm", style = "margin-left: 10px;")
      )
    ),
    
    # Loader
    shiny::div(id = "loader", class = "loader", shiny::div(class = "spinner")),
    
    # Main content
    shiny::div(
      style = "max-width: 1200px; margin: 0 auto;",
      
      # Logo centered
      shiny::div(
        style = "text-align: center; margin-bottom: 30px;",
        logo_html
      ),
      
      # Mode selection
      shiny::fluidRow(
        shiny::column(12,
          shiny::div(
            style = "margin-bottom: 20px;",
            shiny::radioButtons("conversion_mode", 
                              shiny::textOutput("label_mode", inline = TRUE),
                              choices = c("Single file" = "single", "Directory" = "directory"),
                              selected = "single",
                              inline = TRUE)
          )
        )
      ),
      
      # Input selector (conditional based on mode)
      shiny::conditionalPanel(
        condition = "input.conversion_mode == 'single'",
        # File selectors
        shiny::fluidRow(
          shiny::column(6,
            shiny::div(
              style = "margin-bottom: 15px;",
              shiny::strong(shiny::textOutput("label_input_file")),
            shiny::br(),
            shiny::div(
              style = "display: flex; align-items: center; margin-top: 5px;",
              shiny::div(
                style = "flex: 1; padding: 6px 12px; border: 1px solid #ddd; border-radius: 4px; background-color: #f9f9f9; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;",
                shiny::textOutput("input_file_display", inline = TRUE)
              ),
              shiny::div(
                style = "margin-left: 10px;",
                shinyFiles::shinyFilesButton("input_file_btn", "Browse", "Select R script", multiple = FALSE, class = "btn-primary")
              )
            )
          )
        ),
        shiny::column(6,
          shiny::div(
            style = "margin-bottom: 15px;",
            shiny::strong(shiny::textOutput("label_output_file")),
            shiny::br(),
            shiny::div(
              style = "display: flex; align-items: center; margin-top: 5px;",
              shiny::div(
                style = "flex: 1; padding: 6px 12px; border: 1px solid #ddd; border-radius: 4px; background-color: #f9f9f9; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;",
                shiny::textOutput("output_file_display", inline = TRUE)
              ),
              shiny::div(
                style = "margin-left: 10px;",
                shinyFiles::shinySaveButton("output_file_btn", "Browse", "Save .qmd file", filetype = list(qmd = "qmd"), class = "btn-primary")
              )
            )
          )
        )
      ),
      
      # HTML output file
      shiny::fluidRow(
        shiny::column(12,
          shiny::div(
            style = "margin-bottom: 15px;",
            shiny::strong(shiny::textOutput("label_html_file")),
            shiny::span(
              style = "margin-left: 5px; font-size: 0.9em; color: #666;",
              shiny::textOutput("label_html_file_optional", inline = TRUE)
            ),
            shiny::br(),
            shiny::div(
              style = "display: flex; align-items: center; margin-top: 5px;",
              shiny::div(
                style = "flex: 1; padding: 6px 12px; border: 1px solid #ddd; border-radius: 4px; background-color: #f9f9f9; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;",
                shiny::textOutput("html_file_display", inline = TRUE)
              ),
              shiny::div(
                style = "margin-left: 10px;",
                shinyFiles::shinySaveButton("html_file_btn", "Browse", "Save HTML file", filetype = list(html = "html"), class = "btn-primary")
              )
            )
          )
        )
      )
      ),  # End of single file conditional panel
      
      # Directory selection (for directory mode)
      shiny::conditionalPanel(
        condition = "input.conversion_mode == 'directory'",
        shiny::fluidRow(
          shiny::column(12,
            shiny::div(
              style = "margin-bottom: 15px;",
              shiny::strong(shiny::textOutput("label_input_directory")),
              shiny::br(),
              shiny::div(
                style = "display: flex; flex-direction: column; margin-top: 5px;",
                shinyFiles::shinyDirButton("input_directory", 
                                          shiny::textOutput("button_select_directory", inline = TRUE), 
                                          "Select directory containing R scripts",
                                          class = "btn-primary",
                                          style = "margin-bottom: 10px; width: fit-content;"),
                shiny::verbatimTextOutput("selected_directory", placeholder = TRUE)
              )
            )
          )
        )
      ),
      
      shiny::hr(),
      
      # Parameters
      shiny::fluidRow(
        shiny::column(4, shiny::textInput("title", shiny::textOutput("label_title"), value = "My Analysis", width = "100%")),
        shiny::column(4, shiny::textInput("author", shiny::textOutput("label_author"), 
                                         value = ifelse(Sys.getenv("USER") != "", Sys.getenv("USER"), "Your name"), width = "100%")),
        shiny::column(4, shiny::selectInput("theme", shiny::textOutput("label_theme"),
          choices = c("Default" = "", "Cerulean" = "cerulean", "Cosmo" = "cosmo", "Flatly" = "flatly",
                     "Journal" = "journal", "Litera" = "litera", "Lumen" = "lumen", "Lux" = "lux",
                     "Materia" = "materia", "Minty" = "minty", "Morph" = "morph", "Pulse" = "pulse",
                     "Quartz" = "quartz", "Sandstone" = "sandstone", "Simplex" = "simplex",
                     "Sketchy" = "sketchy", "Slate" = "slate", "Solar" = "solar", "Spacelab" = "spacelab",
                     "Superhero" = "superhero", "United" = "united", "Vapor" = "vapor", "Yeti" = "yeti",
                     "Zephyr" = "zephyr", "Darkly" = "darkly", "Cyborg" = "cyborg"),
          selected = "", width = "100%"))
      ),
      
      shiny::hr(),
      
      # Checkboxes
      shiny::fluidRow(
        shiny::column(6,
          shiny::checkboxInput("render", shiny::textOutput("label_render"), value = TRUE),
          shiny::checkboxInput("open_qmd", shiny::textOutput("label_open_qmd"), value = FALSE),
          shiny::checkboxInput("number_sections", shiny::textOutput("label_number_sections"), value = TRUE)
        ),
        shiny::column(6,
          shiny::checkboxInput("code_fold", shiny::textOutput("label_code_fold"), value = FALSE),
          shiny::checkboxInput("open_html", shiny::textOutput("label_open_html"), value = FALSE),
          shiny::checkboxInput("show_source_lines", shiny::textOutput("label_show_source_lines"), value = TRUE)
        )
      )
    )
  )
  
  # Define server (reuse logic from add-in)
  server <- function(input, output, session) {
    
    # Detect language
    detect_lang <- function() {
      sys_lang <- Sys.getenv("LANG")
      if (sys_lang == "") {
        sys_lang <- Sys.getlocale("LC_CTYPE")
      }
      if (grepl("^fr", sys_lang, ignore.case = TRUE)) {
        return("fr")
      } else {
        return("en")
      }
    }
    
    lang <- shiny::reactiveVal(detect_lang())
    
    shiny::observeEvent(input$lang_en, { lang("en") })
    shiny::observeEvent(input$lang_fr, { lang("fr") })
    
    input_file_path <- shiny::reactiveVal(NULL)
    output_file_path <- shiny::reactiveVal(NULL)
    html_file_path <- shiny::reactiveVal(NULL)
    selected_dir <- shiny::reactiveVal(NULL)
    
    volumes <- shinyFiles::getVolumes()()
    shinyFiles::shinyFileChoose(input, "input_file_btn", roots = volumes, session = session, filetypes = c("", "R"))
    
    # Directory chooser
    shinyFiles::shinyDirChoose(input, "input_directory", roots = volumes)
    
    shiny::observeEvent(input$input_directory, {
      dir_path <- shinyFiles::parseDirPath(volumes, input$input_directory)
      if (length(dir_path) > 0) {
        selected_dir(as.character(dir_path))
      }
    })
    
    # Display selected directory
    output$selected_directory <- shiny::renderText({
      if (!is.null(selected_dir())) {
        if (lang() == "fr") {
          paste0("S\u00e9lectionn\u00e9 : ", selected_dir())
        } else {
          paste0("Selected: ", selected_dir())
        }
      } else {
        if (lang() == "fr") {
          "Aucun r\u00e9pertoire s\u00e9lectionn\u00e9"
        } else {
          "No directory selected"
        }
      }
    })
    
    shiny::observeEvent(input$input_file_btn, {
      file_selected <- shinyFiles::parseFilePaths(volumes, input$input_file_btn)
      if (nrow(file_selected) > 0) {
        new_path <- as.character(file_selected$datapath)
        input_file_path(new_path)
        output_file_path(sub("\\.R$", ".qmd", new_path, ignore.case = TRUE))
      }
    })
    
    shinyFiles::shinyFileSave(input, "output_file_btn", roots = volumes, session = session, filetypes = c(qmd = "qmd"))
    
    shiny::observeEvent(input$output_file_btn, {
      file_selected <- shinyFiles::parseSavePath(volumes, input$output_file_btn)
      if (nrow(file_selected) > 0) {
        output_file_path(as.character(file_selected$datapath))
      }
    })
    
    shinyFiles::shinyFileSave(input, "html_file_btn", roots = volumes, session = session, filetypes = c(html = "html"))
    
    shiny::observeEvent(input$html_file_btn, {
      file_selected <- shinyFiles::parseSavePath(volumes, input$html_file_btn)
      if (nrow(file_selected) > 0) {
        html_file_path(as.character(file_selected$datapath))
      }
    })
    
    output$input_file_display <- shiny::renderText({
      path <- input_file_path()
      if (is.null(path)) {
        if (lang() == "fr") "(s\u00E9lectionner un fichier)" else "(select a file)"
      } else {
        basename(path)
      }
    })
    
    output$output_file_display <- shiny::renderText({
      path <- output_file_path()
      if (is.null(path)) {
        if (lang() == "fr") "(s\u00E9lectionner un fichier)" else "(select a file)"
      } else {
        basename(path)
      }
    })
    
    output$html_file_display <- shiny::renderText({
      path <- html_file_path()
      if (is.null(path)) {
        if (lang() == "fr") "(emplacement par d\u00E9faut)" else "(default location)"
      } else {
        basename(path)
      }
    })
    
    translations <- list(
      en = list(
        mode = "Conversion mode:",
        input_file = "Input file:",
        input_directory = "Input directory:",
        button_select_directory = "Select Directory",
        output_file = "Output file path:",
        html_file = "HTML output file path:",
        html_file_optional = "(optional - leave blank for default location)",
        title = "Document title:",
        author = "Author name:",
        theme = "HTML theme:",
        render = "Render Html after conversion",
        open_html = "Open Html output file after rendering",
        open_qmd = "Open .qmd file in editor after conversion",
        code_fold = "Fold code blocks by default",
        number_sections = "Number sections automatically (not needed if sections already numbered)",
        show_source_lines = "Show original line numbers in code chunks"
      ),
      fr = list(
        mode = "Mode de conversion :",
        input_file = "Fichier d'entr\u00E9e :",
        input_directory = "R\u00E9pertoire d'entr\u00E9e :",
        button_select_directory = "S\u00E9lectionner un R\u00E9pertoire",
        output_file = "Chemin du fichier de sortie :",
        html_file = "Chemin du fichier HTML :",
        html_file_optional = "(optionnel - laisser vide pour l'emplacement par d\u00E9faut)",
        title = "Titre du document :",
        author = "Nom de l'auteur :",
        theme = "Th\u00E8me HTML :",
        render = "G\u00E9n\u00E9rer Html apr\u00E8s conversion",
        open_html = "Ouvrir le fichier Html apr\u00E8s rendu",
        open_qmd = "Ouvrir le fichier .qmd dans l'\u00E9diteur apr\u00E8s conversion",
        code_fold = "Replier les blocs de code par d\u00E9faut",
        number_sections = "Num\u00E9roter les sections automatiquement (pas utile si vos sections sont d\u00E9j\u00E0 num\u00E9rot\u00E9es)",
        show_source_lines = "Afficher les num\u00E9ros de ligne originaux dans les chunks"
      )
    )
    
    output$label_mode <- shiny::renderText({ translations[[lang()]]$mode })
    output$label_input_file <- shiny::renderText({ translations[[lang()]]$input_file })
    output$label_input_directory <- shiny::renderText({ translations[[lang()]]$input_directory })
    output$button_select_directory <- shiny::renderText({ translations[[lang()]]$button_select_directory })
    output$label_output_file <- shiny::renderText({ translations[[lang()]]$output_file })
    output$label_html_file <- shiny::renderText({ translations[[lang()]]$html_file })
    output$label_html_file_optional <- shiny::renderText({ translations[[lang()]]$html_file_optional })
    output$label_title <- shiny::renderText({ translations[[lang()]]$title })
    output$label_author <- shiny::renderText({ translations[[lang()]]$author })
    output$label_theme <- shiny::renderText({ translations[[lang()]]$theme })
    output$label_render <- shiny::renderText({ translations[[lang()]]$render })
    output$label_open_html <- shiny::renderText({ translations[[lang()]]$open_html })
    output$label_open_qmd <- shiny::renderText({ translations[[lang()]]$open_qmd })
    output$label_code_fold <- shiny::renderText({ translations[[lang()]]$code_fold })
    output$label_number_sections <- shiny::renderText({ translations[[lang()]]$number_sections })
    output$label_show_source_lines <- shiny::renderText({ translations[[lang()]]$show_source_lines })
    
    shiny::observeEvent(input$done, {
      
      # Check mode
      is_directory_mode <- input$conversion_mode == "directory"
      
      # Validation based on mode
      if (is_directory_mode) {
        if (is.null(selected_dir())) {
          shiny::showNotification(
            if (lang() == "fr") "Veuillez s\u00E9lectionner un r\u00E9pertoire" else "Please select a directory",
            type = "error",
            duration = 5
          )
          return()
        }
      } else {
        input_file_final <- input_file_path()
        output_file_final <- output_file_path()
        
        if (is.null(input_file_final) || is.null(output_file_final)) {
          shiny::showNotification(
            if (lang() == "fr") "Veuillez s\u00E9lectionner les fichiers d'entr\u00E9e et de sortie" else "Please select input and output files",
            type = "error",
            duration = 5
          )
          return()
        }
      }
      
      session$sendCustomMessage('toggleLoader', TRUE)
      
      # Get common values
      title <- shiny::req(input$title)
      author <- shiny::req(input$author)
      theme <- input$theme
      if (theme == "") theme <- NULL
      render <- input$render
      open_html <- input$open_html
      open_qmd <- input$open_qmd
      code_fold <- input$code_fold
      number_sections <- input$number_sections
      show_source_lines <- input$show_source_lines
      
      tryCatch({
        if (is_directory_mode) {
          # Directory mode
          dir_path <- selected_dir()
          
          rtoqmd_dir(
            input_dir = dir_path,
            title_prefix = paste0(title, " - "),
            author = author,
            format = "html",
            theme = theme,
            render = render,
            code_fold = code_fold,
            number_sections = number_sections,
            lang = lang()
          )
          
        } else {
          # Single file mode
          html_file_final <- html_file_path()
          
          rtoqmd(
            input_file = input_file_final,
            output_file = output_file_final,
            title = title,
            author = author,
            format = "html",
            theme = theme,
            render = render,
            output_html_file = html_file_final,
            open_html = open_html && render,
            code_fold = code_fold,
            number_sections = number_sections,
            lang = lang(),
            show_source_lines = show_source_lines
          )
          
          if (open_qmd && file.exists(output_file_final)) {
            utils::browseURL(output_file_final)
          }
        }
        
        session$sendCustomMessage('toggleLoader', FALSE)
        
        success_msg <- if (lang() == "fr") {
          "\u2714 Conversion termin\u00E9e avec succ\u00E8s !"
        } else {
          "\u2714 Conversion completed successfully!"
        }
        
        shiny::showModal(shiny::modalDialog(
          title = if (lang() == "fr") "Conversion termin\u00E9e" else "Conversion completed",
          success_msg,
          easyClose = TRUE,
          footer = shiny::actionButton("close_modal", if (lang() == "fr") "Fermer" else "Close")
        ))
        
      }, error = function(e) {
        session$sendCustomMessage('toggleLoader', FALSE)
        shiny::showNotification(
          paste0("Error: ", e$message),
          type = "error",
          duration = 10
        )
      })
    })
    
    shiny::observeEvent(input$close_modal, {
      shiny::removeModal()
    })
    
    # Quit app button handler
    shiny::observeEvent(input$quit_app, {
      shiny::stopApp()
    })
    
    # Handle session end (when browser window is closed)
    session$onSessionEnded(function() {
      shiny::stopApp()
    })
  }
  
  # Run app
  if (is.null(port)) {
    shiny::runApp(list(ui = ui, server = server), launch.browser = launch.browser)
  } else {
    shiny::runApp(list(ui = ui, server = server), launch.browser = launch.browser, port = port)
  }
  
  invisible()
}

#' Launch Quartify Web Application (for deployment)
#'
#' @description
#' Web-friendly version of quartify_app() designed for deployment on web servers.
#' Uses file upload/download instead of local file system access.
#'
#' @param launch.browser Logical, whether to launch browser (default: TRUE)
#' @param port Integer, port number for the application (default: NULL for random port)
#'
#' @return Invisible NULL
#' @export
#'
#' @examples
#' \dontrun{
#' quartify_app_web()
#' }
quartify_app_web <- function(launch.browser = TRUE, port = NULL) {
  
  # Get resources for UI (try multiple paths for compatibility)
  hex_path <- system.file("man", "figures", "hex_quartify.png", package = "quartify")
  if (hex_path == "" || !file.exists(hex_path)) {
    hex_path <- system.file("figures", "hex_quartify.png", package = "quartify")
  }
  if (hex_path == "" || !file.exists(hex_path)) {
    hex_path <- NULL
  }
  
  english_flag_path <- system.file("man", "figures", "english_flag.png", package = "quartify")
  if (english_flag_path == "" || !file.exists(english_flag_path)) {
    english_flag_path <- system.file("figures", "english_flag.png", package = "quartify")
  }
  if (english_flag_path == "" || !file.exists(english_flag_path)) {
    english_flag_path <- NULL
  }
  
  french_flag_path <- system.file("man", "figures", "french_flag.png", package = "quartify")
  if (french_flag_path == "" || !file.exists(french_flag_path)) {
    french_flag_path <- system.file("figures", "french_flag.png", package = "quartify")
  }
  if (french_flag_path == "" || !file.exists(french_flag_path)) {
    french_flag_path <- NULL
  }
  
  # Create UI elements
  logo_html <- if (!is.null(hex_path)) {
    img_base64 <- paste0("data:image/png;base64,", base64enc::base64encode(hex_path))
    shiny::tags$img(src = img_base64, width = "150px", style = "max-width: 150px;")
  } else {
    shiny::h3("quartify", style = "color: #0073e6; font-weight: bold;")
  }
  
  english_flag_html <- if (!is.null(english_flag_path)) {
    flag_base64 <- paste0("data:image/png;base64,", base64enc::base64encode(english_flag_path))
    shiny::HTML(paste0('<img src="', flag_base64, '" width="20" style="margin-right: 5px; vertical-align: middle;"/> EN'))
  } else {
    "EN"
  }
  
  french_flag_html <- if (!is.null(french_flag_path)) {
    flag_base64 <- paste0("data:image/png;base64,", base64enc::base64encode(french_flag_path))
    shiny::HTML(paste0('<img src="', flag_base64, '" width="20" style="margin-right: 5px; vertical-align: middle;"/> FR'))
  } else {
    "FR"
  }
  
  # Define UI
  ui <- shiny::fluidPage(
    title = "Quartify - Convert R Scripts to Quarto",
    shiny::tags$head(
      shiny::tags$style(shiny::HTML("
        body { padding: 20px; }
        .title-bar {
          background-color: #0073e6;
          color: white;
          padding: 15px 20px;
          margin: -20px -20px 20px -20px;
          display: flex;
          justify-content: space-between;
          align-items: center;
        }
        .title-bar h2 { margin: 0; color: white; }
        .lang-buttons { display: flex; gap: 10px; }
        .loader {
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background-color: rgba(255, 255, 255, 0.9);
          display: none;
          justify-content: center;
          align-items: center;
          z-index: 9999;
        }
        .loader.active { display: flex; }
        .spinner {
          border: 8px solid #f3f3f3;
          border-top: 8px solid #0073e6;
          border-radius: 50%;
          width: 60px;
          height: 60px;
          animation: spin 1s linear infinite;
        }
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        .download-section {
          margin-top: 20px;
          padding: 15px;
          border: 2px dashed #0073e6;
          border-radius: 5px;
          background-color: #f0f8ff;
        }
      ")),
      shiny::tags$script(shiny::HTML("
        Shiny.addCustomMessageHandler('toggleLoader', function(show) {
          var loader = document.getElementById('loader');
          if (show) {
            loader.classList.add('active');
          } else {
            loader.classList.remove('active');
          }
        });
      "))
    ),
    
    # Title bar
    shiny::div(
      class = "title-bar",
      shiny::div(
        style = "display: flex; align-items: center; gap: 15px;",
        shiny::h2("Convert R Script to Quarto"),
        shiny::tags$a(
          href = "https://github.com/ddotta/quartify",
          target = "_blank",
          style = "color: white; text-decoration: none; font-size: 14px; display: flex; align-items: center; gap: 5px;",
          shiny::HTML('<svg height="20" width="20" viewBox="0 0 16 16" fill="white"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"></path></svg>'),
          "GitHub"
        )
      ),
      shiny::div(
        class = "lang-buttons",
        shiny::actionButton("lang_en", english_flag_html, class = "btn-sm"),
        shiny::actionButton("lang_fr", french_flag_html, class = "btn-sm")
      )
    ),
    
    # Loader
    shiny::div(id = "loader", class = "loader", shiny::div(class = "spinner")),
    
    # Main content
    shiny::div(
      style = "max-width: 1200px; margin: 0 auto;",
      
      # Logo centered
      shiny::div(
        style = "text-align: center; margin-bottom: 30px;",
        logo_html
      ),
      
      # Mode selection
      shiny::fluidRow(
        shiny::column(12,
          shiny::div(
            style = "margin-bottom: 20px;",
            shiny::radioButtons("conversion_mode", 
                              shiny::textOutput("label_mode", inline = TRUE),
                              choices = c("Single file" = "single", "Batch (multiple files)" = "batch"),
                              selected = "single",
                              inline = TRUE)
          )
        )
      ),
      
      # File upload (conditional based on mode)
      shiny::conditionalPanel(
        condition = "input.conversion_mode == 'single'",
        shiny::fluidRow(
          shiny::column(12,
            shiny::div(
              style = "margin-bottom: 20px;",
              shiny::strong(shiny::textOutput("label_upload_file")),
              shiny::br(),
              shiny::fileInput("input_file", NULL, accept = c(".R", ".r"), 
                             buttonLabel = shiny::textOutput("button_upload", inline = TRUE))
            )
          )
        )
      ),
      
      # Batch file upload or directory selection
      shiny::conditionalPanel(
        condition = "input.conversion_mode == 'batch'",
        shiny::fluidRow(
          shiny::column(12,
            shiny::div(
              style = "margin-bottom: 20px;",
              shiny::strong(shiny::textOutput("label_batch_source")),
              shiny::radioButtons("batch_source_type",
                                NULL,
                                choices = c("Upload files" = "files", "Select directory" = "directory"),
                                selected = "files",
                                inline = TRUE)
            )
          )
        ),
        # File upload option
        shiny::conditionalPanel(
          condition = "input.batch_source_type == 'files'",
          shiny::fluidRow(
            shiny::column(12,
              shiny::div(
                style = "margin-bottom: 20px;",
                shiny::fileInput("input_files", NULL, accept = c(".R", ".r"), 
                               multiple = TRUE,
                               buttonLabel = shiny::textOutput("button_upload_batch", inline = TRUE))
              )
            )
          )
        ),
        # Directory selection option
        shiny::conditionalPanel(
          condition = "input.batch_source_type == 'directory'",
          shiny::fluidRow(
            shiny::column(12,
              shiny::div(
                style = "margin-bottom: 20px;",
                shinyFiles::shinyDirButton("input_directory", 
                                          label = shiny::textOutput("button_select_directory", inline = TRUE),
                                          title = "Select a directory containing R scripts"),
                shiny::br(),
                shiny::verbatimTextOutput("selected_directory", placeholder = TRUE)
              )
            )
          )
        )
      ),
      
      # Options
      shiny::fluidRow(
        shiny::column(6,
          shiny::div(
            style = "margin-bottom: 15px;",
            shiny::strong(shiny::textOutput("label_title")),
            shiny::textInput("doc_title", NULL, value = "My Analysis", width = "100%")
          )
        ),
        shiny::column(6,
          shiny::div(
            style = "margin-bottom: 15px;",
            shiny::strong(shiny::textOutput("label_author")),
            shiny::textInput("doc_author", NULL, value = "", width = "100%")
          )
        )
      ),
      
      shiny::fluidRow(
        shiny::column(4,
          shiny::div(
            style = "margin-bottom: 15px;",
            shiny::strong(shiny::textOutput("label_theme")),
            shiny::selectInput("theme", NULL, 
                             choices = c("Default" = "", "Cerulean" = "cerulean", "Cosmo" = "cosmo", 
                                       "Flatly" = "flatly", "Journal" = "journal", "Litera" = "litera", 
                                       "Lumen" = "lumen", "Lux" = "lux", "Materia" = "materia", 
                                       "Minty" = "minty", "Morph" = "morph", "Pulse" = "pulse",
                                       "Quartz" = "quartz", "Sandstone" = "sandstone", "Simplex" = "simplex",
                                       "Sketchy" = "sketchy", "Slate" = "slate", "Solar" = "solar",
                                       "Spacelab" = "spacelab", "Superhero" = "superhero", "United" = "united", 
                                       "Vapor" = "vapor", "Yeti" = "yeti", "Zephyr" = "zephyr",
                                       "Darkly" = "darkly", "Cyborg" = "cyborg"),
                             selected = "",
                             width = "100%")
          )
        )
      ),
      
      shiny::hr(),
      
      # Checkboxes in 2 columns
      shiny::fluidRow(
        shiny::column(6,
          shiny::checkboxInput("render_html", shiny::textOutput("label_render"), value = TRUE),
          shiny::checkboxInput("number_sections", shiny::textOutput("label_number_sections"), value = TRUE),
          shiny::checkboxInput("show_source_lines", shiny::textOutput("label_show_source_lines"), value = TRUE)
        ),
        shiny::column(6,
          shiny::checkboxInput("code_fold", shiny::textOutput("label_code_fold"), value = FALSE)
        )
      ),
      
      # Book option (only visible in batch mode)
      shiny::conditionalPanel(
        condition = "input.conversion_mode == 'batch'",
        shiny::fluidRow(
          shiny::column(12,
            shiny::div(
              style = "margin-top: 15px; padding: 10px; border: 1px solid #0073e6; border-radius: 5px; background-color: #f0f8ff;",
              shiny::checkboxInput("create_book", shiny::textOutput("label_create_book"), value = TRUE),
              shiny::p(
                style = "margin: 0; font-size: 0.9em; color: #666;",
                shiny::textOutput("label_book_description")
              )
            )
          )
        )
      ),
      
      # Generate button
      shiny::div(
        style = "text-align: center; margin: 30px 0;",
        shiny::actionButton("generate", shiny::HTML("<span style='font-size: 16px; font-weight: bold;'>GENERATE \u25B6</span>"), 
                          class = "btn-primary btn-lg")
      ),
      
      # Download section (hidden until files are generated)
      shiny::uiOutput("download_section")
    )
  )
  
  # Define server logic
  server <- function(input, output, session) {
    
    # Reactive values
    rv <- shiny::reactiveValues(
      lang = "en",
      qmd_file = NULL,
      html_file = NULL,
      qmd_files = list(),
      html_files = list(),
      generated = FALSE,
      batch_mode = FALSE,
      selected_dir = NULL
    )
    
    # Initialize directory chooser
    volumes <- c(Home = path.expand("~"), shinyFiles::getVolumes()())
    shinyFiles::shinyDirChoose(input, "input_directory", roots = volumes, session = session)
    
    # Display selected directory
    shiny::observeEvent(input$input_directory, {
      if (!is.integer(input$input_directory)) {
        dir_path <- shinyFiles::parseDirPath(volumes, input$input_directory)
        if (length(dir_path) > 0) {
          rv$selected_dir <- as.character(dir_path)
        }
      }
    })
    
    output$selected_directory <- shiny::renderText({
      if (!is.null(rv$selected_dir)) {
        if (rv$lang == "en") {
          paste0("Selected: ", rv$selected_dir)
        } else {
          paste0("S\u00E9lectionn\u00E9 : ", rv$selected_dir)
        }
      } else {
        if (rv$lang == "en") {
          "No directory selected"
        } else {
          "Aucun r\u00E9pertoire s\u00E9lectionn\u00E9"
        }
      }
    })
    
    # Language management
    shiny::observeEvent(input$lang_en, { rv$lang <- "en" })
    shiny::observeEvent(input$lang_fr, { rv$lang <- "fr" })
    
    # Dynamic labels
    output$label_mode <- shiny::renderText({
      if (rv$lang == "en") "Conversion mode:" else "Mode de conversion :"
    })
    
    output$label_upload_file <- shiny::renderText({
      if (rv$lang == "en") "Upload R Script (.R)" else "T\u00E9l\u00E9charger le Script R (.R)"
    })
    
    output$label_upload_files <- shiny::renderText({
      if (rv$lang == "en") "Upload Multiple R Scripts (.R)" else "T\u00E9l\u00E9charger Plusieurs Scripts R (.R)"
    })
    
    output$label_batch_source <- shiny::renderText({
      if (rv$lang == "en") "Batch Source:" else "Source du Batch :"
    })
    
    output$button_upload <- shiny::renderText({
      if (rv$lang == "en") "Browse..." else "Parcourir..."
    })
    
    output$button_upload_batch <- shiny::renderText({
      if (rv$lang == "en") "Browse..." else "Parcourir..."
    })
    
    output$button_select_directory <- shiny::renderText({
      if (rv$lang == "en") "Select Directory" else "S\u00E9lectionner un R\u00E9pertoire"
    })
    
    output$label_title <- shiny::renderText({
      if (rv$lang == "en") "Document Title" else "Titre du Document"
    })
    
    output$label_author <- shiny::renderText({
      if (rv$lang == "en") "Author (optional)" else "Auteur (optionnel)"
    })
    
    output$label_theme <- shiny::renderText({
      if (rv$lang == "en") "HTML Theme" else "Th\u00E8me HTML"
    })
    
    output$label_render <- shiny::renderText({
      if (rv$lang == "en") "Generate HTML" else "G\u00E9n\u00E9rer le HTML"
    })
    
    output$label_code_fold <- shiny::renderText({
      if (rv$lang == "en") "Fold code blocks by default" else "Replier les blocs de code par d\u00E9faut"
    })
    
    output$label_number_sections <- shiny::renderText({
      if (rv$lang == "en") "Number sections automatically" else "Num\u00E9roter les sections automatiquement"
    })
    
    output$label_show_source_lines <- shiny::renderText({
      if (rv$lang == "en") "Show original line numbers" else "Afficher les num\u00E9ros de ligne originaux"
    })
    
    output$label_create_book <- shiny::renderText({
      if (rv$lang == "en") "Create Quarto Book (with table of contents)" else "Cr\u00E9er un Quarto Book (avec table des mati\u00E8res)"
    })
    
    output$label_book_description <- shiny::renderText({
      if (rv$lang == "en") {
        "Creates a Quarto book with _quarto.yml that respects the directory structure and provides a unified navigation."
      } else {
        "Cr\u00E9e un Quarto book avec _quarto.yml qui respecte la structure des r\u00E9pertoires et fournit une navigation unifi\u00E9e."
      }
    })
    
    # Generation process
    shiny::observeEvent(input$generate, {
      
      # Check mode and validate input
      is_batch <- input$conversion_mode == "batch"
      
      if (is_batch) {
        # Check if either files are uploaded or directory is selected
        has_files <- !is.null(input$input_files)
        has_directory <- !is.null(rv$selected_dir) && input$batch_source_type == "directory"
        
        if (!has_files && !has_directory) {
          shiny::showNotification(
            if (rv$lang == "en") "Please upload R scripts or select a directory" else "Veuillez t\u00E9l\u00E9charger des scripts R ou s\u00E9lectionner un r\u00E9pertoire",
            type = "error"
          )
          return()
        }
      } else {
        if (is.null(input$input_file)) {
          shiny::showNotification(
            if (rv$lang == "en") "Please upload an R script first" else "Veuillez d'abord t\u00E9l\u00E9charger un script R",
            type = "error"
          )
          return()
        }
      }
      
      session$sendCustomMessage("toggleLoader", TRUE)
      rv$generated <- FALSE
      rv$batch_mode <- is_batch
      
      tryCatch({
        # Get theme value
        theme_val <- input$theme
        if (theme_val == "") theme_val <- NULL
        
        if (is_batch) {
          # BATCH MODE: Process multiple files or directory
          temp_dir <- file.path(tempdir(), "quartify_batch")
          if (!dir.exists(temp_dir)) dir.create(temp_dir, recursive = TRUE)
          
          # Determine input source
          if (input$batch_source_type == "directory" && !is.null(rv$selected_dir)) {
            # Use selected directory directly
            input_dir <- rv$selected_dir
          } else {
            # Copy uploaded files to temp directory
            input_dir <- file.path(temp_dir, "input")
            if (!dir.exists(input_dir)) dir.create(input_dir)
            
            for (i in seq_len(nrow(input$input_files))) {
              file.copy(input$input_files$datapath[i], 
                       file.path(input_dir, input$input_files$name[i]))
            }
          }
          
          # Create output directory
          output_dir <- file.path(temp_dir, "output")
          if (!dir.exists(output_dir)) dir.create(output_dir)
          
          # Call rtoqmd_dir with book creation if requested
          create_book_opt <- if (is.null(input$create_book)) FALSE else input$create_book
          
          rtoqmd_dir(
            dir_path = input_dir,
            output_html_dir = if (!create_book_opt && input$render_html) output_dir else NULL,
            title_prefix = if (input$doc_title != "My Analysis") paste0(input$doc_title, " - ") else NULL,
            author = if (input$doc_author == "") "Your name" else input$doc_author,
            theme = theme_val,
            render = input$render_html,
            code_fold = input$code_fold,
            number_sections = input$number_sections,
            create_book = create_book_opt,
            book_title = input$doc_title,
            output_dir = if (create_book_opt) output_dir else NULL
          )
          
          # Collect generated files
          if (create_book_opt && input$render_html) {
            # Book mode: collect from _book directory
            book_dir <- file.path(input_dir, "_book")
            rv$qmd_files <- list.files(input_dir, pattern = "\\.qmd$", full.names = TRUE, recursive = TRUE)
            rv$html_files <- if (dir.exists(book_dir)) {
              list.files(book_dir, pattern = "\\.html$", full.names = TRUE, recursive = TRUE)
            } else {
              list()
            }
            # Also include _quarto.yml
            quarto_yml <- file.path(input_dir, "_quarto.yml")
            if (file.exists(quarto_yml)) {
              rv$qmd_files <- c(rv$qmd_files, quarto_yml)
            }
          } else {
            # Regular mode: collect from input_dir
            rv$qmd_files <- list.files(input_dir, pattern = "\\.qmd$", full.names = TRUE)
            rv$html_files <- if (input$render_html) {
              if (!is.null(output_dir) && dir.exists(output_dir)) {
                list.files(output_dir, pattern = "\\.html$", full.names = TRUE)
              } else {
                list.files(input_dir, pattern = "\\.html$", full.names = TRUE)
              }
            } else {
              list()
            }
          }
          
        } else {
          # SINGLE FILE MODE: Process one file
          temp_dir <- tempdir()
          input_path <- input$input_file$datapath
          qmd_path <- file.path(temp_dir, "output.qmd")
          
          # Call rtoqmd to generate .qmd
          rtoqmd(
            input_file = input_path,
            output_file = qmd_path,
            title = input$doc_title,
            author = if (input$doc_author == "") NULL else input$doc_author,
            theme = theme_val,
            render = FALSE,  # We'll render separately
            code_fold = input$code_fold,
            number_sections = input$number_sections,
            show_source_lines = input$show_source_lines,
            lang = rv$lang
          )
          
          rv$qmd_file <- qmd_path
          
          # Render HTML if requested
          if (input$render_html) {
            # Change working directory to temp_dir to avoid path issues with Quarto
            old_wd <- getwd()
            setwd(temp_dir)
            tryCatch({
              quarto::quarto_render("output.qmd", output_file = "output.html")
              rv$html_file <- file.path(temp_dir, "output.html")
            }, finally = {
            setwd(old_wd)
          })
        } else {
          rv$html_file <- NULL
        }
        }
        
        rv$generated <- TRUE
        session$sendCustomMessage("toggleLoader", FALSE)
        
        success_msg <- if (is_batch) {
          if (rv$lang == "en") {
            sprintf("\u2714 %d files generated successfully! Check the download section below.", 
                   length(rv$qmd_files))
          } else {
            sprintf("\u2714 %d fichiers g\u00E9n\u00E9r\u00E9s avec succ\u00E8s ! Consultez la section de t\u00E9l\u00E9chargement ci-dessous.", 
                   length(rv$qmd_files))
          }
        } else {
          if (rv$lang == "en") "\u2714 Files generated successfully! Check the download section below." 
          else "\u2714 Fichiers g\u00E9n\u00E9r\u00E9s avec succ\u00E8s ! Consultez la section de t\u00E9l\u00E9chargement ci-dessous."
        }
        
        shiny::showNotification(
          success_msg,
          type = "message",
          duration = 10
        )
        
      }, error = function(e) {
        session$sendCustomMessage("toggleLoader", FALSE)
        shiny::showNotification(
          paste0("Error: ", e$message),
          type = "error",
          duration = 10
        )
      })
    })
    
    # Download section
    output$download_section <- shiny::renderUI({
      if (!rv$generated) return(NULL)
      
      if (rv$batch_mode) {
        # BATCH MODE: Download ZIP
        shiny::div(
          class = "download-section",
          shiny::h4(
            if (rv$lang == "en") {
              sprintf("\u2714 %d Files Ready for Download", length(rv$qmd_files))
            } else {
              sprintf("\u2714 %d Fichiers Pr\u00EAts \u00E0 T\u00E9l\u00E9charger", length(rv$qmd_files))
            }
          ),
          shiny::p(
            if (rv$lang == "en") "Download all files as ZIP archive:" 
            else "T\u00E9l\u00E9charger tous les fichiers en archive ZIP :"
          ),
          shiny::fluidRow(
            shiny::column(12,
              shiny::downloadButton("download_zip", 
                                  if (rv$lang == "en") "Download ZIP" else "T\u00E9l\u00E9charger ZIP",
                                  class = "btn-success btn-lg btn-block")
            )
          )
        )
      } else {
        # SINGLE MODE: Download individual files
        shiny::div(
          class = "download-section",
          shiny::h4(if (rv$lang == "en") "\u2714 Files Ready for Download" else "\u2714 Fichiers Pr\u00EAts \u00E0 T\u00E9l\u00E9charger"),
          shiny::fluidRow(
            shiny::column(6,
              shiny::downloadButton("download_qmd", 
                                  if (rv$lang == "en") "Download .qmd" else "T\u00E9l\u00E9charger .qmd",
                                  class = "btn-success btn-block")
            ),
            if (!is.null(rv$html_file)) {
              shiny::column(6,
                shiny::downloadButton("download_html", 
                                    if (rv$lang == "en") "Download .html" else "T\u00E9l\u00E9charger .html",
                                    class = "btn-success btn-block")
              )
            } else {
              NULL
            }
          )
        )
      }
    })
    
    # Download handlers - Single mode
    output$download_qmd <- shiny::downloadHandler(
      filename = function() {
        paste0(tools::file_path_sans_ext(basename(input$input_file$name)), ".qmd")
      },
      content = function(file) {
        file.copy(rv$qmd_file, file)
      }
    )
    
    output$download_html <- shiny::downloadHandler(
      filename = function() {
        paste0(tools::file_path_sans_ext(basename(input$input_file$name)), ".html")
      },
      content = function(file) {
        file.copy(rv$html_file, file)
      }
    )
    
    # Download handler - Batch mode (ZIP)
    output$download_zip <- shiny::downloadHandler(
      filename = function() {
        paste0("quartify_batch_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".zip")
      },
      content = function(file) {
        # Create temporary directory for zip
        temp_zip_dir <- file.path(tempdir(), "quartify_zip")
        if (dir.exists(temp_zip_dir)) unlink(temp_zip_dir, recursive = TRUE)
        dir.create(temp_zip_dir)
        
        # Copy all files to temp directory
        all_files <- c(rv$qmd_files, rv$html_files)
        for (f in all_files) {
          file.copy(f, file.path(temp_zip_dir, basename(f)))
        }
        
        # Create ZIP
        old_wd <- getwd()
        setwd(temp_zip_dir)
        utils::zip(file, files = list.files())
        setwd(old_wd)
      }
    )
  }
  
  # Run app
  if (is.null(port)) {
    shiny::runApp(list(ui = ui, server = server), launch.browser = launch.browser)
  } else {
    shiny::runApp(list(ui = ui, server = server), launch.browser = launch.browser, port = port)
  }
  
  invisible()
}
