"""
=============================================================================
Script: K-means Clustering + PCA + t-SNE Visualisation
Facebook Reactions COVID-19 India — Doctoral Thesis
Author: Sawood Anwar | University of Urbino Carlo Bo
Publication: Frontiers in Sociology, 2024 | DOI: 10.3389/fsoc.2024.1379265

Pipeline:
  1. Load embeddings (output of 01_text_embedding_openai.py)
  2. PCA dimensionality reduction (8096-dim → manageable)
  3. K-means clustering (k=25, selected via silhouette analysis)
  4. t-SNE 2D visualisation (perplexity=30, iterations=1000)
  5. Save cluster assignments + plot

See Thesis Chapter 4, Sections 4.3.2–4.3.3 (pp. 63–64) and Appendix C
=============================================================================

Required packages:
    pip install numpy pandas scikit-learn matplotlib seaborn tqdm loguru
"""

import os
import pickle
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import seaborn as sns
from pathlib import Path
from tqdm import tqdm
from loguru import logger
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
from sklearn.manifold import TSNE
from sklearn.metrics import silhouette_score, silhouette_samples
from sklearn.preprocessing import StandardScaler

# =============================================================================
# Configuration (mirrors Thesis Section 4.3.2–4.3.3)
# =============================================================================
config = {
    "n_clusters":        25,     # Final k from silhouette analysis
    "pca_components":    100,    # PCA reduction before K-means (large matrix)
    "tsne_perplexity":   30,     # t-SNE perplexity (Thesis p. 63)
    "tsne_iterations":   1000,   # t-SNE iterations (Thesis p. 63)
    "tsne_components":   2,      # 2D output for visualisation
    "random_state":      42,
    "k_range":           range(5, 35),  # Range tested in silhouette analysis
}

# Logging
log_dir = Path(".logs")
log_dir.mkdir(exist_ok=True)
logger.add(log_dir / "clustering_{time}.log", rotation="1 day")


# =============================================================================
# Step 1: Load Embeddings
# =============================================================================
def load_embeddings(filepath: str) -> tuple[np.ndarray, pd.DataFrame]:
    logger.info(f"Loading embeddings from {filepath}")
    if filepath.endswith(".pkl"):
        data = pd.read_pickle(filepath)
    else:
        data = pd.read_csv(filepath)

    # Extract embedding matrix
    embeddings = np.vstack(data["text_embedding"].values)

    # Remove rows with NaN embeddings
    valid_mask = ~np.isnan(embeddings).any(axis=1)
    embeddings = embeddings[valid_mask]
    data = data[valid_mask].reset_index(drop=True)

    logger.info(f"Loaded {len(data)} valid embeddings of dimension {embeddings.shape[1]}")
    return embeddings, data


# =============================================================================
# Step 2: PCA Reduction
# Thesis: "we run the Principal Component Analysis PCA setting for
# large matrices of 8096 data" (p. 63)
# =============================================================================
def reduce_with_pca(embeddings: np.ndarray, n_components: int) -> np.ndarray:
    logger.info(f"Running PCA: {embeddings.shape[1]}D → {n_components}D")
    scaler = StandardScaler()
    embeddings_scaled = scaler.fit_transform(embeddings)
    pca = PCA(n_components=n_components, random_state=config["random_state"])
    reduced = pca.fit_transform(embeddings_scaled)
    explained = pca.explained_variance_ratio_.sum() * 100
    logger.info(f"PCA complete. Explained variance: {explained:.2f}%")
    return reduced


# =============================================================================
# Step 3: Silhouette Analysis to Confirm Optimal k
# Thesis: "we employed the Silhouette analysis to find out how similar
# an objective is to other clusters" (p. 63) → k=25
# =============================================================================
def silhouette_analysis(embeddings_pca: np.ndarray) -> int:
    logger.info("Running silhouette analysis to determine optimal k...")
    silhouette_scores = {}

    for k in tqdm(config["k_range"], desc="Testing k values"):
        kmeans = KMeans(n_clusters=k, random_state=config["random_state"], n_init=10)
        labels = kmeans.fit_predict(embeddings_pca)
        score = silhouette_score(embeddings_pca, labels, sample_size=2000)
        silhouette_scores[k] = score
        logger.info(f"k={k}: silhouette score = {score:.4f}")

    # Plot silhouette scores
    output_dir = Path("results")
    output_dir.mkdir(exist_ok=True)

    plt.figure(figsize=(10, 6))
    plt.plot(list(silhouette_scores.keys()), list(silhouette_scores.values()),
             marker="o", color="steelblue", linewidth=2)
    plt.axvline(x=config["n_clusters"], color="red", linestyle="--",
                label=f"Selected k={config['n_clusters']}")
    plt.xlabel("Number of Clusters (k)", fontsize=13)
    plt.ylabel("Silhouette Score", fontsize=13)
    plt.title("Silhouette Analysis for K-means Clustering", fontsize=15, fontweight="bold")
    plt.legend()
    plt.tight_layout()
    plt.savefig(output_dir / "silhouette_analysis.png", dpi=300)
    plt.close()

    optimal_k = max(silhouette_scores, key=silhouette_scores.get)
    logger.info(f"Optimal k from silhouette analysis: {optimal_k}")
    return optimal_k


