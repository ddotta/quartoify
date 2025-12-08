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
      shiny::uiOutput("ui_checkboxes_web"),
      
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
          paste0("Selectionne : ", rv$selected_dir)
        }
      } else {
        if (rv$lang == "en") {
          "No directory selected"
        } else {
          "Aucun repertoire selectionne"
        }
      }
    })
    
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
      if (rv$lang == "en") "Select Directory" else "Selectionner un Repertoire"
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
    
    output$label_render <- shiny::renderText({
      if (rv$lang == "en") "Generate HTML" else "Generer le HTML"
    })
    
    output$label_code_fold <- shiny::renderText({
      if (rv$lang == "en") "Fold code blocks by default" else "Replier les blocs de code par defaut"
    })
    
    output$label_number_sections <- shiny::renderText({
      if (rv$lang == "en") "Number sections automatically" else "Numeroter les sections automatiquement"
    })
    
    output$label_show_source_lines <- shiny::renderText({
      if (rv$lang == "en") "Show original line numbers" else "Afficher les numeros de ligne originaux"
    })
    
    # Dynamic UI for checkboxes
    output$ui_checkboxes_web <- shiny::renderUI({
      if (rv$lang == "en") {
        shiny::fluidRow(
          shiny::column(6,
            shiny::checkboxInput("render_html", "Generate HTML", value = TRUE),
            shiny::checkboxInput("number_sections", "Number sections automatically", value = TRUE),
            shiny::checkboxInput("show_source_lines", "Show original line numbers", value = TRUE)
          ),
          shiny::column(6,
            shiny::checkboxInput("code_fold", "Fold code blocks by default", value = FALSE),
            shiny::checkboxInput("use_styler", "Use styler formatting (shows styled version in tabs)", value = FALSE),
            shiny::checkboxInput("use_lintr", "Use lintr quality checks (shows issues in tabs)", value = FALSE),
            shiny::checkboxInput("apply_styler", "Apply styler to source file (modifies original)", value = FALSE)
          )
        )
      } else {
        shiny::fluidRow(
          shiny::column(6,
            shiny::checkboxInput("render_html", "Generer le HTML", value = TRUE),
            shiny::checkboxInput("number_sections", "Numeroter les sections automatiquement", value = TRUE),
            shiny::checkboxInput("show_source_lines", "Afficher les numeros de ligne originaux", value = TRUE)
          ),
          shiny::column(6,
            shiny::checkboxInput("code_fold", "Replier les blocs de code par defaut", value = FALSE),
            shiny::checkboxInput("use_styler", "Utiliser styler pour le formatage (affiche la version stylisee dans des onglets)", value = FALSE),
            shiny::checkboxInput("use_lintr", "Utiliser lintr pour la qualite du code (affiche les problemes dans des onglets)", value = FALSE),
            shiny::checkboxInput("apply_styler", "Appliquer styler au fichier source (modifie l'original)", value = FALSE)
          )
        )
      }
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
        # Check if either files are uploaded or directory is selected
        has_files <- !is.null(input$input_files)
        has_directory <- !is.null(rv$selected_dir) && input$batch_source_type == "directory"
        
        if (!has_files && !has_directory) {
          shiny::showNotification(
            if (rv$lang == "en") "Please upload R scripts or select a directory" else "Veuillez telecharger des scripts R ou selectionner un repertoire",
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
            title_prefix = if (title_val != "" && title_val != "My Analysis") paste0(title_val, " - ") else "",
            author = if (input$doc_author == "") "Your name" else input$doc_author,
            theme = theme_val,
            render = input$render_html,
            code_fold = input$code_fold,
            number_sections = input$number_sections,
            create_book = create_book_opt,
            book_title = title_val,
            output_dir = if (create_book_opt) output_dir else NULL,
            language = rv$lang
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
            title = title_val,
            author = if (input$doc_author == "") NULL else input$doc_author,
            theme = theme_val,
            render = FALSE,  # We'll render separately
            code_fold = input$code_fold,
            number_sections = input$number_sections,
            show_source_lines = input$show_source_lines,
            lang = rv$lang,
            use_styler = if (!is.null(input$use_styler)) input$use_styler else FALSE,
            use_lintr = if (!is.null(input$use_lintr)) input$use_lintr else FALSE,
            apply_styler = if (!is.null(input$apply_styler)) input$apply_styler else FALSE
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
            sprintf("\u2714 %d fichiers generes avec succes ! Consultez la section de telechargement ci-dessous.", 
                   length(rv$qmd_files))
          }
        } else {
          if (rv$lang == "en") "\u2714 Files generated successfully! Check the download section below." 
          else "\u2714 Fichiers generes avec succes ! Consultez la section de telechargement ci-dessous."
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
              sprintf("\u2714 %d Fichiers Pr\u00EAts \u00E0 Telecharger", length(rv$qmd_files))
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
          shiny::h4(if (rv$lang == "en") "\u2714 Files Ready for Download" else "\u2714 Fichiers Pr\u00EAts \u00E0 Telecharger"),
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
