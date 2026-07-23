# =============================================================================
# Script 03: Lexicon-Based Sentiment Analysis
# Facebook Reactions COVID-19 India — Doctoral Thesis
# Author: Sawood Anwar | University of Urbino Carlo Bo
# Publication: Frontiers in Sociology, 2024 | DOI: 10.3389/fsoc.2024.1379265
#
# Package: sentimentr (Rinker, 2015-2024)
# See Thesis Chapter 4, Section 4.4 (pp. 64-68) and Appendix D
# =============================================================================

library(dplyr)
library(sentimentr)   # Lexicon-based sentiment with valence shifters
library(ggplot2)
library(readr)

# Source preprocessing script
# source("scripts/R/01_data_import_preprocessing.R")

# =============================================================================
# Sentiment Calculation
# sentimentr accounts for valence shifters: negators, amplifiers,
# de-amplifiers, and adversative conjunctions (Rinker, 2016)
# =============================================================================

# Calculate sentence-level sentiment scores
sentiment_score <- sapply(
  df$message,
  function(x) sentiment_by(x)$ave_sentiment
)

df$sentiment_score <- sentiment_score

# =============================================================================
# User Engagement Matrix
# Aggregate Facebook Reactions into a single user reaction score
# Positive reactions: Love, Wow, Haha | Negative reactions: Sad, Angry
# See Thesis Section 4.4.2 (p. 67)
# =============================================================================

df <- df %>%
  mutate(
    user_reaction = statistics.actual.loveCount +
                    statistics.actual.wowCount  +
                    statistics.actual.hahaCount -
                    statistics.actual.sadCount  -
                    statistics.actual.angryCount
  )

# =============================================================================
# Statistical Summary per Cluster
# A: Sentiment score + user reactions per post
# B: Average sentiment, average user reaction, story count per cluster
# C: Correlation between average sentiment score and user reactions
# D: Sentiment score per cluster separately
# =============================================================================

cluster_summary <- df %>%
  group_by(cluster_label, account.name) %>%
  summarize(
    avg_sentiment  = mean(sentiment_score, na.rm = TRUE),
    avg_reaction   = mean(user_reaction,   na.rm = TRUE),
    story_count    = n(),
    .groups = "drop"
  )

# Correlation between average sentiment score and user reactions
correlation <- cor(
  cluster_summary$avg_sentiment,
  cluster_summary$avg_reaction,
  use = "complete.obs"
)
cat(sprintf("Correlation (avg_sentiment vs avg_reaction): %.4f\n", correlation))

# =============================================================================
# Visualisation: Sentiment Score vs User Reaction by Cluster
# =============================================================================

p_scatter <- ggplot(cluster_summary, aes(x = avg_sentiment, y = avg_reaction,
                                          color = account.name, label = cluster_label)) +
  geom_point(size = 3, alpha = 0.8) +
  geom_smooth(method = "lm", se = TRUE, color = "grey40") +
  labs(
    title    = "Average Sentiment Score vs. Average User Reaction by Cluster",
    subtitle = "Across four Indian news outlets, COVID-19 posts (2020-2022)",
    x        = "Average Sentiment Score (sentimentr)",
    y        = "Average User Reaction Score",
    color    = "News Outlet"
  ) +
  theme_minimal() +
  theme(
    plot.title  = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )

dir.create("results", showWarnings = FALSE)
ggsave("results/sentiment_vs_reaction_scatter.png", p_scatter, width = 12, height = 8, dpi = 300)
write_csv(cluster_summary, "results/cluster_sentiment_summary.csv")

cat("Sentiment analysis complete. Results saved to results/\n")
