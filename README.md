# Parcial 2 - Transformación de Datos con dbt y BigQuery

Proyecto de transformación de datos desarrollado con **dbt Core** sobre **Google BigQuery**, para la asignatura *Transformación de Datos con Data Build Tool (DBT)* del Departamento de Ingeniería de Sistemas, Fundación Universidad del Norte.

El proyecto toma las tablas crudas de clientes y pedidos, las limpia, las combina y las deja listas para consumo en BI, siguiendo la jerarquía recomendada por dbt: **staging → intermediate → marts**.

**Integrantes:** _(completar)_

---

## Tecnologías

| Herramienta | Uso |
|---|---|
| dbt Core + `dbt-bigquery` | Transformación de datos con SQL modular |
| Google BigQuery | Data warehouse |
| Google Cloud Service Account | Autenticación de dbt contra BigQuery |
| VS Code + extensión de dbt | Desarrollo |
| Git / GitHub | Control de versiones |

## Datos de origen (RAW)

- **Proyecto GCP:** `parcialestransformaciondatos`
- **Dataset:** `Parcial_1` (región `US`)

| Tabla | Descripción | Columnas |
|---|---|---|
| `customers` | Clientes | customer_id, name, country_code, created_at, city, postal_code, preferred_language, signup_channel, is_active, customer_tier |
| `exam_orders` | Pedidos | order_id, customer_id, order_date, amount, amount_cents, currency, order_status, payment_method, discount_amount, item_count |

## Estructura del proyecto

```
parcial_2_transformacion/
├── dbt_project.yml
├── models/
│   ├── staging/
│   │   ├── sources.yml
│   │   ├── schema.yml
│   │   ├── stg_customers.sql
│   │   └── stg_orders.sql
│   ├── intermediate/
│   │   ├── schema.yml
│   │   ├── int_orders_enriched.sql
│   │   └── int_customer_order_metrics.sql
│   └── marts/
│       ├── schema.yml
│       ├── dim_customers.sql
│       ├── fct_orders.sql
│       └── mart_sales_by_country_month.sql
├── analyses/  macros/  seeds/  snapshots/  tests/
└── README.md
```

## Arquitectura de modelos

```
 RAW (Parcial_1)        Staging              Intermediate                 Marts
┌───────────────┐   ┌──────────────┐   ┌────────────────────────┐   ┌─────────────────────────────┐
│ customers     │──▶│ stg_customers│──▶│ int_orders_enriched    │──▶│ fct_orders                  │
│ exam_orders   │──▶│ stg_orders   │──▶│ int_customer_order_    │──▶│ dim_customers               │
└───────────────┘   └──────────────┘   │   metrics              │   │ mart_sales_by_country_month │
                                       └────────────────────────┘   └─────────────────────────────┘
```

### Staging (`stg_`)
Limpieza básica de las tablas crudas, con relación 1:1 respecto a RAW. Solo renombra columnas, castea tipos y normaliza texto. No contiene JOINs ni lógica compleja.

| Modelo | Origen | Qué hace |
|---|---|---|
| `stg_customers` | `raw.customers` | Renombra `name` → `customer_name` y `created_at` → `created_date`, castea `postal_code` a string, normaliza mayúsculas/minúsculas y espacios |
| `stg_orders` | `raw.exam_orders` | Renombra `amount` → `order_amount`, normaliza `currency`, `order_status` y `payment_method` |

### Intermediate (`int_`)
Transformaciones más complejas: JOINs, cálculos y agregaciones. Sus resultados no son el producto final y se materializan como vistas.

| Modelo | Descripción |
|---|---|
| `int_orders_enriched` | Une pedidos con datos del cliente y calcula `net_amount` (monto menos descuento) e `is_completed` |
| `int_customer_order_metrics` | Métricas de pedidos por cliente: total de pedidos, ingresos, descuentos, ítems y fechas del primer y último pedido |

### Marts (`dim_` / `fct_`)
Tablas finales, anchas y listas para BI. Se materializan como tablas.

| Modelo | Descripción |
|---|---|
| `dim_customers` | Dimensión de clientes con sus métricas de compra (una fila por cliente) |
| `fct_orders` | Tabla de hechos de pedidos (una fila por pedido) |
| `mart_sales_by_country_month` | Ventas completadas por país, mes y moneda |

## Configuración

### 1. Requisitos
- Python 3.9 o superior
- Una cuenta de servicio de GCP con los roles **BigQuery Job User** y **BigQuery Data Editor** (o **BigQuery Admin**)
- La llave JSON de esa cuenta de servicio

### 2. Instalación

```bash
python -m venv venv
venv\Scripts\activate          # Windows
# source venv/bin/activate     # macOS / Linux

pip install dbt-core dbt-bigquery
```

### 3. Archivo `profiles.yml`

Créalo en `~/.dbt/profiles.yml` (en Windows: `C:\Users\<usuario>\.dbt\profiles.yml`):

```yaml
parcial_2_transformacion:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      keyfile: /ruta/a/tu/service_account_key.json
      project: parcialestransformaciondatos
      dataset: Parcial_1
      location: US
      threads: 4
```

### 4. Configuración de esquemas en `dbt_project.yml`

```yaml
models:
  parcial_2_transformacion:
    staging:
      +materialized: view
      +schema: staging
    intermediate:
      +materialized: view
      +schema: intermediate
    marts:
      +materialized: table
      +schema: marts
```

Con esta configuración dbt crea los datasets `Parcial_1_staging`, `Parcial_1_intermediate` y `Parcial_1_marts`, y deja las tablas crudas en `Parcial_1`.

## Ejecución

```bash
dbt debug            # verifica la conexión con BigQuery
dbt run              # construye todos los modelos
dbt test             # corre las pruebas de calidad
dbt build            # run + test en orden de dependencias
dbt docs generate    # genera la documentación
dbt docs serve       # abre la documentación y el DAG en el navegador
```

Para ejecutar una sola capa o un modelo con sus dependencias:

```bash
dbt run --select staging
dbt run --select +fct_orders
```

## Pruebas de calidad

Las pruebas están definidas en los archivos `schema.yml` de cada capa:

- `unique` y `not_null` sobre las llaves primarias (`customer_id`, `order_id`).
- `relationships` entre pedidos y clientes.

## Convenciones

- Prefijos: `stg_` (staging), `int_` (intermediate), `dim_` y `fct_` (marts).
- Los modelos se conectan con `ref()` y las tablas crudas con `source()`, para que dbt construya el DAG de dependencias.
- Los nombres de columnas usan `snake_case`.

## Seguridad

**Nunca subas la llave de la cuenta de servicio al repositorio.** Asegúrate de que el `.gitignore` incluya:

```
service_account_key.json
*.json
target/
logs/
venv/
dbt_packages/
```

Si una llave se expuso por error, elimínala en la consola de GCP (IAM y administración → Cuentas de servicio → Claves) y genera una nueva.

## Referencias

- [About dbt models](https://docs.getdbt.com/docs/build/models)
- [Jinja and macros](https://docs.getdbt.com/docs/build/jinja-macros)
- [dbt BigQuery setup](https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup)
