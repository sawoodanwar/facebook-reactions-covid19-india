# R package dependencies
# Install with: install.packages(c(...))

required_packages <- c(
  "sentimentr",    # Lexicon-based sentiment analysis
  "ggplot2",       # Visualization
  "dplyr",         # Data manipulation
  "tidyr",         # Data tidying
  "lubridate",     # Date/time handling
  "zoo",           # Rolling statistics for time series
  "forecast",      # Time series analysis
  "anomalize",     # Anomaly detection in time series
  "readr",         # Reading CSV files
  "stringr",       # String manipulation
  "purrr",         # Functional programming tools
  "scales"         # Scale functions for visualization
)

# Install missing packages
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

lapply(required_packages, install_if_missing)
