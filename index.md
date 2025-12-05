# 📦 `quartify` ![](reference/figures/hex_quartify.png)

🇫🇷 [Version française](https://ddotta.github.io/quartify/README_FR.html)

## Description

`quartify` is an R package that automatically converts R scripts into
Quarto markdown documents (.qmd).

The package facilitates the transformation of your R analyses into
reproducible and well-structured Quarto documents, preserving the
logical structure of your code through [RStudio code
sections](https://docs.posit.co/ide/user/ide/guide/code/code-sections.html).
It recognizes the standard RStudio code section syntax (`####`, `====`,
`----`) to create properly indented navigation structures.

### Why quartify instead of knitr::spin()?

While [`knitr::spin()`](https://yihui.org/knitr/demo/stitch/) converts R
scripts to R Markdown (.Rmd), `quartify` converts them to **Quarto**
(.qmd), giving you access to all modern Quarto features:

- ✅ **Modern Publishing System**: Leverage Quarto’s advanced features
  (callouts, tabsets, etc.)
- ✅ **Better Theming**: Access to 25+ modern HTML themes with
  consistent styling
- ✅ **Enhanced Interactivity**: Native support for Observable JS,
  Shiny, and interactive widgets
- ✅ **Scientific Publishing**: Built-in support for citations,
  bibliographies, and academic formatting
- ✅ **Mermaid Diagrams**: Create flowcharts and diagrams directly in
  your documentation
- ✅ **Future-Proof**: Quarto is the next-generation successor to R
  Markdown, actively developed by Posit
- ✅ **One-Step HTML Generation**: Unlike
  [`knitr::spin()`](https://rdrr.io/pkg/knitr/man/spin.html) which only
  creates .Rmd files (requiring a separate knitting step), `quartify`
  can generate HTML output directly in a single step

**Key Difference**:
[`knitr::spin()`](https://rdrr.io/pkg/knitr/man/spin.html) uses `#'` for
markdown text and `#+` for chunk options, while `quartify` uses natural
R commenting (`#` for text, RStudio sections for headers) making your R
scripts more readable and maintainable even before conversion.

### Use Cases

If you have a working R script that contains comments, you may want to
generate a Quarto document from this script that will allow you to
automatically produce displayable HTML documentation. This is
particularly useful for:

- **Documentation**: Automatically generate documentation from your
  commented code
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
  other parameters  
- **Table of contents**: Automatic generation of a table of contents in
  the Quarto document with proper depth
- **Automatic HTML rendering**: Optionally renders the .qmd file to HTML
  and opens it in your browser (disabled by default)
- **Customizable themes**: Choose from 25+ Quarto themes to customize
  the appearance of your HTML documents
- **Source line numbers**: Optionally display original line numbers from
  the R script in code chunks for traceability
- **Web deployment ready**: Includes
  [`quartify_app_web()`](https://ddotta.github.io/quartify/reference/quartify_app_web.md)
  for deploying on web servers with file upload/download capabilities

## Installation

You can install the development version of quartify from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("ddotta/quartify")
```

## Usage

### 🌐 Try the Online Web Application!

**No installation required!** Use quartify directly in your browser:

### **→ <https://quartify.lab.sspcloud.fr/> ←**

The web version allows you to: - ✅ Upload your R script directly from
your computer - ✅ Configure conversion options (title, author, theme,
etc.) - ✅ Download generated .qmd and .html files - ✅ No R
installation required!

------------------------------------------------------------------------

### Interactive Shiny Interface (for R users)

`quartify` also provides an interactive Shiny interface that works in
any R environment:

#### Option 1: Standalone App (works in most IDEs)

``` r
library(quartify)
quartify_app()  # Opens in your default web browser
```

This launches a browser-based interface where you can: - Select input R
script using a file browser - Choose output file location - Customize
document title, author, and theme - Toggle rendering and display
options - Switch between English/French interface

**Perfect for users of Positron, VS Code, or any IDE that supports R!**

#### Option 2: RStudio Add-in

If you use RStudio, you can also access the same interface through:

1.  Open your R script in RStudio
2.  Go to **Addins** menu → **Convert R Script to Quarto**
3.  A dialog window will appear with the same options as the standalone
    app
4.  Click **GENERATE** to convert your script

The interface automatically detects your R session language preferences
and displays all labels in English or French accordingly. You can change
the language at any time using the EN/FR buttons. The output format is
always HTML.

### Basic example

``` r
library(quartify)

# Convert an R script to a Quarto document and render to HTML
rtoqmd("my_script.R", "my_document.qmd")

# Convert only, without rendering to HTML
rtoqmd("my_script.R", "my_document.qmd", render = FALSE)
```

### Customization

``` r
# With title and author customization
rtoqmd("my_script.R", 
       output_file = "my_document.qmd",
       title = "My statistical analysis",
       author = "Your name",
       format = "html",
       theme = "cosmo",              # Quarto theme (optional)
       render = TRUE,                # Render to HTML 
       output_html_file = "docs/my_analysis.html",  # Custom HTML location
       open_html = TRUE,             # Open HTML in browser
       number_sections = TRUE)       # Number sections automatically
```

### Using the example files

Example files are included in the package to test the function:

``` r
# Locate the basic example file
example_file <- system.file("examples", "example.R", package = "quartify")

# Convert the example file
rtoqmd(example_file, "test_output.qmd")

# Try the Mermaid diagrams example
mermaid_file <- system.file("examples", "example_mermaid.R", package = "quartify")
rtoqmd(mermaid_file, "test_mermaid.qmd", render = TRUE)
```

### Batch conversion

Convert all R scripts in a directory (including subdirectories):

``` r
# Convert all R scripts in a directory
rtoqmd_dir("path/to/scripts")

# Convert and render all scripts to custom HTML directory
rtoqmd_dir("path/to/scripts", 
           render = TRUE,
           output_html_dir = "docs/html")

# With custom settings
rtoqmd_dir("path/to/scripts", 
           author = "Data Team",
           exclude_pattern = "test_.*\\.R$")
```

## Source R script format

For the conversion to work properly, structure your R script using
RStudio code sections:

``` r
# Title : Iris Data Analysis
#
# Author : Jane Doe
#
# Date : 2025-11-28
#
# Description : Explore differences between iris species
#

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

#### 0. Document Metadata (Optional)

You can define metadata directly in your R script using special comments
at the beginning:

- **Title**: `# Title : My title` or `# Titre : Mon titre`
- **Author**: `# Author : My name` or `# Auteur : Mon nom`
- **Date**: `# Date : YYYY-MM-DD`
- **Description**: `# Description : Your description`

**💡 RStudio Snippet:** Create a snippet for quick metadata insertion
(Tools \> Edit Code Snippets \> R):

    snippet header
        # Title : ${1}
        #
        # Author : ${2}
        #
        # Date : ${3}
        #
        # Description : ${4}
        #

Type `header` + `Tab` in your script to insert the metadata structure.

**Behavior:** - Metadata found in script **overrides** function
parameters - Metadata lines are **removed** from document body (only in
YAML) - If no metadata in script, function parameters are used

> **📝 Note:** The `Description` field can span multiple lines. To
> continue the description, start the next line with `#` followed by at
> least one space. Continuation lines are automatically concatenated.
> Example:
>
> ``` r
> # Description : This analysis explores differences between iris species
> # using various statistical methods and visualization techniques
> # to identify patterns and correlations.
> ```

`quartify` recognizes three types of lines in your R script:

#### 1. Code Sections (Headers)

RStudio code sections become markdown headers. **Critical**: trailing
symbols must be at least 4 characters long:

- `## Title ----` → Level 2 header (at least 4 `#`, `=` or `-` at the
  end)
- `### Title ----` → Level 3 header (at least 4 `#`, `=` or `-` at the
  end)
- `#### Title ----` → Level 4 header (at least 4 `#`, `=` or `-` at the
  end)

**Note:** You can use `#`, `=`, or `-` interchangeably as trailing
symbols (e.g., `## Title ====` or `### Title ----` will work).

#### 2. Regular Comments (Text)

Single `#` comments **at the start of a line (no leading space)** become
explanatory text:

``` r
# This is a standalone comment
# It becomes plain text in the Quarto document
```

> **⚠️ Important:** For a comment to be converted to text, the line must
> start with `#` **without any leading space**. Indented comments (with
> spaces before `#`) remain in the code.

> **💡 Tip:** To **split a long chunk into multiple parts**, insert a
> **comment at the start of a line** (no space before `#`) between two
> code blocks. This comment will be converted to text and naturally
> create two separate chunks.

**Tip:** Use RStudio’s [Comment/Uncomment
shortcut](https://docs.posit.co/ide/user/ide/guide/productivity/text-editor.html#commentuncomment)
(`Ctrl+Shift+C` on Windows/Linux or `Cmd+Shift+C` on Mac) to quickly add
or remove comments.

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

#### 5. Callouts

Callouts are special blocks that highlight important information. Five
types are supported: `note`, `tip`, `warning`, `caution`, `important`.

**Syntax in R script:**

``` r
# callout-note - Important Note
# This is the content of the callout.
# It can span multiple lines.

# Empty line or code ends the callout
x <- 1
```

**Converts to Quarto:**

``` markdown
::: {.callout-note title="Important Note"}
This is the content of the callout.
It can span multiple lines.
:::
```

**Without title:**

``` r
# callout-tip
# This is a tip without a title.
```

Callouts end when encountering an empty line, code, or another section.

#### 6. Mermaid Diagrams

Create flowcharts, sequence diagrams, and other visualizations using
Mermaid syntax.

**Syntax in R script:**

``` r
#| mermaid
#| eval: true
flowchart TD
    A[Start] --> B[Process]
    B --> C{Decision}
    C -->|Yes| D[End]
    C -->|No| B
```

**Converts to Quarto Mermaid chunk** with proper formatting for diagram
rendering in HTML output.

**Supported diagram types:** - Flowcharts (`flowchart TD`,
`flowchart LR`) - Sequence diagrams (`sequenceDiagram`) - Class diagrams
(`classDiagram`) - State diagrams, Gantt charts, and more

**Rules:** - Start with `#| mermaid` comment - Add chunk options with
`#|` (e.g., `#| eval: true`) - Diagram content follows without `#`
prefix - Chunk ends at first blank line or comment

See complete example in
[`inst/examples/example_mermaid.R`](https://github.com/ddotta/quartify/blob/main/inst/examples/example_mermaid.R)

#### 7. Tabsets

Organize related content in interactive tabs for better presentation and
navigation.

**Syntax in R script:**

``` r
# tabset

# tab - Summary
# Display summary statistics

summary(data)

# tab - Structure
# Show data structure

str(data)

# tab - Preview
# First rows of data

head(data)
```

**Converts to Quarto tabset** with interactive tabs in HTML output.

**Rules:** - Start with `# tabset` comment to begin the tabset
container - Define each tab with `# tab - Tab Title` - Add content
(comments and code) after each tab declaration - Tabset closes
automatically at next section or end of file - Tabs can contain text,
code chunks, and any other content

See complete example in
[`inst/examples/example_tabset.R`](https://github.com/ddotta/quartify/blob/main/inst/examples/example_tabset.R)

**Important rules:**

- Always include a space after `#` for comments
- Section headers MUST have at least 4 trailing symbols
- **Standalone comments with `#` at line start** → become text outside
  code blocks
- **Inline comments within code** → stay inside code blocks
- **Callouts** → `# callout-TYPE` or `# callout-TYPE - Title`
- **Mermaid diagrams** → `#| mermaid` followed by options and diagram
  content
- **Tabsets** → `# tabset` then `# tab - Title` for each tab
- Consecutive code lines are grouped in the same block
- Empty lines between blocks are ignored

This follows the [RStudio code sections
convention](https://docs.posit.co/ide/user/ide/guide/code/code-sections.html)
which provides proper indentation in the RStudio document outline
navigation.

## Quarto Themes

Customize the appearance of your HTML documents with Quarto themes. The
package supports all available Bootswatch themes:

**Light themes**: cosmo, flatly, journal, litera, lumen, lux, materia,
minty, morph, pulse, quartz, sandstone, simplex, sketchy, spacelab,
united, vapor, yeti, zephyr

**Dark themes**: darkly, cyborg, slate, solar, superhero

Example:

``` r
# Use the "flatly" theme
rtoqmd("my_script.R", theme = "flatly")

# Use the dark "darkly" theme
rtoqmd("my_script.R", theme = "darkly")
```

For more information about themes, see the [Quarto
documentation](https://quarto.org/docs/output-formats/html-themes.html).

## Output and documentation

The generated .qmd document contains:  
- A complete YAML header with table of contents configuration  
- Properly structured headers from RStudio code sections  
- Textual explanations from your comments  
- **Non-executable code chunks** for static documentation

📝 **For a complete example of the generated output**, see the [Getting
Started
vignette](https://ddotta.github.io/quartify/articles/getting-started.html#generated-output)

## CI/CD Integration

Use `quartify` in your CI/CD pipelines to automatically generate
documentation:

**GitHub Actions** (`.github/workflows/generate-docs.yml`):

``` yaml
- name: Generate documentation
  run: |
    library(quartify)
    rtoqmd_dir("scripts/", render = TRUE, author = "Data Team")
  shell: Rscript {0}

- uses: actions/upload-artifact@v4
  with:
    name: documentation
    path: |
      scripts/**/*.qmd
      scripts/**/*.html
```

**GitLab CI** (`.gitlab-ci.yml`):

``` yaml
generate-docs:
  image: rocker/r-ver:4.5.1
  script:
    - R -e "quartify::rtoqmd_dir('scripts/', render = TRUE, author = 'Data Team')"
  artifacts:
    paths:
      - scripts/**/*.qmd
      - scripts/**/*.html
```

📘 **Full CI/CD guide** with complete examples: [CI/CD
Integration](https://ddotta.github.io/quartify/articles/getting-started.html#cicd-integration)

## License

MIT