# =============================================================================
# Step 4: K-means Clustering
# =============================================================================
def run_kmeans(embeddings_pca: np.ndarray, n_clusters: int) -> np.ndarray:
    logger.info(f"Running K-means with k={n_clusters}")
    kmeans = KMeans(
        n_clusters=n_clusters,
        random_state=config["random_state"],
        n_init=10,
        max_iter=500,
    )
    labels = kmeans.fit_predict(embeddings_pca)
    final_score = silhouette_score(embeddings_pca, labels, sample_size=2000)
    logger.info(f"K-means complete. Final silhouette score: {final_score:.4f}")
    return labels


# =============================================================================
# Step 5: t-SNE 2D Reduction and Visualisation
# Thesis: "perplexity=30, iterations=1000" (p. 63)
# =============================================================================
def run_tsne_and_plot(embeddings_pca: np.ndarray, labels: np.ndarray,
                     data: pd.DataFrame) -> pd.DataFrame:
    logger.info("Running t-SNE dimensionality reduction...")
    tsne = TSNE(
        n_components=config["tsne_components"],
        perplexity=config["tsne_perplexity"],
        n_iter=config["tsne_iterations"],
        random_state=config["random_state"],
        verbose=1,
    )
    tsne_coords = tsne.fit_transform(embeddings_pca)
    logger.info("t-SNE complete")

    # Build result dataframe
    result_df = data.copy()
    result_df["cluster"]  = labels
    result_df["tsne_x"]   = tsne_coords[:, 0]
    result_df["tsne_y"]   = tsne_coords[:, 1]

    # -------------------------------------------------------------------------
    # t-SNE Cluster Plot (replicates Thesis Appendix C, Figure 1)
    # -------------------------------------------------------------------------
    output_dir = Path("results")
    output_dir.mkdir(exist_ok=True)

    n_clusters = len(np.unique(labels))
    palette    = sns.color_palette("tab20", n_clusters)

    plt.figure(figsize=(16, 12))
    for cluster_id in range(n_clusters):
        mask = result_df["cluster"] == cluster_id
        plt.scatter(
            result_df.loc[mask, "tsne_x"],
            result_df.loc[mask, "tsne_y"],
            c=[palette[cluster_id]],
            label=f"Cluster {cluster_id}",
            alpha=0.6,
            s=10,
        )

    plt.title(
        "t-SNE Visualisation of Text Embeddings with K-means Clusters\n"
        "COVID-19 News Posts — Indian Media Platforms (2020–2022)",
        fontsize=15, fontweight="bold",
    )
    plt.xlabel("t-SNE Dimension 1", fontsize=12)
    plt.ylabel("t-SNE Dimension 2", fontsize=12)
    plt.legend(loc="upper right", markerscale=2, fontsize=7, ncol=2,
               title="Cluster", title_fontsize=9)
    plt.tight_layout()
    plt.savefig(output_dir / "tsne_kmeans_clusters.png", dpi=300)
    plt.close()
    logger.info("t-SNE plot saved to results/tsne_kmeans_clusters.png")

    return result_df


# =============================================================================
# Main
# =============================================================================
def main():
    logger.info("=== K-means Clustering + t-SNE Pipeline ===")

    input_file = ".processed_data/sawood.rds"
    if not os.path.exists(input_file):
        raise FileNotFoundError(
            f"Embeddings file not found: {input_file}\n"
            "Please run 01_text_embedding_openai.py first."
        )

    # Load
    embeddings, data = load_embeddings(input_file)

    # PCA
    embeddings_pca = reduce_with_pca(embeddings, config["pca_components"])

    # Silhouette (optional — skip to use fixed k=25 from thesis)
    # optimal_k = silhouette_analysis(embeddings_pca)
    optimal_k = config["n_clusters"]

    # K-means
    labels = run_kmeans(embeddings_pca, optimal_k)

    # t-SNE + plot
    result_df = run_tsne_and_plot(embeddings_pca, labels, data)

    # Save clustered dataset
    output_dir = Path("results")
    output_dir.mkdir(exist_ok=True)
    result_df.drop(columns=["text_embedding"], errors="ignore").to_csv(
        output_dir / "clustered_posts.csv", index=False
    )
    logger.info("Clustered dataset saved to results/clustered_posts.csv")

    # Cluster size summary
    cluster_sizes = result_df["cluster"].value_counts().sort_index()
    logger.info("Cluster sizes:")
    for c, s in cluster_sizes.items():
        logger.info(f"  Cluster {c}: {s} posts")

    logger.info("Pipeline complete.")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        logger.error(f"Pipeline failed: {e}")
        raise
