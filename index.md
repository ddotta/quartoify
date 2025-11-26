# 📦 `quartoify` ![](reference/figures/hex_quartoify.png)

## Description

`quartoify` is an R package that automatically converts R scripts into
Quarto markdown documents (.qmd).

The package facilitates the transformation of your R analyses into
reproducible and well-structured Quarto documents, preserving the
logical structure of your code through a special comment system.

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
- **Title management**: Special comments `# ##` to `# ######` become
  level 2 to 6 markdown headers
- **Comment preservation**: Regular comments are converted into
  explanatory text
- **Code organization**: R code is automatically organized into
  executable blocks
- **Customizable YAML header**: Ability to define title, author, and
  output format
- **Table of contents**: Automatic generation of a table of contents in
  the Quarto document

## Installation

You can install the development version of quartoify from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("ddotta/quartoify")
```

## Usage

### Basic example

``` r
library(quartoify)

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
example_file <- system.file("examples", "example.R", package = "quartoify")

# Convert the example file
rtoqmd(example_file, "test_output.qmd")
```

## Source R script format

For the conversion to work properly, structure your R script as follows:

``` r
library(dplyr)

# ## Level 2 title

# ### Level 3 subtitle

# Analysis description
# This section explains what the code does

iris |> 
  count(Species)

# ### Another subtitle

# Data filtering

iris |> 
  filter(Species == "setosa")
```

### Conversion rules

- **Titles**: Comments `# ##` to `# ######` become markdown headers
  (levels 2 to 6)
- **Comments**: Simple comments `#` become explanatory text
- **Code**: Uncommented code is grouped into Quarto code blocks
- **Consecutive blocks**: Consecutive code lines are grouped in the same
  block

## Generated Quarto document structure

The generated .qmd document contains:

- A complete YAML header with table of contents configuration
- Titles and subtitles from your special comments
- Textual explanations from your regular comments
- Formatted and executable R code blocks

## Output example

From the example script, `quartoify` generates a structured Quarto
document with: - Navigable table of contents - Code organized into
reusable blocks - Clear documentation between code sections - Ready for
HTML, PDF, or other formats supported by Quarto

## License

MIT
