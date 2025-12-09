# Convert All R Scripts in a Directory to Quarto Markdown

This function recursively searches for all R script files (.R) in a
directory and its subdirectories, and converts each one to a Quarto
markdown document (.qmd). The output files are created in the same
directories as the input files.

## Usage

``` r
rtoqmd_dir(
  dir_path,
  title_prefix = NULL,
  author = "Your name",
  format = "html",
  theme = NULL,
  render_html = FALSE,
  output_html_dir = NULL,
  open_html = TRUE,
  code_fold = FALSE,
  number_sections = TRUE,
  recursive = TRUE,
  pattern = "\\.R$",
  exclude_pattern = NULL,
  create_book = TRUE,
  book_title = "R Scripts Documentation",
  output_dir = NULL,
  language = "en",
  use_styler = FALSE,
  use_lintr = FALSE,
  apply_styler = FALSE
)
```

## Arguments

- dir_path:

  Path to the directory containing R scripts

- title_prefix:

  Optional prefix to add to all document titles (default: NULL)

- author:

  Author name for all documents (default: "Your name")

- format:

  Output format - always "html" (parameter kept for backward
  compatibility)

- theme:

  Quarto theme for HTML output (default: NULL uses Quarto's default).
  See <https://quarto.org/docs/output-formats/html-themes.html>

- render_html:

  Logical, whether to render the .qmd files to HTML after creation
  (default: FALSE)

- output_html_dir:

  Directory path for HTML output files (optional, defaults to same
  directory as .qmd files)

- open_html:

  Logical, whether to open the HTML files in browser after rendering
  (default: FALSE)

- code_fold:

  Logical, whether to fold code blocks in HTML output (default: FALSE)

- number_sections:

  Logical, whether to number sections automatically (default: TRUE)

- recursive:

  Logical, whether to search subdirectories recursively (default: TRUE)

- pattern:

  Regular expression pattern to filter R files (default: "\\R\$")

- exclude_pattern:

  Optional regular expression pattern to exclude certain files (default:
  NULL)

- create_book:

  Logical, whether to create a Quarto book structure with \_quarto.yml
  (default: TRUE)

- book_title:

  Title for the Quarto book (default: "R Scripts Documentation")

- output_dir:

  Output directory for the book (required if create_book=TRUE, default:
  NULL uses input_dir/output)

- language:

  Language for the documentation ("en" or "fr", default: "en")

- use_styler:

  Logical, whether to apply styler code formatting and show differences
  in tabsets (default: FALSE). Requires the styler package to be
  installed.

- use_lintr:

  Logical, whether to run lintr code quality checks and display issues
  in tabsets (default: FALSE). Requires the lintr package to be
  installed.

- apply_styler:

  Logical, whether to apply styler formatting directly to the source R
  script files (default: FALSE). If TRUE, all input files will be
  modified with styled code. Requires use_styler = TRUE to take effect.

## Value

Invisibly returns a data frame with conversion results (file paths and
status)

## Details

Supports all features of
[`rtoqmd`](https://ddotta.github.io/quartify/reference/rtoqmd.md),
including:

- Metadata detection (Title, Author, Date, Description)

- RStudio section headers

- Callouts (note, tip, warning, caution, important)

- Code blocks and comments

See [`rtoqmd`](https://ddotta.github.io/quartify/reference/rtoqmd.md)
for details on callout syntax and metadata detection.

## Note

Existing .qmd and .html files will be automatically overwritten during
generation to ensure fresh output.

## Examples

``` r
# \donttest{
# Convert all R scripts in a directory
rtoqmd_dir("path/to/scripts")
#> ✖ Directory does not exist: path/to/scripts
#> Error: Directory does not exist: path/to/scripts

# Convert and render all scripts
rtoqmd_dir("path/to/scripts", render_html = TRUE)
#> ✖ Directory does not exist: path/to/scripts
#> Error: Directory does not exist: path/to/scripts

# Create a Quarto book with automatic navigation
rtoqmd_dir(
  dir_path = "path/to/scripts",
  output_html_dir = "path/to/scripts/documentation",
  render_html = TRUE,
  author = "Your Name",
  book_title = "My R Scripts Documentation",
  open_html = TRUE
)
#> ✖ Directory does not exist: path/to/scripts
#> Error: Directory does not exist: path/to/scripts

# Create a Quarto book in French
rtoqmd_dir(
  dir_path = "path/to/scripts",
  output_html_dir = "path/to/scripts/documentation",
  render_html = TRUE,
  author = "Votre Nom",
  book_title = "Documentation des Scripts R",
  language = "fr"
)
#> ✖ Directory does not exist: path/to/scripts
#> Error: Directory does not exist: path/to/scripts

# Convert with custom author and title prefix
rtoqmd_dir("path/to/scripts", 
           title_prefix = "Analysis: ",
           author = "Data Team")
#> ✖ Directory does not exist: path/to/scripts
#> Error: Directory does not exist: path/to/scripts

# Exclude certain files (e.g., test files)
rtoqmd_dir("path/to/scripts", 
           exclude_pattern = "test_.*\\.R$")
#> ✖ Directory does not exist: path/to/scripts
#> Error: Directory does not exist: path/to/scripts

# Non-recursive (only current directory)
rtoqmd_dir("path/to/scripts", recursive = FALSE)
#> ✖ Directory does not exist: path/to/scripts
#> Error: Directory does not exist: path/to/scripts

# Reproducible example with sample scripts
example_dir <- system.file("examples", "book_example", package = "quartify")
if (example_dir != "") {
  rtoqmd_dir(
    dir_path = example_dir,
    output_html_dir = file.path(example_dir, "documentation"),
    render_html = TRUE,
    open_html = TRUE
  )
}
#> 
#> ── Converting R Scripts to Quarto Markdown ─────────────────────────────────────
#> ℹ Searching directory: /home/runner/work/_temp/Library/quartify/examples/book_example
#> ℹ Recursive: TRUE
#> ✔ Found 3 R scripts to convert
#> 
#> ── Converting files... ──
#> 
#> ✔ Quarto markdown file created: /home/runner/work/_temp/Library/quartify/examples/book_example/analysis/visualization.qmd
#> ✔ Quarto markdown file created: /home/runner/work/_temp/Library/quartify/examples/book_example/script1.qmd
#> ✔ Quarto markdown file created: /home/runner/work/_temp/Library/quartify/examples/book_example/script2.qmd
#> 
#> ── Conversion Summary ──
#> 
#> ✔ Successfully converted: 3 files
#> 
#> ── Creating Quarto Book ──
#> 
#> ✔ Created: /home/runner/work/_temp/Library/quartify/examples/book_example/index.qmd
#> ✔ Created: /home/runner/work/_temp/Library/quartify/examples/book_example/_quarto.yml
#> ℹ Rendering Quarto book...
#> ✖ Failed to render book: Quarto command-line tools path not found! 
# }
```
