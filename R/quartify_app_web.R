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
#' @importFrom shiny runApp stopApp observeEvent reactive req textInput checkboxInput actionButton renderText reactiveVal tags fluidPage fluidRow column div hr fileInput downloadButton downloadHandler uiOutput renderUI
#' @importFrom base64enc base64encode
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
          background-color: rgba(0, 0, 0, 0.6);
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
    
    # Generate button
    shiny::div(
      style = "text-align: center; margin: 20px auto; padding: 15px 0; background-color: #f8f9fa; border-bottom: 1px solid #dee2e6; max-width: 1200px;",
      logo_html,
      shiny::br(),
      shiny::actionButton("generate", "GENERATE", class = "btn-primary btn-lg", style = "font-size: 16px; font-weight: bold; padding: 10px 40px; margin-top: 10px;")
    ),
    
    # Main content
    shiny::div(
      style = "max-width: 1200px; margin: 0 auto;",
      
      # Mode selection
      shiny::fluidRow(
        shiny::column(12,
          shiny::div(
            style = "margin-bottom: 20px;",
            shiny::uiOutput("mode_selector_web")
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
      
      # Batch file upload
      shiny::conditionalPanel(
        condition = "input.conversion_mode == 'batch'",
        shiny::fluidRow(
          shiny::column(12,
            shiny::div(
              style = "margin-bottom: 20px;",
              shiny::strong(shiny::textOutput("label_batch_upload")),
              shiny::fileInput("input_files", NULL, accept = c(".R", ".r"), 
                             multiple = TRUE,
                             buttonLabel = shiny::textOutput("button_upload_batch", inline = TRUE))
            )
          )
        )
      ),
      
      # Options
      shiny::fluidRow(
        shiny::conditionalPanel(
          condition = "input.conversion_mode == 'single'",
          shiny::column(6,
            shiny::div(
              style = "margin-bottom: 15px;",
              shiny::strong(shiny::textOutput("label_title")),
              shiny::textInput("doc_title", NULL, value = "My Analysis", width = "100%")
            )
          )
        ),
        shiny::conditionalPanel(
          condition = "input.conversion_mode == 'batch'",
          shiny::column(6)
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
      shiny::uiOutput("ui_checkboxes"),
      
      # Code quality checkboxes
      shiny::hr(),
      shiny::uiOutput("ui_code_quality"),
      
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
      book_dir = NULL,
      generated = FALSE,
      batch_mode = FALSE
    )
    
    # Language management
    shiny::observeEvent(input$lang_en, { rv$lang <- "en" })
    shiny::observeEvent(input$lang_fr, { rv$lang <- "fr" })
    
    # Dynamic UI for mode selection
    output$mode_selector_web <- shiny::renderUI({
      if (rv$lang == "fr") {
        shiny::radioButtons("conversion_mode", 
                          "Mode de conversion :",
                          choices = c("Un fichier" = "single", "Repertoire (plusieurs fichiers)" = "batch"),
                          selected = "single",
                          inline = TRUE)
      } else {
        shiny::radioButtons("conversion_mode", 
                          "Conversion mode:",
                          choices = c("Single file" = "single", "Batch (multiple files)" = "batch"),
                          selected = "single",
                          inline = TRUE)
      }
    })
    
    # Dynamic labels
    output$label_mode <- shiny::renderText({
      if (rv$lang == "en") "Conversion mode:" else "Mode de conversion :"
    })
    
    output$label_upload_file <- shiny::renderText({
      if (rv$lang == "en") "Upload R Script (.R)" else "Telecharger le Script R (.R)"
    })
    
    output$label_upload_files <- shiny::renderText({
      if (rv$lang == "en") "Upload Multiple R Scripts (.R)" else "Telecharger Plusieurs Scripts R (.R)"
    })
    
    output$label_batch_upload <- shiny::renderText({
      if (rv$lang == "en") "Upload Multiple R Scripts:" else "Telecharger Plusieurs Scripts R :"
    })
    
    output$button_upload <- shiny::renderText({
      if (rv$lang == "en") "Browse..." else "Parcourir..."
    })
    
    output$button_upload_batch <- shiny::renderText({
      if (rv$lang == "en") "Browse..." else "Parcourir..."
    })
    
    output$label_title <- shiny::renderText({
      if (rv$lang == "en") "Document Title" else "Titre du Document"
    })
    
    output$label_author <- shiny::renderText({
      if (rv$lang == "en") "Author (optional)" else "Auteur (optionnel)"
    })
    
    output$label_theme <- shiny::renderText({
      if (rv$lang == "en") "HTML Theme" else "Theme HTML"
    })
    
    # Render main checkboxes with dynamic labels
    output$ui_checkboxes <- shiny::renderUI({
      is_en <- rv$lang == "en"
      shiny::fluidRow(
        shiny::column(6,
          shiny::checkboxInput("render_html", 
            if (is_en) "Generate HTML" else "Generer le HTML", 
            value = TRUE),
          shiny::checkboxInput("number_sections", 
            if (is_en) "Number sections automatically" else "Numeroter les sections automatiquement", 
            value = TRUE),
          shiny::checkboxInput("show_source_lines", 
            if (is_en) "Show original line numbers" else "Afficher les numeros de ligne originaux", 
            value = TRUE)
        ),
        shiny::column(6,
          shiny::checkboxInput("code_fold", 
            if (is_en) "Fold code blocks by default" else "Replier les blocs de code par defaut", 
            value = FALSE)
        )
      )
    })
    
    # Render code quality checkboxes with dynamic labels
    output$ui_code_quality <- shiny::renderUI({
      is_en <- rv$lang == "en"
      shiny::div(
        shiny::h4(
          if (is_en) "Code Quality Checks:" else "Verifications de la qualite du code :",
          style = "color: #0073e6; margin-top: 15px;"
        ),
        shiny::checkboxInput("use_styler", 
          if (is_en) "Use styler formatting (shows styled version in tabs)" 
          else "Utiliser styler pour le formatage (affiche la version stylisee dans des onglets)", 
          value = FALSE),
        shiny::checkboxInput("use_lintr", 
          if (is_en) "Use lintr quality checks (shows issues in tabs)" 
          else "Utiliser lintr pour la qualite du code (affiche les problemes dans des onglets)", 
          value = FALSE)
      )
    })
    
    output$label_create_book <- shiny::renderText({
      if (rv$lang == "en") "Create Quarto Book (with table of contents)" else "Creer un Quarto Book (avec table des matieres)"
    })
    
    output$label_book_description <- shiny::renderText({
      if (rv$lang == "en") {
        "Creates a Quarto book with _quarto.yml that respects the directory structure and provides a unified navigation."
      } else {
        "Cree un Quarto book avec _quarto.yml qui respecte la structure des repertoires et fournit une navigation unifiee."
      }
    })
    
    # Generation process
    shiny::observeEvent(input$generate, {
      
      # Check mode and validate input
      is_batch <- input$conversion_mode == "batch"
      
      if (is_batch) {
        # Check if files are uploaded
        if (is.null(input$input_files)) {
          shiny::showNotification(
            if (rv$lang == "en") "Please upload R scripts" else "Veuillez telecharger des scripts R",
            type = "error"
          )
          return()
        }
      } else {
        if (is.null(input$input_file)) {
          shiny::showNotification(
            if (rv$lang == "en") "Please upload an R script first" else "Veuillez d'abord telecharger un script R",
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
        
        # Get title value (empty in batch mode)
        title_val <- if (is_batch) "" else input$doc_title
        
        if (is_batch) {
          # BATCH MODE: Process multiple files or directory
          temp_dir <- file.path(tempdir(), "quartify_batch")
          if (!dir.exists(temp_dir)) dir.create(temp_dir, recursive = TRUE)
          
          # Copy uploaded files to temp directory
          input_dir <- file.path(temp_dir, "input")
          if (!dir.exists(input_dir)) dir.create(input_dir)
          
          for (i in seq_len(nrow(input$input_files))) {
            file.copy(input$input_files$datapath[i], 
                     file.path(input_dir, input$input_files$name[i]))
          }
          
          # Create output directory
          output_dir <- file.path(temp_dir, "output")
          if (!dir.exists(output_dir)) dir.create(output_dir)
          
          # Call rtoqmd_dir with book creation if requested
          create_book_opt <- if (is.null(input$create_book)) FALSE else input$create_book
          
          rtoqmd_dir(
            dir_path = input_dir,
            output_html_dir = NULL,  # Don't use output_html_dir to avoid auto-enabling book mode
            title_prefix = if (title_val != "" && title_val != "My Analysis") paste0(title_val, " - ") else "",
            author = if (input$doc_author == "") "Your name" else input$doc_author,
            theme = theme_val,
            render_html = input$render_html,
            code_fold = input$code_fold,
            number_sections = input$number_sections,
            create_book = create_book_opt,
            book_title = title_val,
            output_dir = if (create_book_opt) output_dir else NULL,
            language = rv$lang,
            use_styler = if (!is.null(input$use_styler)) input$use_styler else FALSE,
            use_lintr = if (!is.null(input$use_lintr)) input$use_lintr else FALSE,
            apply_styler = FALSE  # Disabled for web version for security
          )
          
          # Collect generated files
          if (create_book_opt && input$render_html) {
            # Book mode: collect QMD and all files from _book directory
            if (!is.null(output_dir) && dir.exists(output_dir)) {
              # If output_dir was specified, files are there
              book_dir <- file.path(output_dir, "_book")
              
              if (dir.exists(book_dir)) {
                # All files in _book subdirectory (recursive, with full structure)
                rv$book_dir <- book_dir
                rv$html_files <- list.files(book_dir, full.names = TRUE, recursive = TRUE, all.files = FALSE)
              } else {
                # All files directly in output_dir
                rv$book_dir <- output_dir
                rv$html_files <- list.files(output_dir, full.names = TRUE, recursive = TRUE, all.files = FALSE)
              }
              # QMD files might be in output_dir too
              rv$qmd_files <- list.files(output_dir, pattern = "\\.qmd$", full.names = TRUE, recursive = TRUE)
              # Also check input_dir for QMD files
              rv$qmd_files <- c(rv$qmd_files, list.files(input_dir, pattern = "\\.qmd$", full.names = TRUE, recursive = TRUE))
            } else {
              # Standard book mode in input_dir
              book_dir <- file.path(input_dir, "_book")
              rv$qmd_files <- list.files(input_dir, pattern = "\\.qmd$", full.names = TRUE, recursive = TRUE)
              if (dir.exists(book_dir)) {
                rv$book_dir <- book_dir
                rv$html_files <- list.files(book_dir, full.names = TRUE, recursive = TRUE)
              } else {
                rv$book_dir <- NULL
                rv$html_files <- list()
              }
            }
            # Also include _quarto.yml if it exists
            quarto_yml <- file.path(input_dir, "_quarto.yml")
            if (file.exists(quarto_yml)) {
              rv$qmd_files <- c(rv$qmd_files, quarto_yml)
            }
            # Remove duplicates
            rv$qmd_files <- unique(rv$qmd_files)
          } else {
            # Regular mode: collect from input_dir (HTML and QMD are in the same place)
            rv$book_dir <- input_dir  # Set to input_dir for proper HTML collection
            rv$qmd_files <- list.files(input_dir, pattern = "\\.qmd$", full.names = TRUE)
            rv$html_files <- if (input$render_html) {
              # Get all HTML files including subdirectories and resources
              list.files(input_dir, pattern = "\\.html$", full.names = TRUE, recursive = TRUE)
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
            title = title_val,
            author = if (input$doc_author == "") NULL else input$doc_author,
            theme = theme_val,
            render_html = FALSE,  # We'll render separately
            code_fold = input$code_fold,
            number_sections = input$number_sections,
            show_source_lines = input$show_source_lines,
            lang = rv$lang,
            use_styler = if (!is.null(input$use_styler)) input$use_styler else FALSE,
            use_lintr = if (!is.null(input$use_lintr)) input$use_lintr else FALSE,
            apply_styler = FALSE  # Disabled for web version for security
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
            sprintf("[OK] %d files generated successfully! Check the download section below.", 
                   length(rv$qmd_files))
          } else {
            sprintf("[OK] %d fichiers generes avec succes ! Consultez la section de telechargement ci-dessous.", 
                   length(rv$qmd_files))
          }
        } else {
          if (rv$lang == "en") "[OK] Files generated successfully! Check the download section below." 
          else "[OK] Fichiers generes avec succes ! Consultez la section de telechargement ci-dessous."
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
              sprintf("[OK] %d Files Ready for Download", length(rv$qmd_files))
            } else {
              sprintf("[OK] %d Fichiers Prets a Telecharger", length(rv$qmd_files))
            }
          ),
          shiny::p(
            if (rv$lang == "en") "Download all files as ZIP archive:" 
            else "Telecharger tous les fichiers en archive ZIP :"
          ),
          shiny::fluidRow(
            shiny::column(12,
              shiny::downloadButton("download_zip", 
                                  if (rv$lang == "en") "Download ZIP" else "Telecharger ZIP",
                                  class = "btn-success btn-lg btn-block")
            )
          )
        )
      } else {
        # SINGLE MODE: Download individual files
        shiny::div(
          class = "download-section",
          shiny::h4(if (rv$lang == "en") "[OK] Files Ready for Download" else "[OK] Fichiers Prets a Telecharger"),
          shiny::fluidRow(
            shiny::column(6,
              shiny::downloadButton("download_qmd", 
                                  if (rv$lang == "en") "Download .qmd" else "Telecharger .qmd",
                                  class = "btn-success btn-block")
            ),
            if (!is.null(rv$html_file)) {
              shiny::column(6,
                shiny::downloadButton("download_html", 
                                    if (rv$lang == "en") "Download .html" else "Telecharger .html",
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
        
        # Copy QMD files (flat structure)
        qmd_dir <- file.path(temp_zip_dir, "qmd")
        dir.create(qmd_dir)
        for (f in rv$qmd_files) {
          if (file.exists(f)) {
            file.copy(f, file.path(qmd_dir, basename(f)))
          }
        }
        
        # Copy HTML files with directory structure
        if (length(rv$html_files) > 0) {
          html_dir <- file.path(temp_zip_dir, "html")
          dir.create(html_dir)
          
          if (!is.null(rv$book_dir) && dir.exists(rv$book_dir)) {
            # Copy files preserving directory structure relative to book_dir
            for (src_file in rv$html_files) {
              if (!file.exists(src_file) || file.info(src_file)$isdir) next
              
              # Calculate relative path from book_dir
              src_normalized <- gsub("\\\\", "/", normalizePath(src_file, winslash = "/"))
              base_normalized <- gsub("\\\\", "/", normalizePath(rv$book_dir, winslash = "/"))
              
              rel_path <- sub(paste0("^", base_normalized, "/?"), "", src_normalized)
              dest_file <- file.path(html_dir, rel_path)
              
              # Create subdirectory if needed
              dest_dir <- dirname(dest_file)
              if (!dir.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE)
              
              file.copy(src_file, dest_file, overwrite = TRUE)
            }
          } else {
            # Fallback: copy files flat (no structure)
            for (f in rv$html_files) {
              if (file.exists(f)) {
                file.copy(f, file.path(html_dir, basename(f)), overwrite = TRUE)
              }
            }
          }
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
