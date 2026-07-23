# =============================================================================
# Script 02: Time Series Anomaly Detection
# Facebook Reactions COVID-19 India — Doctoral Thesis
# Author: Sawood Anwar | University of Urbino Carlo Bo
# Publication: Frontiers in Sociology, 2024 | DOI: 10.3389/fsoc.2024.1379265
#
# Methods:
#   1. Percentage Change Method (Thesis p. 57)
#   2. Z-score Method with 7-day Rolling Statistics (Thesis pp. 57–62)
#
# Source: Thesis Chapter 4, Section 4.2 (pp. 54–63) and
#         Appendix B (pp. 170–181) — verbatim R code
# =============================================================================

# Required Libraries (Thesis p. 58 and Appendix B p. 170)
library(dplyr)      # For data manipulation
library(ggplot2)    # For data visualization
library(zoo)        # For time series analysis
library(readr)      # For CSV file operations
library(lubridate)  # For date handling
library(scales)     # For plot formatting

# Source preprocessing (load df)
# source("scripts/R/01_data_import_preprocessing.R")

# Define reaction types (Thesis Appendix B, p. 172)
reactions <- c("like", "love", "wow", "haha", "sad", "angry", "care")

# =============================================================================
# Main Analysis Function (Thesis Appendix B, pp. 174–179)
# =============================================================================
analyze_reaction <- function(data, reaction, outlet) {

  # Map reaction names to CrowdTangle column names
  reaction_col <- paste0("statistics.actual.", reaction, "Count")

  # Ensure the reaction column exists
  if (!reaction_col %in% names(data)) {
    cat("Column", reaction_col, "not found for", outlet, "\n")
    return(NULL)
  }

  # Calculate daily statistics
  data <- data %>%
    arrange(Date) %>%
    group_by(Date) %>%
    summarize(reaction_count = sum(!!sym(reaction_col))) %>%
    ungroup() %>%
    mutate(
      diff       = reaction_count - lag(reaction_count),
      pct_change = diff / lag(reaction_count) * 100
    )

  # ---------------------------------------------------------------------------
  # Calculate rolling mean and standard deviation
  # Thesis p. 58 / Appendix B p. 175 (verbatim)
  # ---------------------------------------------------------------------------
  data$rolling_mean <- rollmean(data$reaction_count, k = 7, fill = NA, align = "right")
  data$rolling_sd   <- rollapply(data$reaction_count, width = 7, FUN = sd,
                                  fill = NA, align = "right")

  # Calculate Z-scores (Thesis p. 59 / Appendix B p. 175)
  data$z_score <- (data$reaction_count - data$rolling_mean) / data$rolling_sd

  # ---------------------------------------------------------------------------
  # Identify unusual days using both methods (Thesis p. 60 / Appendix B p. 175)
  # Z-score threshold = 2; pct_change threshold = 95th percentile
  # ---------------------------------------------------------------------------
  z_score_threshold    <- 2
  pct_change_threshold <- quantile(abs(data$pct_change), 0.95, na.rm = TRUE)

  data$unusual <- abs(data$z_score)      > z_score_threshold &
                  abs(data$pct_change)   > pct_change_threshold

  # Top 5 sudden changes
  top_changes  <- data %>% arrange(desc(abs(pct_change))) %>% head(5)

  # Extract unusual days
  unusual_days <- data %>%
    filter(unusual) %>%
    select(Date, reaction_count, z_score, pct_change)

  # ---------------------------------------------------------------------------
  # Create Visualisation (Thesis Appendix B, pp. 176–179)
  # ---------------------------------------------------------------------------
  p <- ggplot(data, aes(x = Date, y = reaction_count)) +
    # Base line
    geom_line(color = "blue", size = 0.5) +
    # Unusual days points
    geom_point(data = unusual_days, color = "red", size = 3) +
    # Trend line
    geom_smooth(method = "loess", color = "green", se = FALSE, size = 1) +
    # Labels and titles
    labs(
      title    = paste("Reaction:", reaction, "for", outlet),
      subtitle = "Red points indicate unusual days",
      x        = "Date",
      y        = paste(reaction, "Count")
    ) +
    # Theme customization
    theme_minimal() +
    theme(
      plot.title    = element_text(face = "bold",   size = 16),
      plot.subtitle = element_text(face = "italic", size = 12),
      axis.title    = element_text(face = "bold"),
      axis.text.x   = element_text(angle = 45, hjust = 1)
    ) +
    # Scale customization
    scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") +
    scale_y_continuous(labels = comma_format())

  # ---------------------------------------------------------------------------
  # Save Outputs (Thesis Appendix B, p. 179)
  # ---------------------------------------------------------------------------
  dir.create("results", showWarnings = FALSE)

  ggsave(paste0("results/", outlet, "_", reaction, "_plot.png"),
         p, width = 12, height = 8, dpi = 300)

  write_csv(data,
            paste0("results/", outlet, "_", reaction, "_analysis.csv"))

  if (nrow(unusual_days) > 0) {
    unusual_days_with_url <- unusual_days %>%
      mutate(URL = paste0("https://www.facebook.com/", outlet, "/posts/", Date))
    write_csv(unusual_days_with_url,
              paste0("results/", outlet, "_", reaction, "_unusual_days.csv"))
    cat("Unusual days file created for", reaction, "reaction of", outlet, "\n")
  } else {
    cat("No unusual days found for", reaction, "reaction of", outlet, "\n")
  }

  print(top_changes[, c("Date", "reaction_count", "diff", "pct_change")])
}

# =============================================================================
# Execution: loop over all outlets and all reaction types
# Thesis Appendix B, pp. 172–173
# =============================================================================
# Requires df to be loaded via Script 01
# source("scripts/R/01_data_import_preprocessing.R")

outlets <- unique(df$account.name)

for (outlet in outlets) {
  outlet_data <- filter(df, account.name == outlet)
  for (reaction in reactions) {
    analyze_reaction(outlet_data, reaction, outlet)
  }
}
