with orders as (

    select * from {{ ref('stg_exam_orders') }}

),

customers as (

    select * from {{ ref('stg_exam_customers') }}

),

joined as (

    select
        o.order_id,
        o.customer_id,
        o.order_date,
        o.amount,
        o.discount_amount,
        o.currency,
        o.order_status,
        o.payment_method,
        o.item_count,
        c.name                  as customer_name,
        c.country_code,
        c.city,
        c.customer_tier,
        c.signup_channel,
        c.is_active,
        c.created_at            as customer_created_at,
        c.customer_id is null   as is_orphan_customer

    from orders o
    left join customers c
        on o.customer_id = c.customer_id

),

calculated as (

    select
        *,
        -- el descuento se topa al monto: la orden 1049 trae 28.7 sobre 27.9
        amount - least(coalesce(discount_amount, 0), amount) as net_amount,
        coalesce(discount_amount, 0) > amount               as has_invalid_discount,
        coalesce(discount_amount, 0) > 0                    as has_discount,
        date_trunc(order_date, month)                       as order_month,
        extract(year from order_date)                       as order_year,
        date_diff(order_date, customer_created_at, day)     as days_since_signup,
        order_status = 'paid'                               as is_paid,
        order_status = 'pending'                            as is_pending,
        order_status = 'cancelled'                          as is_cancelled,
        order_status = 'refunded'                           as is_refunded

    from joined

),

final as (

    select
        *,
        if(is_paid, net_amount, 0)                          as net_revenue,
        coalesce(days_since_signup < 0, false)              as is_backdated_order,
        round(safe_divide(net_amount, item_count), 2)       as net_amount_per_item

    from calculated

)

select * from final
