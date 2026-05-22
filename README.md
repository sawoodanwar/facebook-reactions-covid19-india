# Facebook Reactions as Emotional Indicators
## A Multi-Method Approach to Analyzing User Engagement with COVID-19 News on Indian Media Platforms

---

> **PhD Thesis Project** — University of Urbino Carlo Bo  
> Department of Communication Sciences, Humanities and International Studies  
> PhD Programme in Humanities | Curriculum: Text and Communication Sciences | Cycle XXXVII  
> **Author:** Sawood Anwar | **Supervisor:** Prof. Fabio Giglietto | **Co-Supervisor:** Prof. Giovanni Boccia Artieri  
> Academic Year 2023/2024

---

## 📌 Overview

This project investigates the role of **Facebook Reactions** (Love, Haha, Wow, Sad, Angry) as indicators of public sentiment and emotional engagement with **COVID-19 pandemic-related news** in India. The study covers the period from **March 24, 2020 to March 31, 2022**, analyzing data from four major English-language Indian news outlets.

---

## 🎯 Research Questions

1. What were the prominent themes/topics of news coverage during the early stages of the COVID-19 pandemic in India?
2. Is there any relationship between user sentiments across different news outlets?
3. Do different news outlets show variations in user sentiment and engagement for the same COVID-19 topics?
4. How did user sentiment and engagement vary across news outlets?

---

## 📊 Dataset

| Parameter | Details |
|---|---|
| **Platform** | Facebook (via CrowdTangle) |
| **Total Posts** | 68,319 Facebook posts |
| **Early-Stage Subset** | 8,622 posts (March 24 – April 14, 2020) |
| **Study Period** | March 24, 2020 – March 31, 2022 |
| **Language** | English |
| **News Outlets** | The Times of India, The Hindu, Indian Express, Hindustan Times |

> ⚠️ **Note:** Raw data is not publicly shared in compliance with Meta/CrowdTangle data usage policies. Sample/anonymized data may be available upon request for academic purposes.

---

## 🔬 Methodology

This study employs a **mixed-methods approach** combining four analytical techniques:

### 1. 📈 Time-Series Analysis
- Percentage Change Method
- Z-score Method with Rolling Statistics
- Identifies unusual engagement spikes and anomalous days

### 2. 🧠 Embedding-Based Topic Modeling
- OpenAI API-based text embeddings (superior clustering performance vs. BERT on MTEB benchmarks)
- K-means clustering for grouping similar posts
- UMAP dimensionality reduction for 2D visualization
- Identified **25 distinct thematic clusters** in COVID-19 news coverage

### 3. 🤖 GPT-4-Assisted Cluster Labeling
- Novel use of GPT-4 API for automated, interpretable cluster label generation
- Enhances scalability and coherence of large-scale social media topic analysis

### 4. 💬 Lexicon-Based Sentiment Analysis
- `sentimentr` package in R (Rinker, 2015–2024)
- Accounts for valence shifters and mixed sentiments
- Correlates news sentiment scores with Facebook Reaction patterns

---

## 📂 Repository Structure

```
📦 facebook-reactions-covid19-india
├── 📁 notebooks/          # Jupyter notebooks for exploratory analysis
├── 📁 scripts/
│   ├── 📁 R/               # R scripts (time-series, sentimentr)
│   └── 📁 python/         # Python scripts (embeddings, clustering, GPT-4 labeling)
├── 📁 data/
│   └── sample/            # Anonymized/sample data (if available)
├── 📁 results/
│   ├── figures/           # Visualizations and plots
│   └── tables/            # Summary tables and statistics
├── 📁 docs/               # Additional documentation
├── requirements.txt       # Python dependencies
├── packages.R             # R package dependencies
└── README.md
```

---

## 🔑 Key Findings

- **48 unusual days** with significant variations in Facebook Reactions identified during the study period
- **25 thematic clusters** detected in COVID-19 news coverage, ranging from lockdown enforcement to global political responses
- **Positive reactions** (Love, Haha) associated with community support and celebrity engagement clusters
- **Negative reactions** (Angry, Sad) linked to crisis impact and enforcement-related clusters
- **Moderate positive correlation** (r = 0.37) between news sentiment and user reactions
- *The Times of India* achieved highest overall engagement; *The Hindu* showed the most positive sentiment scores
- Evidence of **rage-baiting content** around communal politics and China-related posts

---

## 🛠️ Tech Stack

| Tool/Library | Purpose |
|---|---|
| `R` + `sentimentr` | Lexicon-based sentiment analysis |
| `Python` | Embeddings, clustering, GPT-4 API calls |
| `OpenAI API` | Text embeddings + GPT-4 cluster labeling |
| `K-means` | Post clustering |
| `UMAP` | Dimensionality reduction |
| `CrowdTangle` | Facebook data collection |
| `ggplot2` | Visualizations in R |
| `Pandas / NumPy` | Data processing |

---

## 📖 Citation

If you use ideas, methodology, or findings from this work, please cite:

```bibtex
@phdthesis{anwar2024facebook,
  title     = {Facebook Reactions as Emotional Indicators: A Multi-Method Approach 
               to Analyzing User Engagement with COVID-19 News on Indian Media Platforms},
  author    = {Anwar, Sawood},
  year      = {2024},
  school    = {University of Urbino Carlo Bo},
  type      = {PhD Thesis},
  note      = {Supervisor: Prof. Fabio Giglietto; Co-Supervisor: Prof. Giovanni Boccia Artieri}
}
```

---

## 🔗 Related Publication

- Anwar, S. & Giglietto, F. (2024). *(See published work for full reference)*

---

## 📬 Contact

**Sawood Anwar**  
PhD in Humanities (Text and Communication Sciences)  
University of Urbino Carlo Bo, Italy  
🔗 [GitHub](https://github.com/sawoodanwar)

---

## 📝 License

This project is licensed under the [MIT License](LICENSE).

---

*Keywords: Facebook Reactions, COVID-19, Sentiment Analysis, Topic Modeling, Social Media Engagement, Indian News Media, Crisis Communication, NLP, GPT-4, Embedding-based Clustering*
