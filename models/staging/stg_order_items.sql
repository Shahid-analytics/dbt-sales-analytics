WITH source AS (
    SELECT * FROM {{ source('olist', 'raw_order_items') }}
),

renamed AS (
    SELECT
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date::DATE AS shipping_limit_date,
        price,
        freight_value
    FROM source
)

SELECT * FROM renamed