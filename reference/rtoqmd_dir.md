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
  render = FALSE,
  open_html = FALSE,
  code_fold = FALSE,
  number_sections = TRUE,
  recursive = TRUE,
  pattern = "\\.R$",
  exclude_pattern = NULL
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

- render:

  Logical, whether to render the .qmd files after creation (default:
  FALSE)

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

## Examples

``` r
if (FALSE) { # \dontrun{
# Convert all R scripts in a directory
rtoqmd_dir("path/to/scripts")

# Convert and render all scripts
rtoqmd_dir("path/to/scripts", render = TRUE)

# Convert with custom author and title prefix
rtoqmd_dir("path/to/scripts", 
           title_prefix = "Analysis: ",
           author = "Data Team")

# Exclude certain files (e.g., test files)
rtoqmd_dir("path/to/scripts", 
           exclude_pattern = "test_.*\\.R$")

# Non-recursive (only current directory)
rtoqmd_dir("path/to/scripts", recursive = FALSE)
} # }
```
