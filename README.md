# dbt Sales Analytics

End-to-end analytics engineering project built with **dbt + Snowflake** on the 
[Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

## Project Architecture

```
Raw Kaggle CSVs → Snowflake Raw → DBT Staging → DBT Intermediate → DBT Marts → Power BI
```

## Tech Stack
- **DBT Core** 1.11
- **Snowflake** (Data Warehouse)
- **GitHub Actions** (CI/CD)
- **Power BI** (Dashboard)

## Data Model

### Staging (8 models)
One model per source table — cleaning, renaming, casting only.

### Intermediate (4 models)
- `int_orders_enriched` — Orders + customers + payments, delivery metrics
- `int_order_items_enriched` — Items + products + translations + sellers
- `int_reviews_enriched` — Reviews + order context + sentiment classification
- `int_seller_performance` — Seller level aggregations

### Marts (5 models)
| Model | Description |
|---|---|
| `mart_sales_summary` | Daily revenue, orders, delivery KPIs (incremental) |
| `mart_customer_orders` | Customer LTV, segmentation, order history |
| `mart_product_performance` | Product revenue, reviews, category analysis |
| `mart_seller_performance` | Seller tiers, on-time %, review scores |
| `mart_delivery_analysis` | Delivery speed buckets, delay analysis |

## Macros
- `generate_surrogate_key` — MD5 hash from column list
- `classify_delivery_status` — Reusable delivery status logic
- `cents_to_dollars` — Currency conversion

## Tests
64 data tests across all layers — unique, not_null, accepted_values, relationships.

## CI/CD
GitHub Actions pipeline triggers on every PR:
- Runs `dbt build --select state:modified+`
- Blocks merge on test failure

## Getting Started

```bash
# Install dependencies
pip install dbt-snowflake
dbt deps

# Run full pipeline
dbt build

# Generate docs
dbt docs generate
dbt docs serve
```
