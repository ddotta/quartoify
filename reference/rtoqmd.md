# Convert R Script to Quarto Markdown

This function converts an R script to Quarto markdown format. It
recognizes RStudio code sections with different levels: - \## Title
\#### creates a level 2 header - \### Title ==== creates a level 3
header - \#### Title —- creates a level 4 header Regular comments are
converted to plain text. Code blocks are wrapped in standard R code
chunks. The YAML header includes `execute: eval: false` and
`execute: echo: true` options for static documentation purposes, and
`embed-resources: true` to create self-contained HTML files. See
<https://quarto.org/docs/output-formats/html-basics.html#self-contained>.

## Usage

``` r
rtoqmd(
  input_file,
  output_file = NULL,
  title = "My title",
  author = "Your name",
  format = "html",
  theme = NULL,
  render = TRUE,
  open_html = FALSE,
  code_fold = FALSE,
  number_sections = TRUE
)
```

## Arguments

- input_file:

  Path to the input R script file

- output_file:

  Path to the output Quarto markdown file (optional, defaults to same
  name with .qmd extension)

- title:

  Title for the Quarto document (default: "My title"). Can be overridden
  by `# Title :` or `# Titre :` in the script

- author:

  Author name (default: "Your name"). Can be overridden by `# Author :`
  or `# Auteur :` in the script

- format:

  Output format - always "html" (parameter kept for backward
  compatibility)

- theme:

  Quarto theme for HTML output (default: NULL uses Quarto's default).
  See <https://quarto.org/docs/output-formats/html-themes.html> for
  available themes (e.g., "cosmo", "flatly", "darkly", "solar",
  "united")

- render:

  Logical, whether to render the .qmd file to HTML after creation
  (default: TRUE)

- open_html:

  Logical, whether to open the HTML file in browser after rendering
  (default: FALSE, only used if render = TRUE)

- code_fold:

  Logical, whether to fold code blocks in HTML output (default: FALSE)

- number_sections:

  Logical, whether to number sections automatically in the output
  (default: TRUE)

## Value

Invisibly returns NULL. Creates a .qmd file and optionally renders it to
HTML.

## Metadata Detection

The function automatically extracts metadata from special comment lines
in your R script:

- **Title**: Use `# Title : Your Title` or `# Titre : Votre Titre`

- **Author**: Use `# Author : Your Name` or `# Auteur : Votre Nom`

- **Date**: Use `# Date : YYYY-MM-DD`

- **Description**: Use `# Description : Your description` (also accepts
  `# Purpose` or `# Objectif`)

If metadata is found in the script, it will override the corresponding
function parameters. These metadata lines are removed from the document
body and only appear in the YAML header.

The Description field supports multi-line content. Continuation lines
should start with `#` followed by spaces and the text. The description
ends at an empty line or a line without `#`.

## Callouts

The function converts special comment patterns into Quarto callouts.
Callouts are special blocks that highlight important information.
Supported callout types: `note`, `tip`, `warning`, `caution`,
`important`.

Syntax:

- **With title**: `# callout-tip - Your Title`

- **Without title**: `# callout-tip`

All subsequent comment lines become the callout content until an empty
line or code is encountered.

Example in R script:

    # callout-note - Important Note
    # This is the content of the note.
    # It can span multiple lines.

    x <- 1

Becomes in Quarto:

    ::: {.callout-note title="Important Note"}
    This is the content of the note.
    It can span multiple lines.
    :::

## Examples

``` r
if (FALSE) { # \dontrun{
# Use example file included in package
example_file <- system.file("examples", "example.R", package = "quartify")

# Convert and render to HTML
rtoqmd(example_file, "output.qmd")

# Convert only, without rendering
rtoqmd(example_file, "output.qmd", render = FALSE)

# Example with metadata in the R script:
# Create a script with metadata
script_with_metadata <- tempfile(fileext = ".R")
writeLines(c(
  "# Title : My Analysis",
  "# Author : Jane Doe", 
  "# Date : 2025-11-28",
  "# Description : Analyze iris dataset",
  "",
  "library(dplyr)",
  "iris %>% head()"
), script_with_metadata)

# Convert - metadata will override function parameters
rtoqmd(script_with_metadata, "output_with_metadata.qmd")
} # }
```
