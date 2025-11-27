\name{rtoqmd}
\alias{rtoqmd}
\title{Convert R Script to Quarto Markdown}
\usage{
rtoqmd(input_file, output_file = NULL, title = "My title", 
       author = "Damien Dotta", format = "html")
}
\arguments{
\item{input_file}{Path to the input R script file}

\item{output_file}{Path to the output Quarto markdown file (optional, defaults to same name with .qmd extension)}

\item{title}{Title for the Quarto document (default: "My title")}

\item{author}{Author name (default: "Damien Dotta")}

\item{format}{Output format (default: "html")}
}
\value{
NULL (creates output file)
}
\description{
This function converts an R script to Quarto markdown format.
Comments starting with # ## to # ###### are converted to markdown headers (levels 2 to 6).
Regular comments are converted to plain text.
Code blocks are wrapped in code chunks.
}
\examples{
\dontrun{
# Use example file included in package
example_file <- system.file("examples", "example.R", package = "quartify")
rtoqmd(example_file, "output.qmd")
}
}
