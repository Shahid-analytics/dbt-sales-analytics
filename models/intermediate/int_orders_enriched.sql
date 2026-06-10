WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

payments AS (
    SELECT
        order_id,
        SUM(payment_value)        AS total_payment_value,
        MAX(installments)         AS max_installments,
        COUNT(payment_sequence)   AS payment_count,
        MODE(payment_type)        AS most_used_payment_type
    FROM {{ ref('stg_order_payments') }}
    GROUP BY order_id
),

final AS (
    SELECT
        o.order_id,
        o.customer_id,
        c.customer_unique_id,
        c.city                    AS customer_city,
        c.state                   AS customer_state,
        o.order_status,
        o.order_purchase_date,
        o.order_purchase_at,
        o.order_approved_date,
        o.carrier_delivery_date,
        o.customer_delivery_date,
        o.estimated_delivery_date,
        p.total_payment_value,
        p.max_installments,
        p.payment_count,
        p.most_used_payment_type,
        DATEDIFF('day', 
            o.order_purchase_date, 
            o.customer_delivery_date)  AS actual_delivery_days,
        DATEDIFF('day', 
            o.order_purchase_date, 
            o.estimated_delivery_date) AS estimated_delivery_days,
        {{ classify_delivery_status('o.customer_delivery_date', 'o.estimated_delivery_date') }} AS delivery_status
    FROM orders o
    LEFT JOIN customers c ON o.customer_id = c.customer_id
    LEFT JOIN payments p  ON o.order_id = p.order_id
)

SELECT * FROM final