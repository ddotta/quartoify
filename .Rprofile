# .Rprofile for shinyapps.io deployment
# This ensures quartify is properly loaded

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Load quartify package
if (requireNamespace("quartify", quietly = TRUE)) {
  library(quartify)
}
