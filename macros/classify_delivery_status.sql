{% macro classify_delivery_status(actual_col, estimated_col) %}
    CASE
        WHEN {{ actual_col }} IS NULL THEN 'Pending'
        WHEN {{ actual_col }} <= {{ estimated_col }} THEN 'On Time'
        ELSE 'Late'
    END
{% endmacro %}