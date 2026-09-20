# Parcial 2 — Transformación de datos con dbt

Fundación Universidad del Norte — Departamento de Ingeniería de Sistemas. Exam II, Group 4.

Flujo: **Service Account → seeds → staging → intermediate → marts → BigQuery**.

Proyecto dbt: `parcial_2_transformacion`.  
GCP: `dbt-exam-group-4` / dataset `dbt_exam`.

## Estructura

```
parcial_2_transformacion/
├── seeds/exam_customers.csv
├── seeds/exam_orders.csv
├── models/staging/stg_exam_customers.sql
├── models/staging/stg_exam_orders.sql
├── models/intermediate/int_orders_enriched.sql
└── models/marts/
    ├── dim_customers.sql
    ├── fct_orders.sql
    └── mart_customer_kpis.sql
```

## Cómo correr

```powershell
dbt debug --profiles-dir .
dbt seed --profiles-dir .
dbt run --profiles-dir .
dbt test --profiles-dir .
```

La llave (`service_account_key.json`) y `profiles.yml` viven en esta carpeta pero **no se suben a Git**.
