{% snapshot snap_customer_segments %}

{{
    config(
        target_schema='snapshots',
        unique_key='customer_unique_id',
        strategy='check',
        check_cols=['customer_segment', 'lifetime_value']
    )
}}

SELECT
    customer_unique_id,
    customer_city,
    customer_state,
    customer_segment,
    lifetime_value,
    total_orders,
    avg_review_score
FROM {{ ref('mart_customer_orders') }}

{% endsnapshot %}