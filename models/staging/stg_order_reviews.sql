WITH source AS (
    SELECT * FROM {{ source('olist', 'raw_order_reviews') }}
),

renamed AS (
    SELECT
        review_id,
        order_id,
        review_score,
        review_comment_title    AS comment_title,
        review_comment_message  AS comment_message,
        review_creation_date::DATE    AS review_date,
        review_answer_timestamp::DATE AS review_answer_date
    FROM source
)

SELECT * FROM renamed