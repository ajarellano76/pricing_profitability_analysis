# Dataset

## Overview

This project uses a synthetic relational dataset created for the purpose of
demonstrating pricing and profitability analytics.

The dataset does not represent actual company, customer, employee, or
transactional information.

It was designed to simulate a commercial pricing environment containing
products, customers, sales representatives, transactions, pricing adjustments,
cost changes, competitor pricing, and sales targets.

## Core Dataset

The current analysis uses four primary tables:

| File | Description |
|---|---|
| `orders.csv` | Transaction-level sales, pricing, cost, and profitability data |
| `products.csv` | Product attributes, list prices, and standard costs |
| `customers.csv` | Customer segmentation, tier, region, industry, and sales potential |
| `sales_reps.csv` | Sales representative, territory, and channel information |

The core dataset contains:

- 10,000 orders
- 750 customers
- 50 products
- 40 sales representatives

## Additional Pricing Data

The dataset also includes:

| File | Intended Analysis |
|---|---|
| `price_history.csv` | Historical product pricing analysis |
| `cost_history.csv` | Cost and margin trend analysis |
| `competitor_prices.csv` | Competitive price positioning |
| `discounts.csv` | Discount analysis |
| `sales_targets.csv` | Sales performance and target analysis |

These tables will be incorporated into later stages of the project.

## Data Structure

The `orders` table serves as the primary transactional table and connects to
product, customer, and sales representative dimensions through foreign keys.

Detailed field definitions are available in:

`documentation/data_dictionary.csv`

Database relationships and integrity validation are documented in:

`documentation/database_schema.md`

## Data Disclaimer

This is a synthetic dataset generated specifically for analytical practice and
portfolio development. All entities, transactions, financial values, customers,
products, and sales representatives are fictional and should not be interpreted
as actual business data.
