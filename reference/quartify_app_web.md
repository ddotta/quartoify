# Launch Quartify Web Application (for deployment)

Web-friendly version of quartify_app() designed for deployment on web
servers. Uses file upload/download instead of local file system access.

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

Invisible NULL

## Examples

``` r
if (FALSE) { # \dontrun{
quartify_app_web()
} # }
```
