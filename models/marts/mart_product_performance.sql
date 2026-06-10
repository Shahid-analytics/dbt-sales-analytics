{{
    config(
        materialized = 'table'
    )
}}

WITH order_items AS (
    SELECT * FROM {{ ref('int_order_items_enriched') }}
),

reviews AS (
    SELECT * FROM {{ ref('int_reviews_enriched') }}
),

product_metrics AS (
    SELECT
        oi.product_id,
        oi.category_name,
        COUNT(DISTINCT oi.order_id)             AS total_orders,
        SUM(oi.price)                           AS total_revenue,
        SUM(oi.freight_value)                   AS total_freight,
        ROUND(AVG(oi.price), 2)                 AS avg_price,
        COUNT(DISTINCT oi.seller_id)            AS sellers_carrying_product,
        ROUND(AVG(r.review_score), 2)           AS avg_review_score,
        COUNT(CASE WHEN r.review_sentiment = 'Positive'
              THEN 1 END)                       AS positive_reviews,
        COUNT(CASE WHEN r.review_sentiment = 'Negative'
              THEN 1 END)                       AS negative_reviews,
        ROUND(
            COUNT(CASE WHEN r.review_sentiment = 'Positive' THEN 1 END) * 100.0 /
            NULLIF(COUNT(r.review_id), 0)
        , 2)                                    AS positive_review_pct
    FROM order_items oi
    LEFT JOIN reviews r ON oi.order_id = r.order_id
    GROUP BY
        oi.product_id,
        oi.category_name
)

SELECT * FROM product_metrics