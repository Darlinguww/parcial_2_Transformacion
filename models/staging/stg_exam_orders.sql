select
    cast(order_id as int64) as order_id,
    cast(customer_id as int64) as customer_id,
    cast(order_date as date) as order_date,
    cast(amount as numeric) as amount,
    cast(amount_cents as int64) as amount_cents,
    upper(currency) as currency,
    lower(order_status) as order_status,
    lower(payment_method) as payment_method,
    cast(discount_amount as numeric) as discount_amount,
    cast(item_count as int64) as item_count
from {{ ref('exam_orders') }}
