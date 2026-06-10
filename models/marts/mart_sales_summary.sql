{{
    config(
        materialized = 'incremental',
        unique_key = 'order_purchase_date',
        on_schema_change = 'sync_all_columns'
    )
}}

WITH orders AS (
    SELECT * FROM {{ ref('int_orders_enriched') }}

    {% if is_incremental() %}
        WHERE order_purchase_date > (
            SELECT MAX(order_purchase_date) FROM {{ this }}
        )
    {% endif %}
),

order_items AS (
    SELECT * FROM {{ ref('int_order_items_enriched') }}
),

daily_metrics AS (
    SELECT
        o.order_purchase_date,
        COUNT(DISTINCT o.order_id)              AS total_orders,
        COUNT(DISTINCT o.customer_unique_id)    AS unique_customers,
        COALESCE(SUM(oi.price), 0)                           AS total_revenue,
COALESCE(SUM(oi.freight_value), 0)                   AS total_freight,
COALESCE(SUM(oi.total_item_value), 0)                AS total_gmv,
ROUND(COALESCE(AVG(oi.price), 0), 2)                 AS avg_order_value,
        COUNT(DISTINCT oi.seller_id)            AS active_sellers,
        COUNT(DISTINCT oi.product_id)           AS unique_products_sold,
        COUNT(CASE WHEN o.delivery_status = 'On Time' 
              THEN 1 END)                       AS on_time_deliveries,
        COUNT(CASE WHEN o.delivery_status = 'Late' 
              THEN 1 END)                       AS late_deliveries,
        COUNT(CASE WHEN o.order_status = 'canceled' 
              THEN 1 END)                       AS canceled_orders
    FROM orders o
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_purchase_date
)

SELECT * FROM daily_metrics