WITH source AS (
    SELECT * FROM {{ source('olist', 'raw_orders') }}
),

renamed AS (
    SELECT
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp::DATE     AS order_purchase_date,
        order_purchase_timestamp           AS order_purchase_at,
        order_approved_at::DATE            AS order_approved_date,
        order_approved_at                  AS order_approved_at,
        order_delivered_carrier_date::DATE AS carrier_delivery_date,
        order_delivered_carrier_date       AS carrier_delivery_at,
        order_delivered_customer_date::DATE AS customer_delivery_date,
        order_delivered_customer_date      AS customer_delivery_at,
        order_estimated_delivery_date::DATE AS estimated_delivery_date
    FROM source
)

SELECT * FROM renamed