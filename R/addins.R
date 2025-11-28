#' Convert Active R Script to Quarto Markdown
#'
#' RStudio add-in that converts the currently active R script in the editor
#' to a Quarto markdown document. Uses a Shiny interface for parameter input.
#'
#' @importFrom shiny runGadget stopApp observeEvent reactive req textInput checkboxInput actionButton renderText reactiveVal tags
#' @importFrom miniUI miniPage gadgetTitleBar miniContentPanel miniTitleBarButton miniTitleBarCancelButton
#' @importFrom base64enc base64encode
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
      right = miniUI::miniTitleBarButton("done", shiny::HTML("<span style='font-size: 16px; font-weight: bold;'>GO \u25b6</span>"), primary = TRUE)
    ),
    shiny::div(id = "loader", class = "loader", shiny::div(class = "spinner")),
    miniUI::miniContentPanel(
      shiny::fillCol(
        flex = c(NA, 1),
        shiny::fillRow(
          shiny::div(
            style = "padding: 20px; overflow-y: auto;",
            # Language selector
            shiny::div(
              style = "text-align: right; margin-bottom: 10px;",
              shiny::actionButton(
                "lang_en",
                english_flag_html,
                style = "margin-right: 5px; padding: 5px 10px; font-size: 12px;",
                class = "btn-sm"
              ),
              shiny::actionButton(
                "lang_fr",
                french_flag_html,
                style = "padding: 5px 10px; font-size: 12px;",
                class = "btn-sm"
              )
            ),
            # Logo centered
            shiny::div(
              style = "text-align: center; margin-bottom: 20px;",
              logo_html
            ),
            shiny::h4(shiny::textOutput("label_input_file")),
            shiny::p(basename(input_path), style = "font-family: monospace; color: #666;"),
            shiny::hr(),
            shiny::textInput(
              "output_file",
              shiny::textOutput("label_output_file"),
              value = output_path,
              width = "100%"
            ),
            shiny::textInput(
              "title",
              shiny::textOutput("label_title"),
              value = "My Analysis",
              width = "100%"
            ),
            shiny::textInput(
              "author",
              shiny::textOutput("label_author"),
              value = ifelse(Sys.getenv("USER") != "", Sys.getenv("USER"), "Your name"),
              width = "100%"
            ),
            shiny::div(
              style = "width: 100%;",
              shiny::checkboxInput(
                "render",
                shiny::textOutput("label_render"),
                value = TRUE,
                width = "100%"
              )
            ),
            shiny::div(
              style = "width: 100%;",
              shiny::checkboxInput(
                "open_qmd",
                shiny::textOutput("label_open_qmd"),
                value = TRUE,
                width = "100%"
              )
            ),
            shiny::div(
              style = "width: 100%;",
              shiny::checkboxInput(
                "open_html",
                shiny::textOutput("label_open_html"),
                value = FALSE,
                width = "100%"
              )
            ),
            shiny::div(
              style = "width: 100%;",
              shiny::checkboxInput(
                "code_fold",
                shiny::textOutput("label_code_fold"),
                value = FALSE,
                width = "100%"
              )
            ),
            shiny::div(
              style = "width: 100%;",
              shiny::checkboxInput(
                "number_sections",
                shiny::textOutput("label_number_sections"),
                value = TRUE,
                width = "100%"
              )
            )
          )
        )
      )
    )
  )
  
  # Define server logic
  server <- function(input, output, session) {
    
    # Reactive language
    lang <- shiny::reactiveVal("en")
    
    # Language switchers
    shiny::observeEvent(input$lang_en, {
      lang("en")
    })
    
    shiny::observeEvent(input$lang_fr, {
      lang("fr")
    })
    
    # Translations
    translations <- list(
      en = list(
        input_file = "Input file:",
        output_file = "Output file path:",
        title = "Document title:",
        author = "Author name:",
        render = "Render to HTML after conversion",
        open_html = "Open HTML file in browser (if rendered)",
        open_qmd = "Open .qmd file in editor after conversion",
        code_fold = "Fold code blocks by default",
        number_sections = "Number sections automatically"
      ),
      fr = list(
        input_file = "Fichier d'entr\u00e9e :",
        output_file = "Chemin du fichier de sortie :",
        title = "Titre du document :",
        author = "Nom de l'auteur :",
        render = "G\u00e9n\u00e9rer le HTML apr\u00e8s conversion",
        open_html = "Ouvrir le fichier HTML dans le navigateur (si g\u00e9n\u00e9r\u00e9)",
        open_qmd = "Ouvrir le fichier .qmd dans l'\u00e9diteur apr\u00e8s conversion",
        code_fold = "Replier les blocs de code par d\u00e9faut",
        number_sections = "Num\u00e9roter les sections automatiquement"
      )
    )
    
    # Dynamic labels
    output$label_input_file <- shiny::renderText({ translations[[lang()]]$input_file })
    output$label_output_file <- shiny::renderText({ translations[[lang()]]$output_file })
    output$label_title <- shiny::renderText({ translations[[lang()]]$title })
    output$label_author <- shiny::renderText({ translations[[lang()]]$author })
    output$label_render <- shiny::renderText({ translations[[lang()]]$render })
    output$label_open_html <- shiny::renderText({ translations[[lang()]]$open_html })
    output$label_open_qmd <- shiny::renderText({ translations[[lang()]]$open_qmd })
    output$label_code_fold <- shiny::renderText({ translations[[lang()]]$code_fold })
    output$label_number_sections <- shiny::renderText({ translations[[lang()]]$number_sections })
    
    # When done button is pressed
    shiny::observeEvent(input$done, {
      
      # Show loader
      session$sendCustomMessage('toggleLoader', TRUE)
      
      # Get values
      output_file <- shiny::req(input$output_file)
      title <- shiny::req(input$title)
      author <- shiny::req(input$author)
      render <- input$render
      open_html <- input$open_html
      open_qmd <- input$open_qmd
      code_fold <- input$code_fold
      number_sections <- input$number_sections
      
      # Convert the file
      tryCatch({
        rtoqmd(
          input_file = input_path,
          output_file = output_file,
          title = title,
          author = author,
          format = "html",
          render = render,
          open_html = open_html && render,
          code_fold = code_fold,
          number_sections = number_sections
        )
        
        # Open QMD file if requested
        if (open_qmd && file.exists(output_file)) {
          rstudioapi::navigateToFile(output_file)
        }
        
        # Stop the app
        shiny::stopApp()
        
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
  }
  
  # Run the gadget
  viewer <- shiny::dialogViewer("Convert to Quarto", width = 700, height = 800)
  shiny::runGadget(ui, server, viewer = viewer)
  
  invisible()
}
