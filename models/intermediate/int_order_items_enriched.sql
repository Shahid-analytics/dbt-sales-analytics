WITH order_items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),

products AS (
    SELECT * FROM {{ ref('stg_products') }}
),

translations AS (
    SELECT * FROM {{ ref('stg_product_category_translations') }}
),

sellers AS (
    SELECT * FROM {{ ref('stg_sellers') }}
),

final AS (
    SELECT
        oi.order_id,
        oi.order_item_id,
        oi.product_id,
        oi.seller_id,
        oi.shipping_limit_date,
        oi.price,
        oi.freight_value,
        oi.price + oi.freight_value  AS total_item_value,
        p.category_name              AS category_name_portuguese,
        t.category_name_english      AS category_name,
        p.weight_g,
        p.length_cm,
        p.height_cm,
        p.width_cm,
        p.photos_qty,
        s.city                       AS seller_city,
        s.state                      AS seller_state
    FROM order_items oi
    LEFT JOIN products p    ON oi.product_id = p.product_id
    LEFT JOIN translations t ON p.category_name = t.category_name
    LEFT JOIN sellers s     ON oi.seller_id = s.seller_id
)

SELECT * FROM final