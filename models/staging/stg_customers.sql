-- models/staging/stg_customers.sql

select
    customer_id,
    trim(name)                      as customer_name,
    upper(country_code)             as country_code,
    created_at                      as created_date,
    trim(city)                      as city,
    cast(postal_code as string)     as postal_code,
    lower(preferred_language)       as preferred_language,
    lower(signup_channel)           as signup_channel,
    is_active,
    lower(customer_tier)            as customer_tier
from {{ source('raw', 'customers') }}