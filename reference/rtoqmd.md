# Convert R Script to Quarto Markdown

This function converts an R script to Quarto markdown format. Comments
starting with \# \## to \# \###### are converted to markdown headers
(levels 2 to 6). Regular comments are converted to plain text. Code
blocks are wrapped in code chunks.

## Usage

``` r
rtoqmd(input_file, output_file = NULL, title = "My title", 
       author = "Damien Dotta", format = "html")
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

  Author name (default: "Damien Dotta")

- format:

  Output format (default: "html")

## Value

NULL (creates output file)

## Examples

``` r
if (FALSE) { # \dontrun{
# Use example file included in package
example_file <- system.file("examples", "example.R", package = "quartify")
rtoqmd(example_file, "output.qmd")
} # }
```
