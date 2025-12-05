# Changelog

## quartify 0.0.5

### New Features

- **Source Line Numbers**:
  - Added `show_source_lines` parameter to
    [`rtoqmd()`](https://ddotta.github.io/quartify/reference/rtoqmd.md)
    to display original line numbers from source R script

  - When enabled, adds a comment at the beginning of each code chunk
    indicating the line range

  - Format: `# Lines X-Y` (English) or `# Lignes X-Y` (French)

  - Helps maintain traceability between documentation and source code

  - Added checkbox in RStudio add-in interface with EN/FR translations

  - Example output:

    ``` r
    # Lines 19-20
    iris |> 
      count(Species)
    ```

  - Completely automatic - no modification of R scripts required

  - Default is FALSE to preserve existing behavior

## quartify 0.0.4

### New Features

- **Custom HTML Output Path**:
  - Added `output_html_file` parameter to
    [`rtoqmd()`](https://ddotta.github.io/quartify/reference/rtoqmd.md)
    to specify custom HTML output location
  - Added `output_html_dir` parameter to
    [`rtoqmd_dir()`](https://ddotta.github.io/quartify/reference/rtoqmd_dir.md)
    to specify directory for batch HTML outputs
  - Added HTML file selector in RStudio add-in interface (optional
    field)
  - HTML files can now be saved in different location than .qmd files
  - Useful for organizing outputs in separate directories (e.g.,
    `docs/`, `html_output/`)
- **Mermaid Diagram Support**:
  - Added support for Mermaid diagrams to create flowcharts, sequence
    diagrams, and other visualizations

  - Use `#| mermaid` comment to start a Mermaid chunk in R scripts

  - Chunk options (lines starting with `#|`) are automatically converted
    to Quarto format (`%%|`)

  - Diagram content follows without `#` prefix and ends at empty line or
    comment

  - Example syntax:

    ``` r
    #| mermaid
    #| eval: true
    flowchart TD
        A[Start] --> B[Process]
        B --> C[End]
    ```

  - Converted to proper Quarto Mermaid chunks in .qmd output
- **Tabset Support**:
  - Added support for tabsets to organize related content in interactive
    tabs

  - Use `# tabset` to start a tabset container, then `# tab - Title` for
    each tab

  - Perfect for displaying alternative views, different analyses, or
    grouped visualizations

  - Tabsets automatically close at RStudio section headers

  - Example syntax:

    ``` r
    # tabset
    # tab - Summary Statistics
    # Here are the basic summary statistics:
    summary(iris)

    # tab - Data Structure
    # Let's examine the structure:
    str(iris)

    # tab - First Rows
    # Here are the first few rows:
    head(iris)
    ```

  - Converted to Quarto `{.panel-tabset}` format in .qmd output

  - See `inst/examples/example_tabset.R` for complete examples

### Bug Fixes

- Fixed issue where Quarto render command needed to run from .qmd file
  directory
- Improved path handling for custom HTML output locations with relative
  paths
- Added proper working directory management during Quarto rendering

## quartify 0.0.3

### CRAN Preparation

- Removed vignettes from package build (vignettes available online via
  pkgdown site)
- Quoted ‘RStudio’ in DESCRIPTION to address CRAN check notes
- Converted non-ASCII characters in R/addins.R to Unicode escapes
  (\uxxxx) for portability
- Enhanced online documentation with red-highlighted critical rules
  sections for better visibility
- Fixed R version consistency in CI/CD examples (updated to 4.5.1)

## quartify 0.0.2

### New Features

- **Improved RStudio Add-in Interface**:
  - File browsers for input and output file selection using shinyFiles
  - Language buttons (EN/FR) moved to title bar next to GO button
  - Input and output file selectors on the same row for better UX
  - Title, Author, and Theme widgets organized on the same line
  - Checkboxes organized in 2 columns for better layout
  - Automatic language detection based on R session locale preferences
  - Session cleanup: app properly stops when browser window is closed
- **Theme Support**:
  - Added HTML theme selection (25+ Quarto Bootswatch themes available)
  - Theme parameter in
    [`rtoqmd()`](https://ddotta.github.io/quartify/reference/rtoqmd.md)
    and
    [`rtoqmd_dir()`](https://ddotta.github.io/quartify/reference/rtoqmd_dir.md)
    functions
  - Theme selection in RStudio add-in interface
- **Language Support**:
  - Added `lang` parameter to
    [`rtoqmd()`](https://ddotta.github.io/quartify/reference/rtoqmd.md)
    function
  - Table of contents title adapts to language: “Sommaire” (FR) or
    “Table of contents” (EN)
  - Add-in automatically detects user’s R session language
- **Enhanced Section Title Handling**:
  - Flexible regex pattern accepts any RStudio section symbol (#, =, -)
  - Trailing symbols properly removed from section titles in output

### Improvements

- Updated interface labels:
  - “Render Html after conversion” (previously “Render after
    conversion”)
  - “Open Html output file after rendering” (previously “Open output
    file after rendering”)
  - “Number sections automatically (not needed if sections already
    numbered)” with helpful note
- Removed unsupported format option:
  - Format parameter now always uses “html” (PDF removed from add-in
    interface)
  - Updated all documentation to reflect HTML-only support

### Bug Fixes

- Fixed pkgdown configuration:
  - Added `aria-label` to home icon for accessibility
  - Added `rtoqmd_dir` to reference index

### Documentation

- Updated README (EN/FR) with:
  - Automatic language detection feature
  - File browser information
  - Theme selection examples
  - Complete list of available themes
- Enhanced vignettes with:
  - Multi-line Description field syntax
  - Comment conversion rules
  - Chunk splitting technique documentation
  - Theme usage examples

## quartify 0.0.1

### Initial Release

- First public release of quartify package

### Features

- **Automatic R to Quarto Conversion**: Convert R scripts (.R) to Quarto
  markdown documents (.qmd) with proper formatting
- **RStudio Code Sections Support**: Recognizes RStudio code section
  syntax (`####`, `====`, `----`) and converts them to hierarchical
  markdown headers with correct indentation levels (levels 2, 3, and 4)
- **Metadata Extraction**: Automatically extracts metadata from special
  comments in R scripts:
  - `# Title :` or `# Titre :` for document title
  - `# Author :` or `# Auteur :` for author name
  - `# Date :` for document date
  - `# Description :` for document description
  - Metadata found in scripts overrides function parameters
- **Bilingual RStudio Add-in**: Interactive Shiny interface with
  English/French language support for easy conversion through RStudio’s
  Addins menu
- **Comment Preservation**: Regular comments are converted to
  explanatory text, while inline comments within code blocks are
  preserved
- **Markdown Table Support**: Proper rendering of markdown tables in
  comments when lines are isolated with empty comment lines
- **Customizable Output**:
  - HTML output format
  - Control section numbering
  - Enable/disable code folding
  - Automatic HTML rendering and opening in browser
- **RStudio Snippet**: Included snippet for quick metadata header
  insertion in R scripts
- **Comprehensive Documentation**:
  - Bilingual vignettes (English/French)
  - Detailed README with examples
  - Complete function documentation

### Technical Details

- Generated Quarto documents include proper YAML headers with table of
  contents configuration
- Code chunks are non-executable by default (static documentation mode)
- HTML output uses `embed-resources: true` for self-contained files
- Roxygen comments (`#'`) are automatically ignored during conversion
