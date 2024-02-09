#Install all libraries used in this pipeline
# Package names
packages <- c("ggplot2", "fmsb", "gridExtra", "dplyr", "reshape", "introdataviz")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
#invisible(lapply(packages, library, character.only = TRUE))
