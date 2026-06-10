WITH order_items AS (
    SELECT * FROM {{ ref('int_order_items_enriched') }}
),

orders AS (
    SELECT
        order_id,
        order_purchase_date,
        customer_delivery_date,
        estimated_delivery_date,
        delivery_status,
        order_status
    FROM {{ ref('int_orders_enriched') }}
),

reviews AS (
    SELECT
        order_id,
        review_score,
        review_sentiment
    FROM {{ ref('int_reviews_enriched') }}
),

final AS (
    SELECT
        oi.seller_id,
        oi.seller_city,
        oi.seller_state,
        COUNT(DISTINCT oi.order_id)             AS total_orders,
        COUNT(DISTINCT oi.product_id)           AS unique_products_sold,
        SUM(oi.price)                           AS total_revenue,
        SUM(oi.freight_value)                   AS total_freight,
        SUM(oi.total_item_value)                AS total_gmv,
        ROUND(AVG(oi.price), 2)                 AS avg_item_price,
        ROUND(AVG(r.review_score), 2)           AS avg_review_score,
        COUNT(CASE WHEN o.delivery_status = 'On Time' 
              THEN 1 END)                       AS on_time_deliveries,
        COUNT(CASE WHEN o.delivery_status = 'Late' 
              THEN 1 END)                       AS late_deliveries,
        ROUND(
            COUNT(CASE WHEN o.delivery_status = 'On Time' THEN 1 END) * 100.0 /
            NULLIF(COUNT(DISTINCT oi.order_id), 0)
        , 2)                                    AS on_time_delivery_pct,
        COUNT(CASE WHEN r.review_sentiment = 'Positive' 
              THEN 1 END)                       AS positive_reviews,
        COUNT(CASE WHEN r.review_sentiment = 'Negative' 
              THEN 1 END)                       AS negative_reviews
    FROM order_items oi
    LEFT JOIN orders o  ON oi.order_id = o.order_id
    LEFT JOIN reviews r ON oi.order_id = r.order_id
    GROUP BY
        oi.seller_id,
        oi.seller_city,
        oi.seller_state
)

SELECT * FROM final