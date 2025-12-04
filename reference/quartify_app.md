# Launch Quartify Shiny Interface

Opens the Quartify conversion interface in your default web browser.
This function provides the same interface as the RStudio add-in but
works in any R environment including Positron, VS Code, RStudio, or
command line. Unlike the add-in, this function requires you to manually
select input files using the file browser in the interface.

## Usage

``` r
quartify_app(launch.browser = TRUE, port = NULL)
```

## Arguments

- launch.browser:

  Logical, whether to open in browser (default: TRUE). Set to FALSE to
  run in RStudio Viewer pane if available.

- port:

  The port to run the app on (default: random available port)

## Value

Invisibly returns NULL when the app is closed

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
