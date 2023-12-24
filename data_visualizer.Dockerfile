#FROM rocker/shiny:latest

FROM hvalev/shiny-server-arm:latest

# Install required system libraries for tidyverse
RUN apt-get update && apt-get install -y --no-install-recommends libcurl4-openssl-dev libssl-dev libfontconfig1-dev libxml2-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev -y

# Install Shiny and other required packages
RUN R -e "install.packages(c('shiny', 'ggplot2', 'SnowballC', 'tm', 'wordcloud', 'RColorBrewer', 'tidyverse', 'ngram', 'dplyr', 'shinydashboard','tidyr'), repos='http://cran.rstudio.com/', dependencies=TRUE)"

# Run the Shiny app
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/DataVisualizer')"]

