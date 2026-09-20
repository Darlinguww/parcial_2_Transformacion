# Parcial 2 — Transformación de datos con dbt

Fundación Universidad del Norte — Departamento de Ingeniería de Sistemas. Exam II.

Flujo: **Service Account → seeds → staging → intermediate → marts → BigQuery**.

## Integrantes

| Nombre | GitHub |
|---|---|
| Andrés Gómez | [@Andresgomez23310](https://github.com/Andresgomez23310) |
| Darlen Cecelia | [@Darlinguww](https://github.com/Darlinguww) |
| Hernando Barreto | [@DeadSilenceIV](https://github.com/DeadSilenceIV)  |
| José Manuel | [@Znake-G](https://github.com/Znake-G) |
| Juan Delgado | [@Deelgado](https://github.com/Deelgado) |
| Sofía Celeste Palacio | [@palaciosofia](https://github.com/palaciosofia) |
| Zenen Contreras | [@zenencontreras](https://github.com/zenencontreras) |

Proyecto dbt: `parcial_2_transformacion`.  
GCP: `dbt-exam-group-4` / dataset `dbt_exam`.

## Estructura

```
parcial_2_transformacion/
├── dbt_project.yml
├── seeds/
│   ├── exam_customers.csv
│   └── exam_orders.csv
├── models/
│   ├── staging/
│   │   ├── _schema.yml
│   │   ├── stg_exam_customers.sql
│   │   └── stg_exam_orders.sql
│   ├── intermediate/
│   │   ├── _schema.yml
│   │   └── int_orders_enriched.sql
│   └── marts/
│       ├── _schema.yml
│       ├── dim_customers.sql
│       ├── fct_orders.sql
│       └── mart_customer_kpis.sql
└── tests/
    └── assert_net_amount_not_negative.sql
```

`profiles.yml` y `service_account_key.json` van en la raíz, pero no se suben a Git.

## Setup local

Hace falta Python 3.9+, y en la raíz del repo dos archivos que el `.gitignore` excluye:

1. `service_account_key.json` — llave de la Service Account del proyecto GCP `dbt-exam-group-4`.
2. `profiles.yml`:

```yaml
parcial_2_transformacion:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: dbt-exam-group-4
      dataset: dbt_exam
      keyfile: service_account_key.json
      location: US
      threads: 4
      job_execution_timeout_seconds: 300
```

```powershell
pip install dbt-core dbt-bigquery
```

## Cómo correr, probar y mostrar en BigQuery

Desde la raíz del repo:

```powershell
dbt debug --profiles-dir .
dbt seed --profiles-dir .
dbt run --profiles-dir .
dbt test --profiles-dir .
```

| Comando | Qué hace |
|---|---|
| `dbt debug` | Comprueba perfil, llave y conexión a BigQuery. Debe decir `All checks passed!` |
| `dbt seed` | Carga los CSV a `dbt_exam`: `exam_customers` (50) y `exam_orders` (200) |
| `dbt run` | Crea views de staging/intermediate y tables de marts |
| `dbt test` | Corre los 7 tests. Debe decir `PASS=7` |

La llave (`service_account_key.json`) y `profiles.yml` viven en esta carpeta pero **no se suben a Git**.

### Ver resultados en BigQuery

1. Abrir [BigQuery — proyecto dbt-exam-group-4](https://console.cloud.google.com/bigquery?project=dbt-exam-group-4).
2. En el Explorer: **dbt-exam-group-4 → dbt_exam**.
3. Deben aparecer seeds, views y tables:

| Objeto | Tipo | Filas |
|---|---|---|
| `exam_customers` | seed | 50 |
| `exam_orders` | seed | 200 |
| `stg_exam_customers` | view | — |
| `stg_exam_orders` | view | — |
| `int_orders_enriched` | view | — |
| `dim_customers` | table | 50 |
| `fct_orders` | table | 200 |
| `mart_customer_kpis` | table | 50 |

4. Clic en una tabla → pestaña **Preview**, o pegar estas queries en el editor y **Run**.

Conteo:

```sql
SELECT
  (SELECT COUNT(*) FROM `dbt-exam-group-4.dbt_exam.exam_customers`) AS seed_customers,
  (SELECT COUNT(*) FROM `dbt-exam-group-4.dbt_exam.exam_orders`) AS seed_orders,
  (SELECT COUNT(*) FROM `dbt-exam-group-4.dbt_exam.dim_customers`) AS dim_customers,
  (SELECT COUNT(*) FROM `dbt-exam-group-4.dbt_exam.fct_orders`) AS fct_orders,
  (SELECT COUNT(*) FROM `dbt-exam-group-4.dbt_exam.mart_customer_kpis`) AS kpis;
```

Dimensión de clientes:

```sql
SELECT * FROM `dbt-exam-group-4.dbt_exam.dim_customers`
ORDER BY customer_id
LIMIT 20;
```

Hechos de pedidos (`net_amount` = amount − discount):

```sql
SELECT
  order_id, customer_name, amount, discount_amount, net_amount,
  order_status, is_orphan_customer
FROM `dbt-exam-group-4.dbt_exam.fct_orders`
ORDER BY order_id
LIMIT 20;
```

KPIs por cliente (solo pedidos `paid`, sin huérfanos):

```sql
SELECT *
FROM `dbt-exam-group-4.dbt_exam.mart_customer_kpis`
ORDER BY paid_net_revenue DESC;
```
