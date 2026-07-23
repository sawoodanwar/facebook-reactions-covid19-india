# =============================================================================
# Script 05: K-means Clustering + PCA + t-SNE Visualisation
# Facebook Reactions COVID-19 India — Doctoral Thesis
# Author: Sawood Anwar | University of Urbino Carlo Bo
# Publication: Frontiers in Sociology, 2024 | DOI: 10.3389/fsoc.2024.1379265
#
# Pipeline:
#   1. Load embeddings (output of Script 04)
#   2. PCA dimensionality reduction (large matrix → manageable)
#   3. Silhouette analysis → k = 25 clusters confirmed
#   4. K-means clustering (k = 25)
#   5. t-SNE 2D visualisation (perplexity = 30, iterations = 1000)
#
# See Thesis Chapter 4, Sections 4.3.2–4.3.3 (pp. 63–64)
# Visualisation output: Appendix C, Figure 1
# =============================================================================
# Required packages:
#   install.packages(c("dplyr", "ggplot2", "Rtsne", "cluster",
#                      "factoextra", "readr", "scales"))
# =============================================================================

library(dplyr)
library(ggplot2)
library(Rtsne)      # t-SNE implementation used in thesis
library(cluster)    # silhouette analysis
library(factoextra) # silhouette plots
library(readr)
library(scales)

set.seed(42)

# =============================================================================
# Configuration (mirrors Thesis Sections 4.3.2–4.3.3)
# =============================================================================
n_clusters      <- 25   # Final k from silhouette analysis
pca_components  <- 50   # PCA reduction before K-means
tsne_perplexity <- 30   # Thesis p. 63
tsne_iterations <- 1000 # Thesis p. 63

# =============================================================================
# Step 1: Load Embeddings
# =============================================================================
embedded_file <- ".processed_data/sawood_embedded.rds"

if (!file.exists(embedded_file)) {
  stop("Embeddings file not found. Please run Script 04 first.")
}

data <- readRDS(embedded_file)
message("Loaded ", nrow(data), " embedded posts")

# Extract embedding matrix
embedding_matrix <- do.call(rbind, data$text_embedding)

# Remove rows with NA embeddings
valid_idx        <- complete.cases(embedding_matrix)
embedding_matrix <- embedding_matrix[valid_idx, ]
data             <- data[valid_idx, ]
message("Valid embeddings: ", nrow(data))

# =============================================================================
# Step 2: PCA Dimensionality Reduction
# Thesis: "we run the Principal Component Analysis PCA setting
# for large matrices of 8096 data" (p. 63)
# =============================================================================
message("Running PCA: ", ncol(embedding_matrix), "D → ", pca_components, "D")
pca_result      <- prcomp(embedding_matrix, center = TRUE, scale. = TRUE)
embedding_pca   <- pca_result$x[, seq_len(pca_components)]

pct_explained   <- sum(pca_result$sdev[seq_len(pca_components)]^2) /
                   sum(pca_result$sdev^2) * 100
message(sprintf("PCA complete. Variance explained: %.1f%%", pct_explained))

# =============================================================================
# Step 3: Silhouette Analysis to Confirm Optimal k
# Thesis: "we employed the Silhouette analysis to find out how similar
# an objective is to other clusters" → k = 25 (p. 63)
# =============================================================================
message("Running silhouette analysis for k = 5 to 35...")

k_range          <- 5:35
silhouette_scores <- numeric(length(k_range))

for (i in seq_along(k_range)) {
  k      <- k_range[i]
  km     <- kmeans(embedding_pca, centers = k, nstart = 10, iter.max = 500)
  sil    <- silhouette(km$cluster, dist(embedding_pca[sample(nrow(embedding_pca),
                                                             min(2000, nrow(embedding_pca))), ]))
  silhouette_scores[i] <- mean(sil[, 3])
  message(sprintf("  k = %d: silhouette = %.4f", k, silhouette_scores[i]))
}

# Plot silhouette scores
dir.create("results", showWarnings = FALSE)

silhouette_df <- data.frame(k = k_range, score = silhouette_scores)

ggplot(silhouette_df, aes(x = k, y = score)) +
  geom_line(color = "steelblue", linewidth = 1.2) +
  geom_point(color = "steelblue", size = 2.5) +
  geom_vline(xintercept = n_clusters, color = "red", linetype = "dashed") +
  annotate("text", x = n_clusters + 0.5, y = max(silhouette_scores) * 0.98,
           label = paste0("Selected k = ", n_clusters), color = "red", hjust = 0) +
  labs(
    title    = "Silhouette Analysis for K-means Clustering",
    subtitle = "COVID-19 News Posts — Indian Media Platforms (2020–2022)",
    x        = "Number of Clusters (k)",
    y        = "Average Silhouette Score"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"))

ggsave("results/silhouette_analysis.png", width = 10, height = 6, dpi = 300)
message("Silhouette plot saved.")

# =============================================================================
# Step 4: K-means Clustering (k = 25)
# =============================================================================
message(sprintf("Running K-means with k = %d...", n_clusters))

set.seed(42)
kmeans_result <- kmeans(embedding_pca, centers = n_clusters,
                        nstart = 25, iter.max = 500)

data$cluster <- kmeans_result$cluster
message("K-means complete. Cluster sizes:")
print(table(data$cluster))

# =============================================================================
# Step 5: t-SNE 2D Reduction and Visualisation
# Thesis: "perplexity = 30, iterations = 1000" (p. 63)
# Implementation via R package Rtsne (Thesis p. 63)
# =============================================================================
message("Running t-SNE (this may take a few minutes)...")

tsne_result <- Rtsne(
  embedding_pca,
  dims        = 2,
  perplexity  = tsne_perplexity,
  max_iter    = tsne_iterations,
  check_duplicates = FALSE,
  verbose     = TRUE
)

data$tsne_x <- tsne_result$Y[, 1]
data$tsne_y <- tsne_result$Y[, 2]

message("t-SNE complete.")

# -------------------------------------------------------------------------
# t-SNE Cluster Plot (replicates Thesis Appendix C, Figure 1)
# -------------------------------------------------------------------------
ggplot(data, aes(x = tsne_x, y = tsne_y, color = factor(cluster))) +
  geom_point(alpha = 0.5, size = 0.8) +
  scale_color_manual(values = scales::hue_pal()(n_clusters)) +
  labs(
    title    = "t-SNE Visualisation of K-means Clusters",
    subtitle = "COVID-19 News Posts — Indian Media Platforms (2020–2022)",
    x        = "t-SNE Dimension 1",
    y        = "t-SNE Dimension 2",
    color    = "Cluster"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title      = element_text(face = "bold", size = 15),
    legend.position = "right",
    legend.text     = element_text(size = 7)
  ) +
  guides(color = guide_legend(override.aes = list(size = 3, alpha = 1)))

ggsave("results/tsne_kmeans_clusters.png", width = 14, height = 10, dpi = 300)
message("t-SNE plot saved to results/tsne_kmeans_clusters.png")

# Save clustered dataset (without large embedding column)
data_to_save <- data %>% select(-text_embedding)
write_csv(data_to_save, "results/clustered_posts.csv")
message("Clustered posts saved to results/clustered_posts.csv")
