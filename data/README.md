# Data Dictionary

This folder holds the CrowdTangle exports used in the doctoral thesis.  
Raw data files are **not redistributed** due to Meta's CrowdTangle and Content Library data-use agreements.

---

## Data Sources

| Parameter        | Value |
|---|---|
| **Tool**         | CrowdTangle (Meta) — Historical Data & Search feature |
| **Platform**     | Facebook Pages |
| **Keyword**      | `COVID-19` (+ synonyms with Boolean operators) |
| **Account Type** | Pages |
| **Post Type**    | All Posts |
| **Language**     | English |
| **Full corpus**  | March 24, 2020 – March 31, 2022 → **68,319 posts** |
| **Early subset** | March 24, 2020 – April 14, 2020 (22 days) → **8,622 posts** |

### News Outlets Included

| Outlet | Facebook Followers (at time of study) |
|---|---|
| The Times of India | 11 million |
| Indian Express | 7.5 million |
| Hindustan Times | 7.2 million |
| The Hindu | 5.3 million |

---

## CrowdTangle Column Schema

The table below documents the key columns in the exported CSV files.

| Column Name | Type | Description |
|---|---|---|
| `Facebook Id` | string | Unique Facebook post identifier |
| `Post Created` | datetime | Full timestamp of post creation (UTC) |
| `Post Created Date` | date | Date portion of `Post Created` (YYYY-MM-DD) |
| `Post Created Time` | time | Time portion of `Post Created` |
| `Type` | string | Post type: `Link`, `Photo`, `Video`, `Status` |
| `Title` | string | Headline or title of the linked article |
| `Description` | string | Short description or subtitle |
| `message` | string | Body text of the Facebook post |
| `link` | string | URL of the shared news article |
| `account.name` | string | News outlet name (page name) |
| `account.id` | string | Facebook Page ID |
| `account.handle` | string | Facebook Page handle |
| `statistics.actual.likeCount` | integer | Number of Like reactions |
| `statistics.actual.loveCount` | integer | Number of Love reactions |
| `statistics.actual.wowCount` | integer | Number of Wow reactions |
| `statistics.actual.hahaCount` | integer | Number of Haha reactions |
| `statistics.actual.sadCount` | integer | Number of Sad reactions |
| `statistics.actual.angryCount` | integer | Number of Angry reactions |
| `statistics.actual.careCount` | integer | Number of Care reactions (added by Facebook during COVID-19) |
| `statistics.actual.commentCount` | integer | Number of comments |
| `statistics.actual.shareCount` | integer | Number of shares |
| `statistics.actual.totalInteractionCount` | integer | Sum of all reactions + comments + shares |

---

## Derived Variables (created during analysis)

| Variable | Script | Description |
|---|---|---|
| `Date` | `01_data_import_preprocessing.R` | Date column cast from `Post Created Date` |
| `user_reaction` | `03_sentiment_analysis.R` | Aggregate engagement score: Love + Wow + Haha − Sad − Angry |
| `sentiment_score` | `03_sentiment_analysis.R` | Sentence-level sentiment via `sentimentr` (Rinker, 2015–2024) |
| `rolling_mean` | `02_timeseries_anomaly_detection.R` | 7-day rolling mean of reaction counts |
| `rolling_sd` | `02_timeseries_anomaly_detection.R` | 7-day rolling standard deviation |
| `z_score` | `02_timeseries_anomaly_detection.R` | Z-score relative to 7-day rolling statistics |
| `pct_change` | `02_timeseries_anomaly_detection.R` | Day-on-day percentage change in reaction counts |
| `unusual` | `02_timeseries_anomaly_detection.R` | Boolean: TRUE if \|z_score\| > 2 AND \|pct_change\| > 95th percentile |
| `text_embedding` | `01_text_embedding_openai.py` | 3072-dim vector from `text-embedding-3-large` (OpenAI) |
| `cluster` | `02_kmeans_clustering_tsne.py` | K-means cluster ID (0–24; 25 clusters total) |
| `cluster_label` | `03_gpt4_cluster_labelling.py` | GPT-4-generated descriptive label for each cluster |
| `tsne_x`, `tsne_y` | `02_kmeans_clustering_tsne.py` | 2D t-SNE coordinates for visualisation |

---

## Data Access

Access to CrowdTangle data requires academic credentials via Meta's research access programme.  
Meta has since transitioned to the **Meta Content Library API** as the successor platform.

- [Meta Content Library — Academic Access](https://transparency.fb.com/researchtools/meta-content-library)
- [CrowdTangle Legacy Documentation](https://help.crowdtangle.com/en/)

---

*For questions about the dataset or methodology, contact: [anwar1524@gmail.com](mailto:anwar1524@gmail.com)*
