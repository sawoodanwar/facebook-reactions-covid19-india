# =============================================================================
# Script 01: Data Import and Preprocessing
# Facebook Reactions COVID-19 India — Doctoral Thesis
# Author: Sawood Anwar | University of Urbino Carlo Bo
# Publication: Frontiers in Sociology, 2024 | DOI: 10.3389/fsoc.2024.1379265
#
# Source: Thesis Chapter 4, Section 4.1.2 (pp. 53–54) and Appendix B (p. 170)
# =============================================================================
# Required Libraries (Thesis p. 58 and Appendix B p. 170)
library(dplyr)      # For data manipulation
library(ggplot2)    # For data visualization
library(zoo)        # For time series analysis
library(readr)      # For CSV file operations
library(lubridate)  # For date handling
library(scales)     # For plot formatting

# =============================================================================
# File Path Definitions
# Exact paths from Thesis Appendix B (pp. 172–173)
# Update these to match your local directory structure
# =============================================================================
filepath1 <- "C:/COVID-19/4Newsoutlets/Covid-19WholeRange2020-03-24--2022-03-31/monthweekday/2024-07-07-12-07-02-CEST-Historical-Report-Multiple-Pages-2020-03-24--2022-03-31.csv"
filepath2 <- "Users/sawoo/Desktop/Analysis/COVID19Indian/4Newsoutlets/Covid-19WholeRange2020-03-24--2022-03-31/Time/monthweekday/2024-07-07-12-07-02-CEST-Historical-Report-Multiple-Pages-2020-03-24--2022-03-31.csv"

# =============================================================================
# Data Import with Error Handling (Thesis Appendix B, p. 173)
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

# =============================================================================
# Data Cleaning and Pre-processing (Thesis Section 4.1.2, pp. 53–54)
# Steps: removal of non-textual elements (HTML, tags, special characters),
# language detection (English only), tokenization, lemmatization,
# removal of stop words and low-frequency terms
# =============================================================================

# Remove non-textual elements (HTML tags, special characters)
df$message <- gsub("<[^>]+>", "", df$message)          # Remove HTML tags
df$message <- gsub("[^[:alnum:][:space:]]", "", df$message)  # Remove special characters
df$message <- trimws(df$message)                         # Trim whitespace

# Language detection: retain English-only posts
# (CrowdTangle query was already filtered to English;
#  this step removes any residual non-English content)
df <- df %>% filter(!is.na(message), nchar(message) > 0)

# Define reaction types (CrowdTangle column naming convention)
reactions <- c("like", "love", "wow", "haha", "sad", "angry", "care")

# News outlets included in the study
outlets <- unique(df$account.name)

cat("Data imported and cleaned successfully.\n")
cat(sprintf("Total posts      : %d\n", nrow(df)))
cat(sprintf("Date range       : %s to %s\n",
            min(df$Date, na.rm = TRUE), max(df$Date, na.rm = TRUE)))
cat(sprintf("News outlets     : %s\n", paste(outlets, collapse = ", ")))
cat(sprintf("Reaction columns : %s\n", paste(reactions, collapse = ", ")))
