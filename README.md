<!-- badges: start -->
[![R check
status](https://github.com/ddotta/quartify/workflows/R-CMD-check/badge.svg)](https://github.com/ddotta/quartify/actions/workflows/check-release.yaml)
[![CodeFactor](https://www.codefactor.io/repository/github/ddotta/quartify/badge)](https://www.codefactor.io/repository/github/ddotta/quartify)
<!-- badges: end -->

# :package: `quartify` <img src="man/figures/hex_quartify.png" width=90 align="right"/>

🇫🇷 [Version française](https://ddotta.github.io/quartify/README_FR.html)

## Description

`quartify` is an R package that automatically converts R scripts into Quarto markdown documents (.qmd).

The package facilitates the transformation of your R analyses into reproducible and well-structured Quarto documents, preserving the logical structure of your code through [RStudio code sections](https://docs.posit.co/ide/user/ide/guide/code/code-sections.html). It recognizes the standard RStudio code section syntax (`####`, `====`, `----`) to create properly indented navigation structures.

### Use Cases

If you have a working R script that contains comments, you may want to generate a Quarto document from this script that will allow you to automatically produce displayable HTML documentation. This is particularly useful for:

- **Documentation**: Automatically generate documentation from your commented code
- **Code review**: Present your code in a more readable format for stakeholders who prefer formatted documents over raw scripts

## Features

- **Automatic conversion**: Transforms your R scripts (.R) into Quarto documents (.qmd)
- **RStudio code sections support**: Recognizes RStudio code sections (`####`, `====`, `----`) and converts them to proper markdown headers with correct indentation levels
- **Comment preservation**: Regular comments are converted into explanatory text
- **Code organization**: R code is automatically organized into executable blocks
- **Customizable YAML header**: Ability to define title, author, and other parameters  
- **Table of contents**: Automatic generation of a table of contents in the Quarto document with proper depth
- **Automatic HTML rendering**: Optionally renders the .qmd file to HTML and opens it in your browser (disabled by default)

## Installation

You can install the development version of quartify from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("ddotta/quartify")
```

## Usage

### RStudio Add-in

The easiest way to use `quartify` is through the RStudio add-in with its interactive Shiny interface:

1. Open your R script in RStudio
2. Go to **Addins** menu → **Convert R Script to Quarto**
3. A dialog window will appear with:
   - **EN/FR** language selector buttons at the top right
   - Form fields to specify:
     - Output file path
     - Document title and author name
     - Rendering options
4. Click **GO** to convert your script (or ↩ to cancel)

The interface adapts to your language choice, displaying all labels in English or French.
The output format is always HTML.

### Basic example

```r
library(quartify)

# Convert an R script to a Quarto document and render to HTML
rtoqmd("my_script.R", "my_document.qmd")

# Convert only, without rendering to HTML
rtoqmd("my_script.R", "my_document.qmd", render = FALSE)
```

### Customization

```r
# With title and author customization
rtoqmd("my_script.R", 
       output_file = "my_document.qmd",
       title = "My statistical analysis",
       author = "Your name",
       format = "html",
       render = TRUE,      # Render to HTML 
       open_html = TRUE)   # Open HTML in browser
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
  # Select a column
  select(Species)
```

### Commenting Rules

`quartify` recognizes three types of lines in your R script:

#### 1. Code Sections (Headers)

RStudio code sections become markdown headers. **Critical**: trailing symbols must be at least 4 characters long:

- `## Title ----` → Level 2 header (at least 4 `#`, `=` or `-` at the end)
- `### Title ----` → Level 3 header (at least 4 `#`, `=` or `-` at the end)
- `#### Title ----` → Level 4 header (at least 4 `#`, `=` or `-` at the end)

**Note:** You can use `#`, `=`, or `-` interchangeably as trailing symbols (e.g., `## Title ====` or `### Title ----` will work).

#### 2. Regular Comments (Text)

Single `#` comments **at the start of a line** become explanatory text:

```r
# This is a standalone comment
# It becomes plain text in the Quarto document
```

**Tip:** Use RStudio's [Comment/Uncomment shortcut](https://docs.posit.co/ide/user/ide/guide/productivity/text-editor.html#commentuncomment) (`Ctrl+Shift+C` on Windows/Linux or `Cmd+Shift+C` on Mac) to quickly add or remove comments.

#### 3. Code Lines

Uncommented lines become executable R code chunks:

```r
iris |> filter(Species == "setosa")
```

#### 4. Inline Comments (Within Code)

Comments **within code blocks** are preserved inside the R code chunk:

```r
iris %>% 
  # This comment stays in the code block
  select(Species)
```

**Important rules:**

- Always include a space after `#` for comments
- Section headers MUST have at least 4 trailing symbols
- **Standalone comments with `#` at line start** → become text outside code blocks
- **Inline comments within code** → stay inside code blocks
- Consecutive code lines are grouped in the same block
- Empty lines between blocks are ignored

This follows the [RStudio code sections convention](https://docs.posit.co/ide/user/ide/guide/code/code-sections.html) which provides proper indentation in RStudio's document outline navigation.

## Output and Documentation

The generated .qmd document contains:  
- A complete YAML header with table of contents configuration  
- Properly structured headers from RStudio code sections  
- Textual explanations from your comments  
- **Non-executable code chunks** for static documentation  

📝 **For a complete example of the generated output**, see the [Getting Started vignette](https://ddotta.github.io/quartify/articles/getting-started.html#generated-output)

## License

MIT