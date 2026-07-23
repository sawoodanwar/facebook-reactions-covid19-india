"""
=============================================================================
Script: Text Embedding Generation Using OpenAI API
Facebook Reactions COVID-19 India — Doctoral Thesis
Author: Sawood Anwar | University of Urbino Carlo Bo
Publication: Frontiers in Sociology, 2024 | DOI: 10.3389/fsoc.2024.1379265

Model: text-embedding-3-large (OpenAI)
Embedding dimension: 3072
See Thesis Chapter 4, Section 4.3 (pp. 62-64) and Appendix C (pp. 202-217)
=============================================================================

Required packages:
    pip install openai dplyr pandas loguru tqdm

Environment variables required (do NOT hardcode API keys):
    OPENAI_UNIURB_ORG_ID  — your OpenAI organisation ID
    OPENAI_VERA_PROJ_ID_API_KEY — your OpenAI project API key
"""

import os
import time
import pickle
import numpy as np
import pandas as pd
from pathlib import Path
from tqdm import tqdm
from loguru import logger
from openai import OpenAI

# =============================================================================
# Configuration
# =============================================================================
config = {
    "retry_attempts":      3,
    "sleep_time":          0.5,    # seconds between API calls
    "batch_size":          100,    # texts per batch
    "embedding_dim":       3072,   # text-embedding-3-large output dimension
    "model":               "text-embedding-3-large",
    "rate_limit_per_min": 150,
}

# Logging setup
log_dir = Path(".logs")
log_dir.mkdir(exist_ok=True)
logger.add(log_dir / "embedding_{time}.log", rotation="1 day")

# OpenAI client (reads credentials from environment variables)
client = OpenAI(
    organization=os.environ.get("OPENAI_UNIURB_ORG_ID"),
    api_key=os.environ.get("OPENAI_VERA_PROJ_ID_API_KEY"),
)

# Rate limiting state
_call_times: list = []


# =============================================================================
# Rate Limiting
# =============================================================================
def enforce_rate_limit():
    global _call_times
    current_time = time.time()
    _call_times = [t for t in _call_times if current_time - t < 60]
    if len(_call_times) >= config["rate_limit_per_min"]:
        wait_time = 60 - (current_time - min(_call_times))
        if wait_time > 0:
            logger.info(f"Rate limit approaching, waiting {wait_time:.2f} seconds")
            time.sleep(wait_time)
    _call_times.append(time.time())


# =============================================================================
# Embedding with Retry Logic
# =============================================================================
def get_embeddings(text: str) -> list[float]:
    enforce_rate_limit()
    for attempt in range(1, config["retry_attempts"] + 1):
        try:
            result = client.embeddings.create(
                model=config["model"],
                input=text,
            )
            logger.info(f"Successfully got embedding for text: {text[:30]}...")
            return result.data[0].embedding
        except Exception as e:
            logger.error(f"Attempt {attempt} failed: {e}")
            if attempt == config["retry_attempts"]:
                logger.error("All retry attempts exhausted")
                return None
            time.sleep(attempt * config["sleep_time"])  # exponential backoff
    return [np.nan] * config["embedding_dim"]


# =============================================================================
# Batch Processing
# =============================================================================
def process_batch(texts: list[str]) -> list:
    embeddings = [None] * len(texts)
    for i, text in enumerate(texts):
        if not text or pd.isna(text):
            logger.warning(f"Empty or NA text at index {i}")
            embeddings[i] = [np.nan] * config["embedding_dim"]
            continue
        embeddings[i] = get_embeddings(text)
        time.sleep(config["sleep_time"])
    return embeddings


# =============================================================================
# Process a Single RDS/Pickle File
# =============================================================================
def process_single_file(filepath: str) -> pd.DataFrame:
    logger.info(f"Starting to process file: {filepath}")

    output_dir = Path(".processed_data")
    output_dir.mkdir(exist_ok=True)

    # Load data (supports pickle/RDS-exported CSV)
    try:
        if filepath.endswith(".pkl"):
            data = pd.read_pickle(filepath)
        else:
            data = pd.read_csv(filepath)
    except Exception as e:
        logger.error(f"Error loading file: {e}")
        raise

    if "text_to_embed" not in data.columns:
        raise ValueError("File does not contain 'text_to_embed' column")

    # Remove duplicates and NA
    data = data.drop_duplicates(subset="text_to_embed").dropna(subset=["text_to_embed"])
    logger.info(f"Processing {len(data)} unique texts")

    # Process in batches with progress bar
    total_batches = int(np.ceil(len(data) / config["batch_size"]))
    all_embeddings = []

    for batch_idx in tqdm(range(0, len(data), config["batch_size"]),
                          total=total_batches, desc="Embedding batches"):
        batch_end   = min(batch_idx + config["batch_size"], len(data))
        batch_texts = data["text_to_embed"].iloc[batch_idx:batch_end].tolist()
        batch_embs  = process_batch(batch_texts)
        all_embeddings.extend(batch_embs)

    data["text_embedding"] = all_embeddings

    # Save results
    output_file = output_dir / Path(filepath).name
    data.to_pickle(str(output_file))
    logger.info(f"Saved processed data to {output_file}")

    # Validation
    na_count = sum(1 for e in all_embeddings if e is None or (isinstance(e, list) and np.isnan(e[0])))
    logger.info(f"Processing complete. {len(data) - na_count} embeddings created, {na_count} failed")

    return data


# =============================================================================
# Main Execution
# =============================================================================
def main():
    logger.info("Starting embedding generation process")

    required_env_vars = ["OPENAI_UNIURB_ORG_ID", "OPENAI_VERA_PROJ_ID_API_KEY"]
    missing_vars = [v for v in required_env_vars if not os.environ.get(v)]
    if missing_vars:
        raise EnvironmentError(f"Missing required environment variables: {', '.join(missing_vars)}")

    filepath = ".data/sawood.rds"
    if not os.path.exists(filepath):
        raise FileNotFoundError(f"Input file not found: {filepath}")

    result = process_single_file(filepath)
    logger.info("Process completed successfully")
    return result


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        logger.error(f"Process failed: {e}")
        raise
