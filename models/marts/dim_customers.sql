select
    customer_id,
    name,
    country_code,
    created_at,
    city,
    postal_code,
    preferred_language,
    signup_channel,
    is_active,
    customer_tier
from {{ ref('stg_exam_customers') }}
