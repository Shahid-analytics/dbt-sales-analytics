WITH reviews AS (
    SELECT * FROM {{ ref('stg_order_reviews') }}
),

orders AS (
    SELECT
        order_id,
        order_purchase_date,
        customer_id,
        customer_city,
        customer_state,
        order_status,
        delivery_status
    FROM {{ ref('int_orders_enriched') }}
),

final AS (
    SELECT
        r.review_id,
        r.order_id,
        r.review_score,
        r.comment_title,
        r.comment_message,
        r.review_date,
        r.review_answer_date,
        o.customer_id,
        o.customer_city,
        o.customer_state,
        o.order_purchase_date,
        o.order_status,
        o.delivery_status,
        DATEDIFF('day',
            o.order_purchase_date,
            r.review_date)              AS days_to_review,
        CASE
            WHEN r.review_score >= 4 THEN 'Positive'
            WHEN r.review_score = 3  THEN 'Neutral'
            ELSE 'Negative'
        END                             AS review_sentiment,
        CASE
            WHEN r.comment_message IS NULL THEN FALSE
            ELSE TRUE
        END                             AS has_comment
    FROM reviews r
    LEFT JOIN orders o ON r.order_id = o.order_id
)

SELECT * FROM final