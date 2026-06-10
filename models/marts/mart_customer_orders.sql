{{
    config(
        materialized = 'table'
    )
}}

WITH orders AS (
    SELECT * FROM {{ ref('int_orders_enriched') }}
),

order_items AS (
    SELECT * FROM {{ ref('int_order_items_enriched') }}
),

reviews AS (
    SELECT * FROM {{ ref('int_reviews_enriched') }}
),

customer_metrics AS (
    SELECT
    {{ generate_surrogate_key(['customer_unique_id']) }} AS customer_key,
        o.customer_unique_id,
        MAX(o.customer_city)    AS customer_city,
MAX(o.customer_state)   AS customer_state,
        COUNT(DISTINCT o.order_id)              AS total_orders,
        COALESCE(SUM(oi.total_item_value), 0)               AS lifetime_value,
ROUND(COALESCE(AVG(oi.total_item_value), 0), 2)     AS avg_order_value,
        MIN(o.order_purchase_date)              AS first_order_date,
        MAX(o.order_purchase_date)              AS last_order_date,
        DATEDIFF('day',
            MIN(o.order_purchase_date),
            MAX(o.order_purchase_date))         AS customer_lifespan_days,
        ROUND(AVG(r.review_score), 2)           AS avg_review_score,
        COUNT(CASE WHEN o.delivery_status = 'Late'
              THEN 1 END)                       AS late_deliveries_experienced,
        CASE
            WHEN COUNT(DISTINCT o.order_id) = 1 THEN 'One Time'
            WHEN COUNT(DISTINCT o.order_id) BETWEEN 2 AND 4 THEN 'Returning'
            ELSE 'Loyal'
        END                                     AS customer_segment
    FROM orders o
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN reviews r      ON o.order_id = r.order_id
    GROUP BY
        o.customer_unique_id
)

SELECT * FROM customer_metrics