select
    c.customer_id,
    c.name,
    c.country_code,
    c.customer_tier,
    c.is_active,
    count(f.order_id) as paid_order_count,
    coalesce(sum(f.net_amount), 0) as paid_net_revenue,
    coalesce(avg(f.net_amount), 0) as avg_paid_ticket
from {{ ref('dim_customers') }} as c
left join {{ ref('fct_orders') }} as f
    on c.customer_id = f.customer_id
    and f.order_status = 'paid'
    and f.is_orphan_customer = false
group by 1, 2, 3, 4, 5
