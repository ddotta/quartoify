\name{rtoqmd}
\alias{rtoqmd}
\title{Convert R Script to Quarto Markdown}
\usage{
rtoqmd(input_file, output_file = NULL)
}
\arguments{
\item{input_file}{Path to the input R script file}

\item{output_file}{Path to the output Quarto markdown file (optional)}
}
\value{
NULL
}
\description{
This function converts an R script to Quarto markdown format.
}
\examples{
\dontrun{
rtoqmd("script.R", "output.qmd")
}
}
