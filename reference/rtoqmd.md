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

  Title for the Quarto document (default: "My title")

- author:

  Author name (default: "Your name")

- format:

  Output format (default: "html")

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

## Examples

``` r
if (FALSE) { # \dontrun{
# Use example file included in package
example_file <- system.file("examples", "example.R", package = "quartify")

# Convert and render to HTML
rtoqmd(example_file, "output.qmd")

# Convert only, without rendering
rtoqmd(example_file, "output.qmd", render = FALSE)
} # }
```
