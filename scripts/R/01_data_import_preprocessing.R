# =============================================================================
# Script 01: Data Import and Preprocessing
# Facebook Reactions COVID-19 India — Doctoral Thesis
# Author: Sawood Anwar | University of Urbino Carlo Bo
# Publication: Frontiers in Sociology, 2024 | DOI: 10.3389/fsoc.2024.1379265
# =============================================================================

# Required Libraries
library(dplyr)      # Data manipulation
library(ggplot2)    # Data visualization
library(zoo)        # Time series analysis
library(readr)      # CSV file operations
library(lubridate)  # Date handling
library(scales)     # Plot formatting

# =============================================================================
# File Path Definitions
# Update these paths to point to your local CrowdTangle exports
# =============================================================================
filepath1 <- "data/Covid-19-WholeRange-2020-03-24--2022-03-31.csv"
filepath2 <- "data/Covid-19-WholeRange-2020-03-24--2022-03-31-alt.csv"

# =============================================================================
# Data Import with Error Handling
# =============================================================================
df <- tryCatch(
  read_csv(filepath1),
  error = function(e) tryCatch(
    read_csv(filepath2),
    error = function(e) stop("Error reading the CSV file. Please check the file path.")
  )
)

# Create Date column from 'Post Created Date'
df$Date <- as.Date(df$`Post Created Date`)

# Define reaction types (CrowdTangle column naming convention)
reactions <- c("like", "love", "wow", "haha", "sad", "angry", "care")

cat("Data imported successfully.\n")
cat(sprintf("Total posts: %d\n", nrow(df)))
cat(sprintf("Date range: %s to %s\n", min(df$Date, na.rm = TRUE), max(df$Date, na.rm = TRUE)))
cat(sprintf("News outlets: %s\n", paste(unique(df$account.name), collapse = ", ")))
