select
    order_id,
    amount,
    discount_amount,
    net_amount
from {{ ref('int_orders_enriched') }}
where net_amount < 0
