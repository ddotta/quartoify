# Base image - using r-ver instead of shiny to avoid Shiny Server checks
FROM rocker/r-ver:4.4.1

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

# Ensure man/figures images are accessible (they may not be installed with package)
RUN mkdir -p /usr/local/lib/R/site-library/quartify/figures && \
    cp /quartify/man/figures/*.png /usr/local/lib/R/site-library/quartify/figures/

# Verify Quarto installation and add to PATH
RUN quarto --version
ENV PATH="/usr/local/bin:${PATH}"

# Expose port where shiny app will broadcast
EXPOSE 3838

# Run the web version of the app (with upload/download instead of file browser)
# Use host 0.0.0.0 to allow external connections
CMD ["Rscript", "-e", "options(shiny.host='0.0.0.0', shiny.port=3838); quartify::quartify_app_web(launch.browser=FALSE)"]
