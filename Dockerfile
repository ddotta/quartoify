# Base image
FROM rocker/shiny:4.4.1

# Install Quarto
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        wget \
        libssl-dev \
        libxml2-dev \
        libcurl4-openssl-dev \
        fontconfig \
        libharfbuzz-dev \
        libfribidi-dev && \
    wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.4.549/quarto-1.4.549-linux-amd64.deb && \
    dpkg -i quarto-1.4.549-linux-amd64.deb && \
    rm quarto-1.4.549-linux-amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install R package and its dependencies
RUN install2.r remotes
COPY . /quartify
RUN Rscript -e 'remotes::install_deps("/quartify")'
RUN Rscript -e 'install.packages("/quartify", repos = NULL, type="source")'

# Create app directory for Shiny Server
RUN mkdir -p /srv/shiny-server/quartify

# Create app.R for Shiny Server
RUN echo 'library(quartify)\nquartify_app()' > /srv/shiny-server/quartify/app.R

# Expose port where shiny app will broadcast
EXPOSE 3838

# Use Shiny Server (already configured in rocker/shiny)
CMD ["/usr/bin/shiny-server"]
