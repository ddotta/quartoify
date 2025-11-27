# 📦 `quartify` ![](reference/figures/hex_quartify.png)

[Version française](https://ddotta.github.io/quartify/README_FR.md)

## Description

`quartify` is an R package that automatically converts R scripts into
Quarto markdown documents (.qmd).

The package facilitates the transformation of your R analyses into
reproducible and well-structured Quarto documents, preserving the
logical structure of your code through RStudio code sections. It
recognizes the standard RStudio code section syntax (`####`, `====`,
`----`) to create properly indented navigation structures.

### Typical Use Case

If you have a working R script that contains comments, you may want to
generate a Quarto document from this script that will allow you to
automatically produce displayable HTML documentation. This is
particularly useful for:

- **Sharing analyses**: Transform your working scripts into
  professional-looking reports without rewriting everything
- **Documentation**: Automatically generate documentation from your
  commented code
- **Reproducible research**: Create self-documenting analyses where code
  and explanations are seamlessly integrated
- **Code review**: Present your code in a more readable format for
  stakeholders who prefer formatted documents over raw scripts

## Features

- **Automatic conversion**: Transforms your R scripts (.R) into Quarto
  documents (.qmd)
- **RStudio code sections support**: Recognizes RStudio code sections
  (`####`, `====`, `----`) and converts them to proper markdown headers
  with correct indentation levels
- **Comment preservation**: Regular comments are converted into
  explanatory text
- **Code organization**: R code is automatically organized into
  executable blocks
- **Customizable YAML header**: Ability to define title, author, and
  output format
- **Table of contents**: Automatic generation of a table of contents in
  the Quarto document with proper depth

## Installation

You can install the development version of quartify from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("ddotta/quartify")
```

## Usage

### RStudio Add-in (Recommended)

The easiest way to use `quartify` is through the RStudio add-in:

1.  Open your R script in RStudio
2.  Go to **Addins** menu → **Convert R Script to Quarto**
3.  Follow the prompts to specify output file, title, and author
4.  The Quarto document will be created and optionally opened

### Basic example

``` r
library(quartify)

# Convert an R script to a Quarto document
rtoqmd("my_script.R", "my_document.qmd")
```

### Customization

``` r
# With title and author customization
rtoqmd("my_script.R", 
       output_file = "my_document.qmd",
       title = "My statistical analysis",
       author = "Your name",
       format = "html")
```

### Using the example file

An example file is included in the package to test the function:

``` r
# Locate the example file
example_file <- system.file("examples", "example.R", package = "quartify")

# Convert the example file
rtoqmd(example_file, "test_output.qmd")
```

## Source R script format

For the conversion to work properly, structure your R script using
RStudio code sections:

``` r
library(dplyr)

## Title 2 ####

### Title 3 ====

# Start of statistical processing
# Counting the number of observations by species

iris |> 
  count(Species)

### Title 3 ====

# Filter the data.frame on Species "setosa"

iris |> 
  filter(Species == "setosa")

#### Title 4 ----

# Select column Species

iris %>% 
  # Select a column
  select(Species)
```

### Commenting Rules

`quartify` recognizes three types of lines in your R script:

#### 1. Code Sections (Headers)

RStudio code sections become markdown headers. **Critical**: trailing
symbols must be at least 4 characters long:

- `## Title ####` → Level 2 header (at least 4 `#` at the end)
- `### Title ====` → Level 3 header (at least 4 `=` at the end)
- `#### Title ----` → Level 4 header (at least 4 `-` at the end)

#### 2. Regular Comments (Text)

Single `#` comments **at the start of a line** become explanatory text:

``` r
# This is a standalone comment
# It becomes plain text in the Quarto document
```

#### 3. Code Lines

Uncommented lines become executable R code chunks:

``` r
iris |> filter(Species == "setosa")
```

#### 4. Inline Comments (Within Code)

Comments **within code blocks** are preserved inside the R code chunk:

``` r
iris %>% 
  # This comment stays in the code block
  select(Species)
```

**Important rules:**

- Always include a space after `#` for comments
- Section headers MUST have at least 4 trailing symbols
- **Standalone comments** (at line start) → become text outside code
  blocks
- **Inline comments** (within code) → stay inside code blocks
- Consecutive code lines are grouped in the same block
- Empty lines between blocks are ignored

This follows the [RStudio code sections
convention](https://docs.posit.co/ide/user/ide/guide/code/code-sections.html)
which provides proper indentation in RStudio’s document outline
navigation.

## Generated Quarto document structure

The generated .qmd document contains:

- A complete YAML header with table of contents configuration
- Properly structured headers from RStudio code sections
- Textual explanations from your regular comments
- Formatted and executable R code blocks

## Output example

From the example R script shown above, `quartify` generates:

``` markdown
---
title: "My title"
author: "Damien Dotta"
format: html
toc: true
toc-title: Sommaire
toc-depth: 4  
toc-location: left
output: 
  html_document:
  number_sections: TRUE
  output-file: example.html
---

```{.r}
library(dplyr)
```

## Title 2

### Title 3

Start of statistical processing Counting the number of observations by
species

``` r
iris |> 
  count(Species)
```

### Title 3

Filter the data.frame on Species “setosa”

``` r
iris |> 
  filter(Species == "setosa")
```

#### Title 4

Select column Species

``` r
iris %>% 
  # Select a column
  select(Species)
```

\`\`\`

The generated document includes: - Navigable table of contents with
proper hierarchy - Code organized into reusable blocks - Inline comments
preserved within code blocks - Clear documentation between code
sections - **Non-executable code chunks** (`{.r}` syntax) for static
documentation - Ready for HTML, PDF, or other formats supported by
Quarto

**Note:** Code chunks are intentionally non-executable to provide static
documentation of your R script without executing the code during
rendering.

## License

MIT
