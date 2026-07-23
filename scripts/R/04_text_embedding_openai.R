# =============================================================================
# Script 04: Text Embedding Generation Using OpenAI API
# Facebook Reactions COVID-19 India — Doctoral Thesis
# Author: Sawood Anwar | University of Urbino Carlo Bo
# Publication: Frontiers in Sociology, 2024 | DOI: 10.3389/fsoc.2024.1379265
#
# Model: text-embedding-3-large (OpenAI)
# Embedding dimension: 3072
# See Thesis Chapter 4, Section 4.3 (pp. 62-64) and Appendix C (pp. 202-217)
# =============================================================================
# Required packages:
#   install.packages(c("httr", "jsonlite", "dplyr", "readr", "logger"))
#
# Environment variables required (do NOT hardcode API keys):
#   OPENAI_UNIURB_ORG_ID           — your OpenAI organisation ID
#   OPENAI_VERA_PROJ_ID_API_KEY    — your OpenAI project API key
# =============================================================================

library(httr)
library(jsonlite)
library(dplyr)
library(readr)

# =============================================================================
# Configuration
# =============================================================================
config <- list(
  model             = "text-embedding-3-large",
  embedding_dim     = 3072,
  batch_size        = 100,
  retry_attempts    = 3,
  sleep_time        = 0.5,   # seconds between API calls
  rate_limit_per_min = 150
)

# Read credentials from environment variables
openai_org_id <- Sys.getenv("OPENAI_UNIURB_ORG_ID")
openai_api_key <- Sys.getenv("OPENAI_VERA_PROJ_ID_API_KEY")

if (nchar(openai_org_id) == 0 || nchar(openai_api_key) == 0) {
  stop("Missing required environment variables: OPENAI_UNIURB_ORG_ID and/or OPENAI_VERA_PROJ_ID_API_KEY")
}

# =============================================================================
# Get Embedding for a Single Text
# =============================================================================
get_embedding <- function(text) {
  for (attempt in seq_len(config$retry_attempts)) {
    response <- tryCatch({
      POST(
        url     = "https://api.openai.com/v1/embeddings",
        add_headers(
          "Authorization"       = paste("Bearer", openai_api_key),
          "OpenAI-Organization" = openai_org_id,
          "Content-Type"        = "application/json"
        ),
        body = toJSON(list(
          model = config$model,
          input = text
        ), auto_unbox = TRUE)
      )
    }, error = function(e) {
      message(sprintf("Attempt %d failed: %s", attempt, e$message))
      NULL
    })

    if (!is.null(response) && status_code(response) == 200) {
      content <- content(response, "parsed")
      return(content$data[[1]]$embedding)
    }

    Sys.sleep(attempt * config$sleep_time)
  }

  warning(sprintf("All %d attempts failed. Returning NA vector.", config$retry_attempts))
  return(rep(NA_real_, config$embedding_dim))
}

# =============================================================================
# Process All Texts in Batches
# =============================================================================
process_embeddings <- function(data, text_col = "text_to_embed") {

  if (!text_col %in% names(data)) {
    stop(sprintf("Column '%s' not found in data.", text_col))
  }

  # Remove duplicates and NA
  data <- data %>%
    filter(!is.na(.data[[text_col]]), nchar(.data[[text_col]]) > 0) %>%
    distinct(.data[[text_col]], .keep_all = TRUE)

  message(sprintf("Processing %d unique texts...", nrow(data)))

  n        <- nrow(data)
  all_embs <- vector("list", n)

  for (i in seq_len(n)) {
    text       <- data[[text_col]][i]
    all_embs[[i]] <- get_embedding(text)
    Sys.sleep(config$sleep_time)

    if (i %% 50 == 0) {
      message(sprintf("Progress: %d / %d texts embedded", i, n))
    }
  }

  data$text_embedding <- all_embs
  return(data)
}

# =============================================================================
# Main Execution
# =============================================================================
filepath <- ".data/sawood.rds"

if (!file.exists(filepath)) {
  stop(sprintf("Input file not found: %s", filepath))
}

data <- readRDS(filepath)
message("Data loaded: ", nrow(data), " rows")

# Generate embeddings
data_with_embeddings <- process_embeddings(data, text_col = "text_to_embed")

# Save results
dir.create(".processed_data", showWarnings = FALSE)
saveRDS(data_with_embeddings, ".processed_data/sawood_embedded.rds")
message("Embeddings saved to .processed_data/sawood_embedded.rds")

# Validation summary
n_na <- sum(sapply(data_with_embeddings$text_embedding, function(e) any(is.na(e))))
message(sprintf("Complete: %d embeddings OK, %d failed",
                nrow(data_with_embeddings) - n_na, n_na))
