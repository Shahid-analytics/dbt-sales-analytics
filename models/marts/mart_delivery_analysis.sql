{{
    config(
        materialized = 'table'
    )
}}

WITH orders AS (
    SELECT * FROM {{ ref('int_orders_enriched') }}
),

delivery_metrics AS (
    SELECT
        order_id,
        customer_city,
        customer_state,
        order_purchase_date,
        carrier_delivery_date,
        customer_delivery_date,
        estimated_delivery_date,
        actual_delivery_days,
        estimated_delivery_days,
        delivery_status,
        order_status,
        CASE
            WHEN actual_delivery_days <= 7  THEN 'Express (<=7 days)'
            WHEN actual_delivery_days <= 14 THEN 'Standard (8-14 days)'
            WHEN actual_delivery_days <= 30 THEN 'Slow (15-30 days)'
            ELSE 'Very Slow (>30 days)'
        END                                 AS delivery_speed_bucket,
        actual_delivery_days - 
            estimated_delivery_days         AS delivery_delay_days
    FROM orders
    WHERE order_status = 'delivered'
)

SELECT * FROM delivery_metrics