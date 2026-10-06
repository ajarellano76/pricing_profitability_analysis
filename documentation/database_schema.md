# Database Schema

## Overview

The pricing analytics database is structured as a relational MySQL database
designed to support pricing, profitability, customer, product, and sales analysis.

The `orders` table serves as the core transactional table and connects sales
transactions to product, customer, and sales representative dimensions.

---

## Core Tables

### `orders`

**Grain:** One row per order transaction  
**Primary Key:** `order_id`

**Foreign Keys:**

- `product_id` → `products.product_id`
- `customer_id` → `customers.customer_id`
- `sales_rep_id` → `sales_reps.sales_rep_id`

**Key analytical fields:**

- Order date
- Shipping date
- Quantity
- List unit price
- Discount percentage
- Promotion percentage
- Rebate percentage
- Freight fee
- Revenue
- Total cost
- Gross profit
- Gross margin percentage
- Order status
- Sales channel

---

### `products`

**Grain:** One row per product  
**Primary Key:** `product_id`

**Key attributes:**

- Product name
- Product category
- Product family
- Manufacturing city
- Size
- Color
- SKU
- Standard cost
- List price
- Product status

---

### `customers`

**Grain:** One row per customer  
**Primary Key:** `customer_id`

**Key attributes:**

- Customer name
- Customer segment
- Customer tier
- Region
- Industry
- Annual sales potential
- Customer start year

---

### `sales_reps`

**Grain:** One row per sales representative  
**Primary Key:** `sales_rep_id`

**Key attributes:**

- Sales representative name
- Territory
- Sales channel

---

## Core Relationships

The `orders` table connects transactional sales activity to the three core
dimension tables.

```text
                    products
                       │
                  product_id
                       │
                       ▼
customers ────────► orders ◄──────── sales_reps
 customer_id                       sales_rep_id
