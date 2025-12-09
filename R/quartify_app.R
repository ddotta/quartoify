#' Launch Quartify Standalone Application
#'
#' Standalone Shiny application for converting R scripts to Quarto markdown documents.
#' Works in any R environment (RStudio, Positron, VS Code, etc.) without requiring
#' the RStudio API.
#'
#' @param launch.browser Logical, whether to launch browser (default: TRUE)
#' @param port Integer, port number for the application (default: NULL for random port)
#'
#' @return No return value, called for side effects (launches a Shiny application).
#' @export
#'
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
            shiny::conditionalPanel(
              condition = "output.current_lang == 'en'",
              shiny::radioButtons("conversion_mode", 
                                shiny::textOutput("label_mode", inline = TRUE),
                                choices = c("One or more files" = "single", "Directory" = "directory"),
                                selected = "single",
                                inline = TRUE)
            ),
            shiny::conditionalPanel(
              condition = "output.current_lang == 'fr'",
              shiny::radioButtons("conversion_mode", 
                                shiny::textOutput("label_mode", inline = TRUE),
                                choices = c("Un ou plusieurs fichiers" = "single", "Repertoire" = "directory"),
                                selected = "single",
                                inline = TRUE)
            )
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
                shinyFiles::shinyFilesButton("input_file_btn", "Browse", "Select R script(s)", multiple = TRUE, class = "btn-primary")
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
      
      # Parameters
      shiny::fluidRow(
        shiny::conditionalPanel(
          condition = "input.conversion_mode == 'single'",
          shiny::column(4, shiny::textInput("title", shiny::textOutput("label_title"), value = "My Analysis", width = "100%"))
        ),
        shiny::conditionalPanel(
          condition = "input.conversion_mode == 'directory'",
          shiny::column(4)
        ),
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
      shiny::uiOutput("ui_checkboxes"),
      
      shiny::hr(),
      
      # Code Quality Checkboxes
      shiny::uiOutput("ui_code_quality")
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
    selected_output_dir <- shiny::reactiveVal(NULL)
    
    volumes <- c(Home = path.expand("~"), shinyFiles::getVolumes()())
    shinyFiles::shinyFileChoose(input, "input_file_btn", roots = volumes, session = session, filetypes = c("", "R"))
    
    # Directory choosers
    shinyFiles::shinyDirChoose(input, "input_directory", roots = volumes)
    shinyFiles::shinyDirChoose(input, "output_directory", roots = volumes)
    
    shiny::observeEvent(input$input_directory, {
      dir_path <- shinyFiles::parseDirPath(volumes, input$input_directory)
      if (length(dir_path) > 0) {
        selected_dir(as.character(dir_path))
      }
    })
    
    shiny::observeEvent(input$output_directory, {
      dir_path <- shinyFiles::parseDirPath(volumes, input$output_directory)
      if (length(dir_path) > 0 && !any(is.na(dir_path))) {
        selected_output_dir(as.character(dir_path))
      }
    })
    
    # Display selected directories
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
        if (lang() == "fr") "(selectionner un fichier)" else "(select a file)"
      } else {
        basename(path)
      }
    })
    
    output$output_file_display <- shiny::renderText({
      path <- output_file_path()
      if (is.null(path)) {
        if (lang() == "fr") "(selectionner un fichier)" else "(select a file)"
      } else {
        basename(path)
      }
    })
    
    output$html_file_display <- shiny::renderText({
      path <- html_file_path()
      if (is.null(path)) {
        if (lang() == "fr") "(emplacement par defaut)" else "(default location)"
      } else {
        basename(path)
      }
    })
    
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
        show_source_lines = "Show original line numbers in code chunks",
        code_quality = "Code Quality Checks:",
        use_styler = "Use styler formatting (shows styled version in tabs)",
        use_lintr = "Use lintr quality checks (shows issues in tabs)",
        apply_styler = "Apply styler to source file (modifies original R file)"
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
        open_html = "Ouvrir le fichier Html apres rendu",
        open_qmd = "Ouvrir le fichier .qmd dans l'editeur apres conversion",
        code_fold = "Replier les blocs de code par defaut",
        number_sections = "Numeroter les sections automatiquement (pas utile si vos sections sont dej\u00E0 numerotees)",
        show_source_lines = "Afficher les numeros de ligne originaux dans les chunks",
        code_quality = "Verifications de la qualite du code :",
        use_styler = "Utiliser styler pour le formatage (affiche la version stylisee dans des onglets)",
        use_lintr = "Utiliser lintr pour la qualite du code (affiche les problemes dans des onglets)",
        apply_styler = "Appliquer styler au fichier source (modifie le fichier R original)"
      )
    )
    
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
    
    # Dynamic UI for checkboxes
    output$ui_checkboxes <- shiny::renderUI({
      trans <- translations[[lang()]]
      shiny::fluidRow(
        shiny::column(6,
          shiny::checkboxInput("render", trans$render, value = TRUE),
          shiny::conditionalPanel(
            condition = "input.conversion_mode == 'single'",
            shiny::checkboxInput("open_qmd", trans$open_qmd, value = FALSE)
          ),
          shiny::checkboxInput("number_sections", trans$number_sections, value = TRUE)
        ),
        shiny::column(6,
          shiny::checkboxInput("code_fold", trans$code_fold, value = FALSE),
          shiny::conditionalPanel(
            condition = "input.conversion_mode == 'single'",
            shiny::checkboxInput("open_html", trans$open_html, value = FALSE)
          ),
          shiny::checkboxInput("show_source_lines", trans$show_source_lines, value = TRUE)
        )
      )
    })
    
    # Dynamic UI for code quality checkboxes
    output$ui_code_quality <- shiny::renderUI({
      trans <- translations[[lang()]]
      shiny::div(
        shiny::h4(trans$code_quality, style = "color: #0073e6; margin-bottom: 15px;"),
        shiny::fluidRow(
          shiny::column(6,
            shiny::checkboxInput("use_styler", trans$use_styler, value = FALSE),
            shiny::checkboxInput("use_lintr", trans$use_lintr, value = FALSE)
          ),
          shiny::column(6,
            shiny::checkboxInput("apply_styler", trans$apply_styler, value = FALSE)
          )
        )
      )
    })
    
    shiny::observeEvent(input$done, {
      
      # Check mode
      is_directory_mode <- input$conversion_mode == "directory"
      
      # Validation based on mode
      if (is_directory_mode) {
        if (is.null(selected_dir())) {
          shiny::showNotification(
            if (lang() == "fr") "Veuillez selectionner un repertoire" else "Please select a directory",
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
            if (lang() == "fr") "Veuillez selectionner les fichiers d'entree et de sortie" else "Please select input and output files",
            type = "error",
            duration = 5
          )
          return()
        }
      }
      
      session$sendCustomMessage('toggleLoader', TRUE)
      
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
      use_styler <- input$use_styler
      use_lintr <- input$use_lintr
      apply_styler <- input$apply_styler
      
      tryCatch({
        if (is_directory_mode) {
          # Directory mode
          dir_path <- selected_dir()
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
            show_source_lines = show_source_lines,
            use_styler = use_styler,
            use_lintr = use_lintr,
            apply_styler = apply_styler
          )
          
          if (open_qmd && file.exists(output_file_final)) {
            utils::browseURL(output_file_final)
          }
        }
        
        session$sendCustomMessage('toggleLoader', FALSE)
        
        success_msg <- if (lang() == "fr") {
          "\u2705 Conversion terminee avec succes !"
        } else {
          "\u2705 Conversion completed successfully!"
        }
        
        shiny::showNotification(
          success_msg,
          type = "message",
          duration = 5,
          closeButton = TRUE
        )
        
      }, error = function(e) {
        session$sendCustomMessage('toggleLoader', FALSE)
        shiny::showNotification(
          paste0("Error: ", e$message),
          type = "error",
          duration = 10
        )
      })
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
