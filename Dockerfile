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

# Expose port where shiny app will broadcast
ARG SHINY_PORT=3838
EXPOSE $SHINY_PORT
RUN echo "local({options(shiny.port = ${SHINY_PORT}, shiny.host = '0.0.0.0')})" >> /usr/local/lib/R/etc/Rprofile.site

# Endpoint
CMD ["sh", "-c", "sleep 10 && Rscript -e 'quartify::quartify_app()'"]
