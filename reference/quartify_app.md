# Launch Quartify Standalone Application

Standalone Shiny application for converting R scripts to Quarto markdown
documents. Works in any R environment (RStudio, Positron, VS Code, etc.)
without requiring the RStudio API.

## Usage

``` r
quartify_app(launch.browser = TRUE, port = NULL)
```

## Arguments

- launch.browser:

  Logical, whether to launch browser (default: TRUE)

- port:

  Integer, port number for the application (default: NULL for random
  port)

## Value

No return value, called for side effects (launches a Shiny application).

## Examples

``` r
if (FALSE) { # \dontrun{
# Launch the Shiny app in browser (works in any IDE)
quartify_app()

# Use in Positron or VS Code
library(quartify)
quartify_app()

# Specify a port
quartify_app(port = 3838)
} # }
```
