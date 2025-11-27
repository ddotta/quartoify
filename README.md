<!-- badges: start -->
![GitHub top
language](https://img.shields.io/github/languages/top/ddotta/quartify)
[![R check
status](https://github.com/ddotta/quartify/workflows/R-CMD-check/badge.svg)](https://github.com/ddotta/quartify/actions/workflows/check-release.yaml)
<!-- badges: end -->

# :package: `quartify` <img src="man/figures/hex_quartify.png" width=90 align="right"/>

## Description

`quartify` is an R package that automatically converts R scripts into Quarto markdown documents (.qmd).

The package facilitates the transformation of your R analyses into reproducible and well-structured Quarto documents, preserving the logical structure of your code through RStudio code sections. It recognizes the standard RStudio code section syntax (`####`, `====`, `----`) to create properly indented navigation structures.

### Typical Use Case

If you have a working R script that contains comments, you may want to generate a Quarto document from this script that will allow you to automatically produce displayable HTML documentation. This is particularly useful for:

- **Sharing analyses**: Transform your working scripts into professional-looking reports without rewriting everything
- **Documentation**: Automatically generate documentation from your commented code
- **Reproducible research**: Create self-documenting analyses where code and explanations are seamlessly integrated
- **Code review**: Present your code in a more readable format for stakeholders who prefer formatted documents over raw scripts

## Features

- **Automatic conversion**: Transforms your R scripts (.R) into Quarto documents (.qmd)
- **RStudio code sections support**: Recognizes RStudio code sections (`####`, `====`, `----`) and converts them to proper markdown headers with correct indentation levels
- **Comment preservation**: Regular comments are converted into explanatory text
- **Code organization**: R code is automatically organized into executable blocks
- **Customizable YAML header**: Ability to define title, author, and output format
- **Table of contents**: Automatic generation of a table of contents in the Quarto document with proper depth

## Installation

You can install the development version of quartify from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("ddotta/quartify")
```

## Usage

### RStudio Add-in (Recommended)

The easiest way to use `quartify` is through the RStudio add-in:

1. Open your R script in RStudio
2. Go to **Addins** menu → **Convert R Script to Quarto**
3. Follow the prompts to specify output file, title, and author
4. The Quarto document will be created and optionally opened

### Basic example

```r
library(quartify)

# Convert an R script to a Quarto document
rtoqmd("my_script.R", "my_document.qmd")
```

### Customization

```r
# With title and author customization
rtoqmd("my_script.R", 
       output_file = "my_document.qmd",
       title = "My statistical analysis",
       author = "Your name",
       format = "html")
```

### Using the example file

An example file is included in the package to test the function:

```r
# Locate the example file
example_file <- system.file("examples", "example.R", package = "quartify")

# Convert the example file
rtoqmd(example_file, "test_output.qmd")
```

## Source R script format

For the conversion to work properly, structure your R script using RStudio code sections:

```r
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
  select(Species)
```

### Conversion rules

- **Code sections**: RStudio code sections become markdown headers
  - `## Title ####` creates a level 2 header
  - `### Title ====` creates a level 3 header  
  - `#### Title ----` creates a level 4 header
- **Comments**: Simple comments `#` become explanatory text
- **Code**: Uncommented code is grouped into Quarto code blocks
- **Consecutive blocks**: Consecutive code lines are grouped in the same block

This follows the [RStudio code sections convention](https://docs.posit.co/ide/user/ide/guide/code/code-sections.html) which provides proper indentation in RStudio's document outline navigation.

## Generated Quarto document structure

The generated .qmd document contains:

- A complete YAML header with table of contents configuration
- Properly structured headers from RStudio code sections
- Textual explanations from your regular comments
- Formatted and executable R code blocks

## Output example

From the example R script shown above, `quartify` generates:

```markdown
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

Start of statistical processing
Counting the number of observations by species

```{.r}
iris |> 
  count(Species)
```

### Title 3

Filter the data.frame on Species "setosa"

```{.r}
iris |> 
  filter(Species == "setosa")
```

#### Title 4

Select column Species

```{.r}
iris %>% 
  select(Species)
```
```

The generated document includes:
- Navigable table of contents with proper hierarchy
- Code organized into reusable blocks
- Clear documentation between code sections
- Ready for HTML, PDF, or other formats supported by Quarto

## License

MIT