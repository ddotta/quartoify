# Code Quality Integration in quartify

## Overview

quartify now integrates with **styler** and **lintr** to provide automated code quality checks and formatting suggestions directly in your generated documentation.

## Features

### Styler Integration (`use_styler = TRUE`)

Automatically formats your R code according to the tidyverse style guide and displays:
- **Original Code**: Your code as written
- **Styled Code**: The formatted version (only shown if changes are needed)
- Side-by-side comparison in interactive tabsets

### Lintr Integration (`use_lintr = TRUE`)

Runs code quality checks and displays:
- **Lint Issues**: A list of style violations and potential problems
- Line-by-line feedback on code quality issues
- Recommendations for improvement

### Smart Tabsets

Tabsets are **only created when needed**:
- If no style changes or lint issues: regular code chunk (no tabset)
- If issues found: interactive tabset with Original Code, Styled Code, and/or Lint Issues

## Installation

Install the optional dependencies:

```r
install.packages(c("styler", "lintr"))
```

## Usage

### Basic Usage

```r
library(quartify)

# With styler only
rtoqmd("script.R", "output.qmd", use_styler = TRUE)

# With lintr only  
rtoqmd("script.R", "output.qmd", use_lintr = TRUE)

# With both
rtoqmd("script.R", "output.qmd", use_styler = TRUE, use_lintr = TRUE)
```

### Batch Processing

```r
# Convert entire directory with quality checks
rtoqmd_dir(
  dir_path = "my_scripts/",
  output_html_dir = "documentation/",
  use_styler = TRUE,
  use_lintr = TRUE,
  render = TRUE
)
```

### Example Script

Try the included example:

```r
example_file <- system.file("examples", "example_code_quality.R", package = "quartify")

# Convert with both checks
rtoqmd(example_file, "quality_demo.qmd", 
       use_styler = TRUE, 
       use_lintr = TRUE,
       render = TRUE,
       open_html = TRUE)
```

## Example Output

Given this code with style issues:

```r
x = 3  # Should use <- instead of =
y <- 2
z<-10  # Missing spaces
```

With `use_styler = TRUE`, you'll see a tabset showing:

**Original Code:**
```r
x = 3  # Should use <- instead of =
y <- 2
z<-10  # Missing spaces
```

**Styled Code:**
```r
x <- 3 # Should use <- instead of =
y <- 2
z <- 10 # Missing spaces
```

**Lint Issues** (with `use_lintr = TRUE`):
- Line 1: Use one of <-, <<- for assignment, not =.
- Line 3: Put spaces around all infix operators.

## Benefits

1. **Learn by Example**: See proper R coding style alongside your code
2. **Code Review**: Automatic quality feedback without manual review
3. **Teaching Tool**: Perfect for educational materials and tutorials
4. **Documentation**: Generate clean, well-styled code in documentation
5. **Best Practices**: Enforce tidyverse style guide automatically

## Configuration

Both styler and lintr use their default configurations. For custom settings:

- **styler**: Create a `.styler.R` file in your project
- **lintr**: Create a `.lintr` file in your project

See their respective documentation for configuration options:
- [styler documentation](https://styler.r-lib.org/)
- [lintr documentation](https://lintr.r-lib.org/)

## Performance Notes

- Code quality checks add processing time (typically < 1 second per chunk)
- Checks run only when parameters are TRUE (default: FALSE)
- Suitable for documentation generation workflows
- May slow down large batch conversions

## Troubleshooting

If you see warnings about missing packages:

```r
install.packages("styler")  # For formatting
install.packages("lintr")   # For linting
```

If checks fail for a specific chunk, the original code is displayed without a tabset, and a warning is logged.
