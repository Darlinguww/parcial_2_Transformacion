select
    cast(customer_id as int64) as customer_id,
    name,
    upper(country_code) as country_code,
    cast(created_at as date) as created_at,
    city,
    postal_code,
    preferred_language,
    signup_channel,
    cast(is_active as bool) as is_active,
    lower(customer_tier) as customer_tier
from {{ ref('exam_customers') }}
