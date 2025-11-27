# Getting Started with quartify

🇫🇷 **[Version française
disponible](https://ddotta.github.io/quartify/articles/getting-started_FR.md)**
/ **French version available**

## Introduction

`quartify` is an R package that automatically converts R scripts into
Quarto markdown documents (.qmd). The package recognizes RStudio code
sections to create properly structured documents with navigation. This
vignette will guide you through the basic usage and features of the
package.

## Installation

You can install the development version of quartify from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("ddotta/quartify")
```

## Basic Usage

The main function of the package is
[`rtoqmd()`](https://ddotta.github.io/quartify/reference/rtoqmd.md).
Here’s a simple example:

``` r
library(quartify)

# Convert an R script to a Quarto document and render to HTML
rtoqmd("my_script.R", "my_document.qmd")

# Convert only, without rendering to HTML
rtoqmd("my_script.R", "my_document.qmd", render = FALSE)
```

By default,
[`rtoqmd()`](https://ddotta.github.io/quartify/reference/rtoqmd.md)
will: 1. Create the .qmd file 2. Render it to HTML using Quarto 3. Open
the HTML file in your default browser

## Structuring Your R Script

For optimal conversion, you need to follow specific commenting rules in
your R script. `quartify` recognizes three types of lines:

### 1. Code Sections (Headers)

Use RStudio code section syntax to create headers at different levels.
These sections MUST follow this exact pattern:

- **Level 2**: `## Title ####` (at least 4 `#` symbols at the end)
- **Level 3**: `### Title ====` (at least 4 `=` symbols at the end)
- **Level 4**: `#### Title ----` (at least 4 `-` symbols at the end)

**Important rules:**

- There must be at least one space between the title text and the
  trailing symbols
- The trailing symbols (`####`, `====`, `----`) must be at least 4
  characters long
- This follows the [RStudio code sections
  convention](https://docs.posit.co/ide/user/ide/guide/code/code-sections.html)

**Example:**

``` r
## Data Loading ####

### Import CSV ====

#### Check Missing Values ----
```

### 2. Regular Comments (Text)

Single `#` comments become explanatory text in the Quarto document:

``` r
# This is a regular comment
# It will appear as plain text in the output
# Use these to explain what your code does
```

**Rules:**

- Start with a single `#` followed by a space
- Multiple consecutive comment lines will each become a separate
  paragraph
- Empty comment lines are ignored

### 3. Code Lines

Any line that is NOT a comment becomes executable R code:

``` r
library(dplyr)

iris |> 
  filter(Species == "setosa") |>
  summarize(mean_length = mean(Sepal.Length))
```

**Rules:**

- Consecutive code lines are grouped into a single code chunk
- Empty lines between code blocks are ignored
- Code blocks are separated by comments or section headers

**Important:** You can include comments WITHIN code blocks. These
comments will be preserved inside the R code chunk:

``` r
iris %>% 
  # Select a column
  select(Species)
```

This will render as:

```` markdown
```{.r}
iris %>% 
  # Select a column
  select(Species)
```
````

The difference: - **Comments at the start of a line** (standalone) →
become text OUTSIDE code blocks - **Comments within code** (indented or
part of a pipeline) → stay INSIDE code blocks

## Complete Example: example.R

Here’s the complete example R script included in the package:

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

This script demonstrates:

1.  **Code without section**:
    [`library(dplyr)`](https://dplyr.tidyverse.org) becomes a code chunk
2.  **Section headers**: `## Title 2 ####`, `### Title 3 ====`,
    `#### Title 4 ----`
3.  **Standalone comments**: `# Select column Species` becomes readable
    text
4.  **Inline comments**: `# Select a column` stays inside the code block
5.  **Code blocks**: Separated by standalone comments or sections

## Customization Options

You can customize the output document with several parameters:

``` r
rtoqmd(
  input_file = "my_script.R",
  output_file = "my_document.qmd",
  title = "My Analysis Report",
  author = "Your Name",
  format = "html"
)
```

### Parameters

- `input_file`: Path to your R script
- `output_file`: Path for the output Quarto document (optional)
- `title`: Title for the document (default: “My title”)
- `author`: Author name (default: “Damien Dotta”)
- `format`: Output format (default: “html”)
- `render`: Whether to render the .qmd to HTML (default: TRUE)
- `open_html`: Whether to open the HTML in browser (default: TRUE)

## Converting the Example

To convert the example script above:

``` r
# Get the example file path
example_file <- system.file("examples", "example.R", package = "quartify")

# Convert it
rtoqmd(
  input_file = example_file,
  output_file = "iris_analysis.qmd",
  title = "Iris Dataset Analysis",
  author = "Data Analyst"
)
```

### Generated Output

This produces the following Quarto document:

``` markdown
---
title: "Iris Dataset Analysis"
author: "Data Analyst"
format: html
toc: true
toc-title: Sommaire
toc-depth: 4  
toc-location: left
output: 
  html_document:
  number_sections: TRUE
  output-file: iris_analysis.html
---

```{.r}
library(dplyr)
```

## Title 2

### Title 3

Start of statistical processing

Counting the number of observations by species

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

    Notice how:

    - Each code section becomes a proper markdown header
    - Standalone comments become readable text paragraphs
    - Inline comments (within code) are preserved in code blocks
    - Code blocks are properly formatted with syntax highlighting
    - The table of contents will show the hierarchical structure

    **Important note about code chunks:** The generated code chunks use the `{.r}` syntax, which creates **non-executable** code blocks. This is intentional - `quartify` is designed to create **static documentation** of your R script, not an executable notebook. The code is displayed with syntax highlighting for reading and documentation purposes, but won't be executed when rendering the Quarto document. This approach is ideal for:

    - Documenting existing scripts without modifying their execution
    - Creating static references of your code
    - Sharing code examples that readers can copy and run in their own environment
    - Ensuring the documentation process doesn't interfere with your original script's behavior

    ## Rendering the Output

    ### Automatic Rendering (Recommended)

    By default, `rtoqmd()` automatically renders your Quarto document to HTML:


    ``` r
    # This will create both .qmd and .html files, then open the HTML
    rtoqmd(example_file, "iris_analysis.qmd")

The function will: 1. Check if Quarto is installed 2. Render the .qmd
file to HTML 3. Open the HTML file in your default browser

If you don’t want automatic rendering:

``` r
rtoqmd(example_file, "iris_analysis.qmd", render = FALSE)
```

### Manual Rendering

You can also render manually using Quarto:

``` bash
quarto render iris_analysis.qmd
```

Or from R:

``` r
quarto::quarto_render("iris_analysis.qmd")
```

**Note:** Quarto must be installed on your system. Download it from
[quarto.org](https://quarto.org/docs/get-started/).

## Use Cases

`quartify` is particularly useful for:

1.  **Documentation**: Transform working scripts into professional
    documentation
2.  **Sharing analyses**: Create readable reports from existing code
3.  **Reproducible research**: Combine code and narrative seamlessly
4.  **Code review**: Present code in a more accessible format

## Comment Rules Summary

| Type                   | Syntax            | Result                | Example                   |
|------------------------|-------------------|-----------------------|---------------------------|
| **Level 2 Header**     | `## Title ####`   | Markdown `## Title`   | `## Data Analysis ####`   |
| **Level 3 Header**     | `### Title ====`  | Markdown `### Title`  | `### Preprocessing ====`  |
| **Level 4 Header**     | `#### Title ----` | Markdown `#### Title` | `#### Remove NA ----`     |
| **Standalone Comment** | `# Text`          | Plain text paragraph  | `# This filters the data` |
| **Code**               | No `#` prefix     | R code chunk          | `iris %>% filter(...)`    |
| **Inline Comment**     | `# Text` in code  | Stays in code chunk   | `iris %>% # comment`      |

**Critical rules to avoid errors:**

1.  **Spacing**: Always include a space after `#` for comments and
    section headers
2.  **Trailing symbols**: Section headers MUST have at least 4 trailing
    symbols (`####`, `====`, or `----`)
3.  **No mixing**: Don’t mix section syntax (e.g., don’t use
    `## Title ====`)
4.  **Roxygen comments**: Lines starting with `#'` are ignored (for
    package development)
5.  **Comment context**: Comments at the start of a line become text;
    comments within code stay in code blocks

## Tips and Best Practices

1.  **Start with structure**: Define your section headers first to
    create the document outline
2.  **Use consistent levels**: Follow a logical hierarchy (2 → 3 → 4,
    don’t skip levels)
3.  **Add explanatory text**: Use regular comments to explain what your
    code does
4.  **Group related code**: Keep related operations together; they’ll be
    grouped into the same code block
5.  **Test incrementally**: Start with a small script to see how the
    conversion works
6.  **Navigate easily**: In RStudio, use the document outline
    (Ctrl+Shift+O) to see your structure
7.  **Comment liberally**: More comments = better documentation in the
    final Quarto document

## Conclusion

`quartify` makes it easy to transform your R scripts into professional
Quarto documents without manual reformatting. By following RStudio code
section conventions, you can automatically generate well-structured,
reproducible documentation from your existing code with proper
navigation hierarchy.
