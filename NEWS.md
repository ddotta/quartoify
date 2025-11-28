# quartify 0.0.1

## Initial Release

* First public release of quartify package

## Features

* **Automatic R to Quarto Conversion**: Convert R scripts (.R) to Quarto markdown documents (.qmd) with proper formatting
* **RStudio Code Sections Support**: Recognizes RStudio code section syntax (`####`, `====`, `----`) and converts them to hierarchical markdown headers with correct indentation levels (levels 2, 3, and 4)
* **Metadata Extraction**: Automatically extracts metadata from special comments in R scripts:
  - `# Title :` or `# Titre :` for document title
  - `# Author :` or `# Auteur :` for author name
  - `# Date :` for document date
  - `# Description :` for document description
  - Metadata found in scripts overrides function parameters
* **Bilingual RStudio Add-in**: Interactive Shiny interface with English/French language support for easy conversion through RStudio's Addins menu
* **Comment Preservation**: Regular comments are converted to explanatory text, while inline comments within code blocks are preserved
* **Markdown Table Support**: Proper rendering of markdown tables in comments when lines are isolated with empty comment lines
* **Customizable Output**: 
  - Choose between HTML and PDF output formats
  - Control section numbering
  - Enable/disable code folding (HTML only)
  - Automatic HTML rendering and opening in browser
* **RStudio Snippet**: Included snippet for quick metadata header insertion in R scripts
* **Comprehensive Documentation**: 
  - Bilingual vignettes (English/French)
  - Detailed README with examples
  - Complete function documentation

## Technical Details

* Generated Quarto documents include proper YAML headers with table of contents configuration
* Code chunks are non-executable by default (static documentation mode)
* HTML output uses `embed-resources: true` for self-contained files
* Roxygen comments (`#'`) are automatically ignored during conversion
