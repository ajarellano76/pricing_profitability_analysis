# Pricing & Profitability Analysis
Pricing and profitability analysis using MySQL and Microsoft Power BI to evaluate revenue, margins, price realization, and pricing performance.

## Project Overview

This project analyzes transactional sales data to evaluate pricing performance, 
profitability, and revenue realization using MySQL.

The analysis examines how list prices, discounts, promotions, rebates, freight, 
costs, and sales volume contribute to realized revenue and gross profit. The 
project also validates the underlying pricing waterfall and investigates 
transaction-level discrepancies between reconstructed and recorded revenue.

GOAL: Demonstrate how SQL can be used to answer practical pricing 
questions, validate pricing logic, and identify opportunities for deeper 
profitability analysis.

## Business Questions

- Which products generate the most revenue and gross profit?
- How much of list-price value is ultimately realized as revenue?
- How do discounts, promotions, and rebates affect realized pricing?
- How profitable are products after accounting for cost?
- Can recorded revenue be reconciled to the underlying pricing adjustments?
- Where do the largest pricing reconciliation discrepancies occur?
- Does reconciliation variance change as pricing adjustments become more complex?


## Methodology & Technologies:

- **MySQL** — Data storage, transformation, validation, and analysis
- **MySQL Workbench** — SQL development and database exploration
- **Microsoft Power BI** — Planned dashboard development and data visualization
- **GitHub** — Version control and project documentation


## Dataset

The relational dataset contains:

- **10,000 orders**
- **750 customers**
- **50 products**
- **40 sales representatives**

The broader dataset also includes pricing, cost, competitor, discount, and sales 
target information that will be incorporated into later stages of the analysis.

Key transactional fields include:

- List unit price
- Quantity
- Revenue
- Standard and total cost
- Gross profit
- Gross margin
- Discount percentage
- Promotion percentage
- Rebate percentage
- Freight fees


## Analysis

### 01 — Product Pricing & Profitability Analysis

Analyzes product-level commercial performance using metrics including:

- Revenue
- Units sold
- Average selling price (ASP)
- List-price value
- Price realization
- Discount from list
- Gross profit
- Gross margin
- Gross profit per unit
- Cost per unit

The analysis also validates stored gross profit against independently calculated 
gross profit to test data consistency.

**Key finding:** Product-level gross profit reconciled to independently calculated 
gross profit with no discrepancies exceeding $1.00.


### 02 — Price Waterfall Validation

Reconstructs order-level revenue from:

**List Price → Discount → Promotion → Rebate → Freight → Revenue**

Transaction-level testing indicates that percentage-based pricing adjustments are 
applied sequentially rather than independently against the original list value.

The reconstructed calculation is:

`List Value × (1 − Discount) × (1 − Promotion) × (1 − Rebate) + Freight`

This analysis establishes the pricing logic used for subsequent revenue 
reconciliation.


### 03 — Price Waterfall Outlier Analysis

Evaluates the accuracy of the reconstructed pricing waterfall and investigates 
material reconciliation discrepancies.

Across 10,000 orders:

- **Average absolute revenue variance:** $0.13
- **Maximum absolute revenue variance:** $4.63

Outliers are evaluated using both dollar variance and percentage variance to 
distinguish financial magnitude from relative materiality.

The analysis also uses conditional logic to classify transactions by the number 
of pricing adjustments applied.

| Pricing Adjustments | Orders | Avg. Absolute Variance | Max Absolute Variance |
|---:|---:|---:|---:|
| 0 | 78 | $0.02 | $0.09 |
| 1 | 4,924 | $0.11 | $3.83 |
| 2 | 4,154 | $0.14 | $4.63 |
| 3 | 844 | $0.18 | $4.52 |

**Key finding:** Average reconciliation variance increased as additional pricing 
adjustments were applied, indicating an association between pricing adjustment 
complexity and reconciliation variance.


## SQL Skills Demonstrated

This project currently demonstrates:

- Multi-table joins
- Common Table Expressions (CTEs)
- Aggregate functions
- `GROUP BY` and `HAVING`
- Conditional logic with `CASE WHEN`
- Window functions with `RANK()`
- Weighted pricing calculations
- Price realization calculations
- Gross margin and profitability analysis
- Revenue reconciliation
- Data validation and outlier analysis


## Repository Structure

```text
pricing_profitability_analysis/
│
├── README.md
│
├── sql/
│   ├── 01_product_pricing_analysis.sql
│   ├── 02_price_waterfall_validation.sql
│   └── 03_price_waterfall_outlier_analysis.sql
│
├── data/
├── documentation/
└── power_bi/
