-- models/staging/stg_orders.sql

select
    order_id,
    customer_id,
    order_date,
    amount                          as order_amount,
    amount_cents,
    upper(currency)                 as currency,
    lower(order_status)             as order_status,
    lower(payment_method)           as payment_method,
    discount_amount,
    item_count
from {{ source('raw', 'exam_orders') }}