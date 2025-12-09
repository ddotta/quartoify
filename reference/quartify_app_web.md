# Launch Quartify Web Application

Web-deployable Shiny application with file upload/download capabilities
for converting R scripts to Quarto markdown documents. Suitable for
deployment on Shiny Server, ShinyApps.io, or other web hosting
platforms.

## Usage

``` r
quartify_app_web(launch.browser = TRUE, port = NULL)
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
quartify_app_web()
} # }
```
