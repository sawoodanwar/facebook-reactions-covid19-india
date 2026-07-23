# =============================================================================
# Script 04: Text Embedding Generation Using OpenAI API
# Facebook Reactions COVID-19 India — Doctoral Thesis
# Author: Sawood Anwar | University of Urbino Carlo Bo
# Publication: Frontiers in Sociology, 2024 | DOI: 10.3389/fsoc.2024.1379265
#
# Model: text-embedding-3-large (OpenAI)
# Embedding dimension: 3072
# Source: Thesis Appendix C (pp. 202–217) — verbatim R code
# =============================================================================
# Required packages (Thesis Appendix C, p. 210)
library(dplyr)    # Data manipulation
library(readr)    # Data reading/writing
library(stringr)  # String manipulation
library(openai)   # OpenAI API interface  <-- NOTE: uses {openai} R package
library(logger)   # Logging functionality
library(tidyr)    # Data tidying

# =============================================================================
# Configuration Settings (Thesis Appendix C, pp. 210–212)
# =============================================================================
config <- list(
  retry_attempts     = 3,           # Number of API retry attempts
  sleep_time         = 0.5,         # Delay between API calls (seconds)
  batch_size         = 100,         # Number of texts per batch
  embedding_dim      = 3072,        # Embedding vector dimension
  model              = "text-embedding-3-large",
  rate_limit_per_minute = 150       # API rate limit
)

# =============================================================================
# Rate Limiting Implementation (Thesis Appendix C, pp. 203–204, 212)
# =============================================================================
last_call_time <- Sys.time()
call_times     <- numeric()

enforce_rate_limit <- function() {
  current_time <- Sys.time()
  # Remove calls older than 1 minute
  call_times <<- call_times[call_times > current_time - 60]
  # If near rate limit, wait
  if (length(call_times) >= config$rate_limit_per_minute) {
    wait_time <- 60 - as.numeric(difftime(current_time, min(call_times), units = "secs"))
    if (wait_time > 0) {
      log_info(sprintf("Rate limit approaching, waiting %.2f seconds", wait_time))
      Sys.sleep(wait_time)
    }
  }
  # Record this call
  call_times <<- c(call_times, current_time)
}

# =============================================================================
# Embedding Generation with Retry Logic (Thesis Appendix C, pp. 204–207)
# Uses {openai} R package: openai::create_embedding()
# =============================================================================
get_embeddings <- function(text, config) {
  enforce_rate_limit()
  for (attempt in 1:config$retry_attempts) {
    result <- tryCatch(
      openai::create_embedding(
        model              = config$model,
        input              = text,
        openai_organization = Sys.getenv("OPENAI_UNIURB_ORG_ID"),
        openai_api_key      = Sys.getenv("OPENAI_VERA_PROJ_ID_API_KEY")
      ),
      error = function(e) {
        log_error(sprintf("Attempt %d failed: %s", attempt, e$message))
        if (attempt == config$retry_attempts) {
          log_error("All retry attempts exhausted")
          return(NULL)
        }
        Sys.sleep(attempt * config$sleep_time)  # exponential backoff
        NULL
      }
    )
    if (!is.null(result) && !is.null(result$data$embedding)) {
      log_info(sprintf("Successfully got embedding for text: %s...",
                       substr(text, 1, 30)))
      return(result$data$embedding)
    }
  }
  return(rep(NA_real_, config$embedding_dim))
}

# =============================================================================
# Batch Processing (Thesis Appendix C, pp. 207–208, 213–214)
# =============================================================================
process_batch <- function(texts, config) {
  embeddings <- vector("list", length(texts))
  for (i in seq_along(texts)) {
    if (is.na(texts[i]) || nchar(texts[i]) == 0) {
      log_warn(sprintf("Empty or NA text at index %d", i))
      embeddings[[i]] <- rep(NA_real_, config$embedding_dim)
      next
    }
    embeddings[[i]] <- get_embeddings(texts[i], config)
    Sys.sleep(config$sleep_time)
  }
  return(embeddings)
}

# =============================================================================
# Process a Single RDS File (Thesis Appendix C, pp. 208–209, 215–216)
# =============================================================================
process_single_file <- function(filepath, config) {
  log_info(sprintf("Starting to process file: %s", filepath))

  # Create output directory if it doesn't exist
  output_dir <- ".processed_data"
  if (!dir.exists(output_dir)) dir.create(output_dir)

  # Load and validate data
  tryCatch(
    data <- readRDS(filepath),
    error = function(e) {
      log_error(sprintf("Error loading file: %s", e$message))
      stop(e)
    }
  )

  if (!"text_to_embed" %in% colnames(data)) {
    stop("File does not contain 'text_to_embed' column")
  }

  # Remove duplicates and NA values (Thesis Appendix C, p. 207)
  data <- data %>%
    distinct(text_to_embed, .keep_all = TRUE) %>%
    filter(!is.na(text_to_embed))

  log_info(sprintf("Processing %d unique texts", nrow(data)))

  # Process in batches with progress bar (Thesis Appendix C, pp. 207–209)
  total_batches <- ceiling(nrow(data) / config$batch_size)
  pb            <- txtProgressBar(min = 0, max = total_batches, style = 3)

  for (batch_idx in seq(1, nrow(data), by = config$batch_size)) {
    batch_end    <- min(batch_idx + config$batch_size - 1, nrow(data))
    batch_texts  <- data$text_to_embed[batch_idx:batch_end]
    embeddings   <- process_batch(batch_texts, config)
    data$text_embedding[batch_idx:batch_end] <- embeddings
    setTxtProgressBar(pb, ceiling(batch_idx / config$batch_size))
  }
  close(pb)

  # Save results (Thesis Appendix C, p. 209)
  output_file <- file.path(output_dir, basename(filepath))
  saveRDS(data, file = output_file)
  log_info(sprintf("Saved processed data to: %s", output_file))

  # Basic validation
  embedding_lengths <- sapply(data$text_embedding, length)
  na_count          <- sum(is.na(embedding_lengths))
  log_info(sprintf("Processing complete. %d embeddings created, %d failed",
                   nrow(data) - na_count, na_count))
  return(data)
}

# =============================================================================
# Main Execution (Thesis Appendix C, pp. 209–211)
# =============================================================================
main <- function() {
  log_info("Starting embedding generation process")

  # Set up environment variables (Thesis Appendix C, p. 215)
  # Sys.setenv(OPENAI_UNIURB_ORG_ID = "org-id")
  # Sys.setenv(OPENAI_VERA_PROJ_ID_API_KEY = "api-key")

  # Check for environment variables
  required_env_vars <- c("OPENAI_UNIURB_ORG_ID", "OPENAI_VERA_PROJ_ID_API_KEY")
  missing_vars      <- required_env_vars[!nzchar(Sys.getenv(required_env_vars))]
  if (length(missing_vars) > 0) {
    stop(sprintf("Missing required environment variables: %s",
                 paste(missing_vars, collapse = ", ")))
  }

  # Process file
  filepath <- ".data/sawood.rds"
  if (!file.exists(filepath)) {
    stop(sprintf("Input file not found: %s", filepath))
  }

  processed_data <- process_single_file(filepath, config)
  log_info("Process completed successfully")
  return(processed_data)
}

# Run the main function
tryCatch(
  result <- main(),
  error = function(e) {
    log_error(sprintf("Process failed: %s", e$message))
    stop(e)
  }
)
