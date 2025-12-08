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
  if (is.null(input_path) || length(input_path) == 0 || input_path == "") {
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
        .gadget-title {
          background-color: #0073e6 !important;
          color: white !important;
        }
        .loader {
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background-color: rgba(0, 0, 0, 0.6);
          display: none;
          justify-content: center;
          align-items: center;
          z-index: 9999;
        }
        .loader.active {
          display: flex;
        }
        .spinner {
          border: 8px solid #e0e0e0;
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
        )
      )
    ),
    shiny::div(id = "loader", class = "loader", shiny::div(class = "spinner")),
    miniUI::miniContentPanel(
      shiny::fillCol(
        flex = c(NA, 1),
        # Generate button
        shiny::div(
          style = "text-align: center; margin: 0; padding: 15px 0; background-color: #f8f9fa; border-bottom: 1px solid #dee2e6;",
          logo_html,
          shiny::br(),
          shiny::actionButton("done", "GENERATE", class = "btn-primary btn-lg", style = "font-size: 16px; font-weight: bold; padding: 10px 40px; margin-top: 10px;")
        ),
        shiny::fillRow(
          shiny::div(
            style = "padding: 20px; overflow-y: auto;",
            # Mode selection
            shiny::fluidRow(
              shiny::column(12,
                shiny::div(
                  style = "margin-bottom: 20px;",
                  shiny::uiOutput("mode_selector")
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
                      shinyFiles::shinyFilesButton("input_file_btn", "Browse", "Select R script(s)", multiple = TRUE, class = "btn-primary", style = "padding: 6px 12px;")
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
                shiny::column(6,
                  shiny::div(
                    style = "margin-bottom: 15px;",
                    shiny::strong(shiny::textOutput("label_input_directory")),
                    shiny::br(),
                    shiny::div(
                      style = "margin-top: 5px;",
                      shinyFiles::shinyDirButton("input_directory", 
                                                 "Browse", 
                                                 "Select directory containing R scripts",
                                                 class = "btn-primary",
                                                 style = "margin-bottom: 10px;"),
                      shiny::br(),
                      shiny::verbatimTextOutput("selected_directory", placeholder = TRUE)
                    )
                  )
                ),
                shiny::column(6,
                  shiny::div(
                    style = "margin-bottom: 15px;",
                    shiny::strong(shiny::textOutput("label_output_directory")),
                    shiny::br(),
                    shiny::div(
                      style = "margin-top: 5px;",
                      shinyFiles::shinyDirButton("output_directory", 
                                                 "Browse", 
                                                 "Select output directory for book",
                                                 class = "btn-primary",
                                                 style = "margin-bottom: 10px;"),
                      shiny::br(),
                      shiny::verbatimTextOutput("selected_output_directory", placeholder = TRUE)
                    )
                  )
                )
              ),
              shiny::fluidRow(
                shiny::column(12,
                  shiny::checkboxInput(
                    "create_book",
                    shiny::textOutput("label_create_book"),
                    value = TRUE
                  )
                )
              )
            ),
            shiny::hr(),
            # Title, Author, Theme on same row
            shiny::fluidRow(
              shiny::conditionalPanel(
                condition = "input.conversion_mode == 'single'",
                shiny::column(4, shiny::textInput(
                  "title",
                  shiny::textOutput("label_title"),
                  value = "My Analysis",
                  width = "100%"
                ))
              ),
              shiny::conditionalPanel(
                condition = "input.conversion_mode == 'directory'",
                shiny::column(4)
              ),
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
                shiny::conditionalPanel(
                  condition = "input.conversion_mode == 'single'",
                  shiny::checkboxInput(
                    "open_qmd",
                    shiny::textOutput("label_open_qmd"),
                    value = TRUE
                  )
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
                shiny::conditionalPanel(
                  condition = "input.conversion_mode == 'single'",
                  shiny::checkboxInput(
                    "open_html",
                    shiny::textOutput("label_open_html"),
                    value = FALSE
                  )
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
        if (lang() == "fr") "(emplacement par defaut)" else "(default location)"
      } else {
        basename(path)
      }
    })
    
    # Reactive values for file paths and directory
    selected_dir <- shiny::reactiveVal(NULL)
    selected_output_dir <- shiny::reactiveVal(NULL)
    
    # Directory choosers
    shinyFiles::shinyDirChoose(input, "input_directory", roots = volumes)
    shinyFiles::shinyDirChoose(input, "output_directory", roots = volumes)
    
    shiny::observeEvent(input$input_directory, {
      dir_path <- shinyFiles::parseDirPath(volumes, input$input_directory)
      if (length(dir_path) > 0) {
        dir_str <- as.character(dir_path)
        selected_dir(dir_str)
      }
    })
    
    shiny::observeEvent(input$output_directory, {
      dir_path <- shinyFiles::parseDirPath(volumes, input$output_directory)
      if (length(dir_path) > 0 && !any(is.na(dir_path))) {
        selected_output_dir(as.character(dir_path))
      }
    })
    
    # Display selected directory
    output$selected_directory <- shiny::renderText({
      if (!is.null(selected_dir())) {
        if (lang() == "fr") {
          paste0("Selectionne : ", selected_dir())
        } else {
          paste0("Selected: ", selected_dir())
        }
      } else {
        if (lang() == "fr") {
          "Aucun repertoire selectionne"
        } else {
          "No directory selected"
        }
      }
    })
    
    output$selected_output_directory <- shiny::renderText({
      if (!is.null(selected_output_dir())) {
        if (lang() == "fr") {
          paste0("Selectionne : ", selected_output_dir())
        } else {
          paste0("Selected: ", selected_output_dir())
        }
      } else {
        if (lang() == "fr") {
          "Aucun repertoire (defaut : _book)"
        } else {
          "None (default: _book)"
        }
      }
    })
    
    # Translations
    translations <- list(
      en = list(
        mode = "Conversion mode:",
        input_file = "Input file(s):",
        input_directory = "Input directory:",
        output_directory = "Output directory (for book):",
        button_select_directory = "Select Directory",
        create_book = "Create Quarto Book",
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
        input_file = "Fichier(s) d'entree :",
        input_directory = "Repertoire d'entree :",
        output_directory = "Repertoire de sortie (pour le book) :",
        button_select_directory = "Selectionner un Repertoire",
        create_book = "Creer un Quarto Book",
        output_file = "Chemin du fichier de sortie :",
        html_file = "Chemin du fichier HTML :",
        html_file_optional = "(optionnel - laisser vide pour l'emplacement par defaut)",
        title = "Titre du document :",
        author = "Nom de l'auteur :",
        theme = "Theme HTML :",
        render = "Generer Html apres conversion",
        open_html = "Ouvrir le fichier Html apr\\u00e8s rendu",
        open_qmd = "Ouvrir le fichier .qmd dans l'editeur apres conversion",
        code_fold = "Replier les blocs de code par d\\u00e9faut",
        number_sections = "Numeroter les sections automatiquement (pas utile si vos sections sont deja numerotees)",
        show_source_lines = "Afficher les numeros de ligne originaux dans les chunks"
      )
    )
    
    # Dynamic UI for mode selection
    output$mode_selector <- shiny::renderUI({
      if (lang() == "fr") {
        shiny::radioButtons("conversion_mode", 
                          translations[["fr"]]$mode,
                          choices = c("Un ou plusieurs fichiers" = "single", "Repertoire" = "directory"),
                          selected = "single",
                          inline = TRUE)
      } else {
        shiny::radioButtons("conversion_mode", 
                          translations[["en"]]$mode,
                          choices = c("One or more files" = "single", "Directory" = "directory"),
                          selected = "single",
                          inline = TRUE)
      }
    })
    
    # Dynamic labels
    output$label_mode <- shiny::renderText({ translations[[lang()]]$mode })
    output$label_input_file <- shiny::renderText({ translations[[lang()]]$input_file })
    output$label_input_directory <- shiny::renderText({ translations[[lang()]]$input_directory })
    output$label_output_directory <- shiny::renderText({ translations[[lang()]]$output_directory })
    output$button_select_directory <- shiny::renderText({ translations[[lang()]]$button_select_directory })
    output$label_create_book <- shiny::renderText({ translations[[lang()]]$create_book })
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
      
      # Check mode
      is_directory_mode <- input$conversion_mode == "directory"
      
      # Get common values
      title <- if (is_directory_mode) "" else shiny::req(input$title)
      author <- shiny::req(input$author)
      theme <- input$theme
      if (theme == "") theme <- NULL
      render <- input$render
      open_html <- input$open_html
      open_qmd <- input$open_qmd
      code_fold <- input$code_fold
      number_sections <- input$number_sections
      show_source_lines <- input$show_source_lines
      
      # Convert based on mode
      tryCatch({
        if (is_directory_mode) {
          # Directory mode
          dir_path <- shiny::req(selected_dir())
          output_dir <- selected_output_dir()
          create_book_val <- if (!is.null(input$create_book)) input$create_book else TRUE
          
          rtoqmd_dir(
            dir_path = dir_path,
            title_prefix = paste0(title, " - "),
            author = author,
            format = "html",
            theme = theme,
            render = render,
            output_dir = output_dir,
            create_book = create_book_val,
            code_fold = code_fold,
            number_sections = number_sections,
            language = lang()
          )
          
          # If rendering, wait for index.html to be created
          if (render && create_book_val) {
            book_dir <- if (!is.null(output_dir)) output_dir else "_book"
            if (!file.path(book_dir) %in% c("_documentation", "_book")) {
              book_dir <- file.path(dir_path, book_dir)
            } else {
              book_dir <- file.path(dir_path, book_dir)
            }
            index_file <- file.path(book_dir, "index.html")
            
            # Wait up to 60 seconds for index.html to be created
            max_wait <- 60
            waited <- 0
            while (!file.exists(index_file) && waited < max_wait) {
              Sys.sleep(0.5)
              waited <- waited + 0.5
            }
          }
          
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
          "[OK] Conversion terminee avec succes !"
        } else {
          "[OK] Conversion completed successfully!"
        }
        
        shiny::showNotification(
          success_msg,
          type = "message",
          duration = 5,
          closeButton = TRUE
        )
        
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
    
  }
  
  # Run the gadget
  viewer <- shiny::browserViewer()
  shiny::runGadget(ui, server, viewer = viewer, stopOnCancel = FALSE)
  
  invisible()
}
