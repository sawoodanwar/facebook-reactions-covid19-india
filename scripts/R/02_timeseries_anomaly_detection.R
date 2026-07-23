# =============================================================================
# Script 02: Time Series Anomaly Detection
# Facebook Reactions COVID-19 India — Doctoral Thesis
# Author: Sawood Anwar | University of Urbino Carlo Bo
# Publication: Frontiers in Sociology, 2024 | DOI: 10.3389/fsoc.2024.1379265
#
# Methods: Percentage Change Method + Z-score with Rolling Statistics
# See Thesis Chapter 4 (pp. 55-63) and Appendix B (pp. 170-181)
# =============================================================================

library(dplyr)
library(ggplot2)
library(zoo)
library(readr)
library(lubridate)
library(scales)

# Source preprocessing script
# source("scripts/R/01_data_import_preprocessing.R")

# =============================================================================
# Main Analysis Function
# Applies both percentage change and Z-score methods per reaction per outlet
# =============================================================================
analyze_reaction <- function(data, reaction, outlet) {

  # Map reaction names to CrowdTangle column names
  reaction_col <- paste0("statistics.actual.", reaction, "Count")

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
      diff = reaction_count - lag(reaction_count),
      pct_change = diff / lag(reaction_count) * 100
    )

  # -------------------------------------------------------------------------
  # Method 1: Z-score with 7-day Rolling Statistics (Thesis pp. 57-62)
  # Z = (X - rolling_mean) / rolling_sd
  # Days with |Z| > 2 are flagged as unusual
  # -------------------------------------------------------------------------
  data$rolling_mean <- rollmean(data$reaction_count, k = 7, fill = NA, align = "right")
  data$rolling_sd   <- rollapply(data$reaction_count, width = 7, FUN = sd, fill = NA, align = "right")
  data$z_score      <- (data$reaction_count - data$rolling_mean) / data$rolling_sd

  # -------------------------------------------------------------------------
  # Method 2: Percentage Change — 95th percentile threshold (Thesis p. 57)
  # -------------------------------------------------------------------------
  z_score_threshold   <- 2
  pct_change_threshold <- quantile(abs(data$pct_change), 0.95, na.rm = TRUE)

  # Flag unusual days using both methods combined
  data$unusual <- abs(data$z_score) > z_score_threshold &
                  abs(data$pct_change) > pct_change_threshold

  # Top 5 sudden changes
  top_changes <- data %>%
    arrange(desc(abs(pct_change))) %>%
    head(5)

  # Extract unusual days
  unusual_days <- data %>%
    filter(unusual) %>%
    select(Date, reaction_count, z_score, pct_change)

  # -------------------------------------------------------------------------
  # Visualisation
  # -------------------------------------------------------------------------
  p <- ggplot(data, aes(x = Date, y = reaction_count)) +
    geom_line(color = "blue", linewidth = 0.5) +
    geom_point(data = unusual_days, color = "red", size = 3) +
    geom_smooth(method = "loess", color = "green", se = FALSE, linewidth = 1) +
    labs(
      title    = paste("Reaction:", reaction, "for", outlet),
      subtitle = "Red points indicate unusual days",
      x        = "Date",
      y        = paste(reaction, "Count")
    ) +
    theme_minimal() +
    theme(
      plot.title    = element_text(face = "bold", size = 16),
      plot.subtitle = element_text(face = "italic", size = 12),
      axis.title    = element_text(face = "bold"),
      axis.text.x   = element_text(angle = 45, hjust = 1)
    ) +
    scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") +
    scale_y_continuous(labels = comma_format())

  # -------------------------------------------------------------------------
  # Save Outputs
  # -------------------------------------------------------------------------
  dir.create("results", showWarnings = FALSE)

  ggsave(paste0("results/", outlet, "_", reaction, "_plot.png"), p, width = 12, height = 8, dpi = 300)
  write_csv(data, paste0("results/", outlet, "_", reaction, "_analysis.csv"))

  if (nrow(unusual_days) > 0) {
    unusual_days_with_url <- unusual_days %>%
      mutate(URL = paste0("https://www.facebook.com/", outlet, "/posts/", Date))
    write_csv(unusual_days_with_url, paste0("results/", outlet, "_", reaction, "_unusual_days.csv"))
    cat("Unusual days file created for", reaction, "reaction of", outlet, "\n")
  } else {
    cat("No unusual days found for", reaction, "reaction of", outlet, "\n")
  }

  print(top_changes[, c("Date", "reaction_count", "diff", "pct_change")])
}

# =============================================================================
# Execute Analysis: Loop over all outlets and all reaction types
# =============================================================================
# Requires df to be loaded via script 01
# source("scripts/R/01_data_import_preprocessing.R")

reactions <- c("like", "love", "wow", "haha", "sad", "angry", "care")
outlets   <- unique(df$account.name)

for (outlet in outlets) {
  outlet_data <- filter(df, account.name == outlet)
  for (reaction in reactions) {
    analyze_reaction(outlet_data, reaction, outlet)
  }
}
