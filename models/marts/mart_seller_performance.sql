{{
    config(
        materialized = 'table'
    )
}}

WITH seller_metrics AS (
    SELECT * FROM {{ ref('int_seller_performance') }}
)

SELECT
    seller_id,
    seller_city,
    seller_state,
    total_orders,
    unique_products_sold,
    total_revenue,
    total_freight,
    total_gmv,
    avg_item_price,
    avg_review_score,
    on_time_deliveries,
    late_deliveries,
    on_time_delivery_pct,
    positive_reviews,
    negative_reviews,
    CASE
        WHEN avg_review_score >= 4.5
         AND on_time_delivery_pct >= 90 THEN 'Top Seller'
        WHEN avg_review_score >= 3.5
         AND on_time_delivery_pct >= 75 THEN 'Good Seller'
        WHEN avg_review_score >= 2.5
         AND on_time_delivery_pct >= 50 THEN 'Average Seller'
        ELSE 'Poor Seller'
    END                                     AS seller_tier
FROM seller_metrics