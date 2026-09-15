# IDS / Database Systems

Oracle SQL/PLSQL relational database project with joins, triggers, stored procedures, indexing and materialized views.

## What this project demonstrates

- Relational database design with primary and foreign keys
- Data integrity with `NOT NULL`, `CHECK` and composite constraints
- Multi-table `JOIN` queries
- Aggregation with `SUM` and `GROUP BY`
- Nested queries, `EXISTS`, `NOT IN`, CTEs and `CASE`
- PL/SQL triggers and stored procedures
- Explicit cursors, `%TYPE`, record types and exception handling
- Index creation and `EXPLAIN PLAN`
- Privilege management with `GRANT`
- Materialized views

## Domain model

The database contains the following main entities:

- `Branch` — retail locations
- `Product` — fruits and vegetables sold by the branches
- `Supplier` — companies delivering products
- `Delivery` — supplier deliveries
- `Sale` — sales recorded by branch
- `Sold` — products included in each sale
- `Located_At` — current stock per branch and product
- `Price_History` — product price changes over time

```mermaid
erDiagram
    BRANCH ||--o{ SALE : records
    BRANCH ||--o{ LOCATED_AT : stores
    PRODUCT ||--o{ LOCATED_AT : stocked_as
    PRODUCT ||--o{ SOLD : appears_in
    SALE ||--o{ SOLD : contains
    PRODUCT ||--o{ PRICE_HISTORY : has
    SUPPLIER ||--o{ DELIVERY : provides

    BRANCH {
        int branch_id PK
        varchar branch_name
        varchar address
        varchar phone_number
    }
    PRODUCT {
        int product_id PK
        varchar type
        varchar product_name
        number weight
        date expiry_date
        number selling_price
    }
    SALE {
        int sale_id PK
        date sale_date
        number total_price
        number total_weight
        int item_count
        int branch_id FK
    }
    SUPPLIER {
        int supplier_id PK
        varchar company_name
        varchar address
        varchar phone_number
        varchar email
    }
    DELIVERY {
        int delivery_id PK
        int supplier_id FK
        date delivery_date
        number total_price
        number total_weight
        int item_count
    }
    SOLD {
        int sale_id FK
        int product_id FK
        int quantity
    }
    LOCATED_AT {
        int branch_id FK
        int product_id FK
        int quantity
    }
    PRICE_HISTORY {
        int product_id FK
        date price_date
        number price
    }
```

## Documentation

The original project documentation with the use-case diagram and database model is available in [`docs/database-design.pdf`](docs/database-design.pdf).

## Repository structure

```text
.
├── README.md
├── docs/
│   └── database-design.pdf
└── xfedor14_xramas01.sql   # original university project file
```

## How to run

The project is written for Oracle Database / Oracle SQL Developer.

Run `xfedor14_xramas01.sql` as the main project script. `SET SERVEROUTPUT ON` may be enabled in Oracle SQL Developer to display output from PL/SQL procedures.

## Notes

This coursework was completed as a team project. The original SQL file is preserved unchanged in this repository.
