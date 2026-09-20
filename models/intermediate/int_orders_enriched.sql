select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.amount,
    o.discount_amount,
    o.amount - o.discount_amount as net_amount,
    o.currency,
    o.order_status,
    o.payment_method,
    o.item_count,
    c.name as customer_name,
    c.country_code,
    c.city,
    c.customer_tier,
    c.is_active,
    c.customer_id is null as is_orphan_customer
from {{ ref('stg_exam_orders') }} as o
left join {{ ref('stg_exam_customers') }} as c
    on o.customer_id = c.customer_id
