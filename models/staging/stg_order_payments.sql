WITH source AS (
    SELECT * FROM {{ source('olist', 'raw_order_payments') }}
),

renamed AS (
    SELECT
        order_id,
        payment_sequential  AS payment_sequence,
        payment_type,
        payment_installments AS installments,
        payment_value
    FROM source
)

SELECT * FROM renamed