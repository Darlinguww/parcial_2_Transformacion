select
    order_id,
    customer_id,
    order_date,
    amount,
    discount_amount,
    net_amount,
    currency,
    order_status,
    payment_method,
    item_count,
    customer_name,
    country_code,
    city,
    customer_tier,
    is_active,
    is_orphan_customer
from {{ ref('int_orders_enriched') }}
