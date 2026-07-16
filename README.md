# Facebook Reactions as Emotional Indicators
## A Multi-Method Approach to Analyzing User Engagement with COVID-19 News on Indian Media Platforms

[![Language: R](https://img.shields.io/badge/Language-R-276DC3?style=flat&logo=r&logoColor=white)](https://www.r-project.org/)
[![Language: Python](https://img.shields.io/badge/Language-Python-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org/)
[![Method: Mixed Methods](https://img.shields.io/badge/Method-Mixed%20Methods-blueviolet?style=flat)]()
[![Platform: Facebook](https://img.shields.io/badge/Platform-Facebook-1877F2?style=flat&logo=facebook&logoColor=white)]()
[![Topic: COVID-19](https://img.shields.io/badge/Topic-COVID--19-red?style=flat)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PhD Thesis](https://img.shields.io/badge/Type-PhD%20Thesis-darkgreen?style=flat)]()

---

> **PhD Thesis Project** — University of Urbino Carlo Bo
> Department of Communication Sciences, Humanities and International Studies (DISCUI)
> PhD Programme in Humanities | Curriculum: Text and Communication Sciences | Cycle XXXVII
> **Author:** Sawood Anwar | **Supervisor:** Prof. Fabio Giglietto | **Co-Supervisor:** Prof. Giovanni Boccia Artieri
> **Defended:** 22 September 2025 | Academic Year 2023/2024

---

## 📌 Overview

This project investigates the role of **Facebook Reactions** (Like, Love, Haha, Wow, Sad, Angry) as indicators of public sentiment and emotional engagement with **COVID-19 pandemic-related news** in India. The study covers the period from **March 24, 2020 to March 31, 2022**, analyzing data from four major English-language Indian news outlets across **68,319 Facebook posts**.

---

## 🔗 Related Projects

| Repository | Description |
|---|---|
| ⏱️ [timeseries-facebook-engagement-r](https://github.com/sawoodanwar/timeseries-facebook-engagement-r) | Time-series toolkit: general, COVID-19 extension & misinfo spike detection |
| 🧠 [stm-social-media-r](https://github.com/sawoodanwar/stm-social-media-r) | STM topic modeling toolkit for social media text in R |
| 🦠 [bertopic-media-topics](https://github.com/sawoodanwar/bertopic-media-topics) | Embedding-based BERTopic pipeline (Python + R) |
| 💬 [sentiment-lexicon-comparison](https://github.com/sawoodanwar/sentiment-lexicon-comparison) | AFINN, Bing, NRC lexicon comparison in R |
| 📊 [meta-content-analysis](https://github.com/sawoodanwar/meta-content-analysis) | Facebook & Instagram health misinformation analysis |
| 🗾️ [reddit-political-misinfo-coding](https://github.com/sawoodanwar/reddit-political-misinfo-coding) | Reddit political communication manual coding project |
| 🔄 [cross-platform-engagement-analysis](https://github.com/sawoodanwar/cross-platform-engagement-analysis) | Unified cross-platform engagement framework (FB, IG, Reddit) |
| 🔴 [disinformation-detection-ml](https://github.com/sawoodanwar/disinformation-detection-ml) | ML classifier for disinformation detection in news posts |
| 🟣 [nlp-news-classification-r](https://github.com/sawoodanwar/nlp-news-classification-r) | Supervised NLP news classification by topic & credibility |
| 🟢 [crowdtangle-meta-api-workflow](https://github.com/sawoodanwar/crowdtangle-meta-api-workflow) | Academic data collection pipeline: CrowdTangle & Meta API |

---

## 🎯 Research Questions

1. What were the prominent themes/topics of news coverage during the early stages of the COVID-19 pandemic in India?
2. Is there any relationship between user sentiments across different news outlets?
3. Do different news outlets show variations in user sentiment and engagement for the same COVID-19 topics?
4. How did user sentiment and engagement vary across news outlets over time?

---

## 📊 Dataset

| Parameter | Details |
|---|---|
| **Platform** | Facebook (via CrowdTangle) |
| **Total Posts** | 68,319 Facebook posts |
| **Early-Stage Subset** | 8,622 posts (March 24 – April 14, 2020) |
| **Study Period** | March 24, 2020 – March 31, 2022 |
| **Language** | English |
| **News Outlets** | The Times of India, The Hindu, The Indian Express, Hindustan Times |

> ⚠️ **Note:** Raw data is not publicly shared in compliance with Meta/CrowdTangle data usage policies. Sample/anonymized data may be available upon request for academic purposes.

---

## 🔬 Methodology

This study employs a **mixed-methods approach** combining four analytical techniques:

### 1. 📈 Time-Series Analysis
- Percentage Change Method
- Z-score Method with Rolling Statistics
- Identifies unusual engagement spikes and anomalous days across the full study period
- Detected **48 unusual days** with significant variation in Facebook Reactions

### 2. 🧠 Embedding-Based Topic Modeling
- OpenAI API-based text embeddings (superior clustering performance vs. BERT on MTEB benchmarks)
- K-means clustering for grouping semantically similar posts
- UMAP dimensionality reduction for 2-D visualization
- Identified **25 distinct thematic clusters** in COVID-19 news coverage

### 3. 🤖 LLM-Assisted Cluster Labeling
- Novel application of GPT-4 API for automated, interpretable cluster label generation
- Top terms and representative documents per cluster passed as structured prompts
- Enhances scalability and semantic coherence of large-scale social media topic analysis

### 4. 💬 Lexicon-Based Sentiment Analysis
- `sentimentr` package in R (Rinker, 2015–2024)
- Accounts for valence shifters and mixed sentiments within sentences
- Correlates news article sentiment scores with observed Facebook Reaction patterns

---

## 📂 Repository Structure

```
facebook-reactions-covid19-india/
├── scripts/
│   ├── R/                        # R scripts (time-series, sentimentr analysis)
│   └── python/                   # Python scripts (embeddings, K-means, GPT-4 labeling)
├── notebooks/                    # Jupyter / R Markdown exploratory notebooks
├── data/
│   └── sample/                   # Anonymized or sample data (if available)
├── results/
│   ├── figures/                  # Visualizations and plots
│   └── tables/                   # Summary statistics and topic tables
├── docs/                         # Additional documentation
├── requirements.txt              # Python dependencies
├── packages.R                    # R package dependencies
└── README.md
```

---

## 🔑 Key Findings

- **48 unusual days** with significant variations in Facebook Reactions identified across the full study period
- **25 thematic clusters** detected in COVID-19 news coverage — from lockdown enforcement to global political responses
- **Positive reactions** (Love, Haha) associated with community support and celebrity engagement clusters
- **Negative reactions** (Angry, Sad) linked to crisis impact and enforcement-related clusters
- **Moderate positive correlation** (r = 0.37) between news article sentiment and user reactions
- *The Times of India* achieved highest overall engagement; *The Hindu* showed the most positive sentiment scores
- Evidence of **rage-baiting content** around communal politics and China-related posts

---

## 🛠️ Tech Stack

| Tool / Library | Purpose |
|---|---|
| `R` + `sentimentr` | Lexicon-based, valence-aware sentiment analysis |
| `Python` | Embeddings, clustering, GPT-4 API calls |
| `OpenAI API` | Text embeddings + GPT-4 cluster label generation |
| `K-means` | Semantic post clustering |
| `UMAP` | Dimensionality reduction for visualization |
| `CrowdTangle` | Facebook data collection |
| `ggplot2` | Visualizations in R |
| `Pandas` / `NumPy` | Data processing in Python |

---

## 💻 Getting Started

### R Dependencies

```r
source("packages.R")  # installs all required R packages
```

### Python Dependencies

```bash
pip install -r requirements.txt
```

### Run Order

```
1. scripts/python/01_embeddings.py       — embed texts via OpenAI API
2. scripts/python/02_clustering.py       — K-means + UMAP clustering
3. scripts/python/03_llm_labeling.py     — GPT-4 cluster label generation
4. scripts/R/04_timeseries.R             — Z-score and rolling stats on reactions
5. scripts/R/05_sentiment_analysis.R     — sentimentr lexicon-based scoring
6. scripts/R/06_visualization.R          — all publication plots
```

---

## 📖 Citation

```bibtex
@phdthesis{anwar2025facebook,
  title     = {``Facebook Reactions'' as Emotional Indicators: A Multi-Method Approach
               to Analyzing User Engagement with COVID-19 News on Indian Media Platforms},
  author    = {Anwar, Sawood},
  year      = {2025},
  school    = {University of Urbino Carlo Bo},
  type      = {PhD Thesis},
  note      = {Supervisor: Prof. Fabio Giglietto; Co-Supervisor: Prof. Giovanni Boccia Artieri;
               Defended: 22 September 2025; Cycle XXXVII}
}
```

---

## 📚 Related Publication

Anwar, S. & Giglietto, F. (2024). **Facebook Reactions as Emotional Indicators: Analyzing Public Engagement with COVID-19 Pandemic News on Indian Media Platforms During the Early Lockdown Phase.** *Frontiers in Sociology*, 9, 1379265. https://doi.org/10.3389/fsoc.2024.1379265

---

## 📬 Contact

**Sawood Anwar** — PhD in Humanities (Text and Communication Sciences)
University of Urbino Carlo Bo, Italy

[![GitHub](https://img.shields.io/badge/GitHub-sawoodanwar-181717?style=flat&logo=github)](https://github.com/sawoodanwar)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-sawood--anwar-0A66C2?style=flat&logo=linkedin)](https://www.linkedin.com/in/sawood-anwar/)
[![Google Scholar](https://img.shields.io/badge/Google%20Scholar-Sawood%20Anwar-4285F4?style=flat&logo=googlescholar&logoColor=white)](https://scholar.google.com/citations?user=Z2kACpkAAAAJ&hl=en)
[![ORCID](https://img.shields.io/badge/ORCID-0009--0000--2819--9179-A6CE39?style=flat&logo=orcid&logoColor=white)](https://orcid.org/0009-0000-2819-9179)

---

## 📝 License

This project is licensed under the [MIT License](LICENSE).

---

*Keywords: Facebook Reactions, COVID-19, Sentiment Analysis, Topic Modeling, Embedding-Based Clustering, GPT-4, UMAP, K-means, Social Media Engagement, Indian News Media, Crisis Communication, NLP, Computational Communication, CrowdTangle*
