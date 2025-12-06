# Launch Quartify Standalone Application

Launches a Shiny application for converting R scripts to Quarto
documents. Provides a user-friendly interface with options for single
file or batch processing.

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

Invisible NULL

## Examples

``` r
if (FALSE) { # \dontrun{
quartify_app()
} # }
```
