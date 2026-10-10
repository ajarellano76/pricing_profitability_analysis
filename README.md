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

This project uses a **synthetic relational pricing dataset** created specifically
for analytical practice and portfolio development. The data does not represent
actual company, customer, employee, or transactional information.

The dataset contains:

- **10,000 orders**
- **750 customers**
- **50 products**
- **40 sales representatives**

The broader dataset also includes historical pricing, cost, competitor pricing,
discount, and sales target data that will be incorporated into later stages of
the analysis.

The complete synthetic source dataset is available in [`data/raw`](data/raw),
with additional documentation available in the
[`documentation`](documentation) directory.

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


### 04 — Customer Profitability Analysis

**Business Question:** Which customers and customer segments generate the greatest revenue and gross profit, and which accounts warrant further pricing review?

**Objective:** Evaluate customer profitability, purchasing behavior, price realization, and estimated annual sales potential to identify differences in financial performance and opportunities for further investigation.

**Analytical Methods:**
- Customer-level revenue, gross profit, and weighted gross margin calculations.
- Average order value and order frequency analysis.
- Annual revenue comparison against estimated customer sales potential.
- Customer segment profitability and price realization benchmarking.
- Common Table Expressions (CTEs) and `CROSS JOIN` to dynamically compare customer performance against company-wide benchmarks.
- Customer screening based on cumulative revenue, gross margin, and price realization.

**Key Findings:**
- Company-wide gross margin averaged **35.93%**, with **89.59% price realization** across 2023–2025.
- The Contractor segment generated the highest revenue at approximately **$10.26 million**.
- Small Business customers achieved the highest segment gross margin (**38.86%**) and price realization (**93.91%**).
- Strategic Enterprise customers recorded the lowest gross margin (**32.82%**) and price realization (**84.78%**).
- Customer-level screening identified higher-revenue accounts falling below both company-wide benchmarks, providing a targeted starting point for reviewing pricing, product mix, and costs.

**Business Implications:**

Revenue alone does not determine customer profitability. Differences in gross margin and price realization suggest that customer segmentation and account-level performance should be considered when evaluating pricing strategies.

Accounts identified through the screening process are candidates for further analysis rather than automatic price increases.

**Limitations:** This project uses synthetic data. Annual sales potential is treated as constant across 2023–2025, and the screening thresholds are exploratory rather than established company policies.

**SQL Script:** `sql/04_customer_profitability_analysis.sql`

### 05 — Cost & Margin Trend Analysis

**SQL File:** [05_cost_margin_trend_analysis.sql](sql/05_cost_margin_trend_analysis.sql)

**Objective:** Evaluate manufacturing cost inflation and gross margin performance between 2023 and 2025 to identify products and categories that may warrant further pricing investigation.

**Analysis Performed:**
- Annual manufacturing unit cost trends
- Year-over-year manufacturing cost inflation
- Product-level manufacturing cost increases
- Annual revenue, cost, and gross margin trends
- Gross margin performance by product category
- Category-level margin deterioration rankings

**Key Findings:**

| Metric | 2023 | 2025 | Change |
|---|---:|---:|---:|
| Average manufacturing unit cost | $218.48 | $242.86 | +11.16% |
| Total revenue | $13.02M | $13.06M | +0.30% |
| Recorded total costs | $8.18M | $8.57M | +4.84% |
| Gross profit | $4.85M | $4.49M | −7.36% |
| Gross margin | 37.23% | 34.39% | −2.84 percentage points |

**Category-Level Findings:**

- **Compressors:** Largest gross margin deterioration, declining 3.56 percentage points.
- **Power Tools:** Gross margin declined 3.37 percentage points, with approximately $4.76 million in 2025 revenue.
- **Replacement Parts:** Gross margin declined 2.82 percentage points.
- **Hydraulic Components:** Smallest deterioration, declining 1.80 percentage points.

**Business Implications:**

All seven product categories experienced gross margin deterioration between 2023 and 2025. Power Tools represents a potential priority for pricing review because of its combination of substantial revenue and declining profitability.

Further analysis of realized selling prices, discounts, and product mix is necessary to determine the drivers of margin compression.

**Methodology:** Manufacturing cost trends use unweighted monthly product-level cost observations. Gross margin trends use recorded order-level financial results and revenue-weighted margin calculations. These measures are related but are not directly interchangeable, and the observed trends do not establish causation.

**SQL Techniques:** Common Table Expressions (CTEs), `LAG()`, conditional aggregation, `CASE WHEN`, `JOIN`, `GROUP BY`, `NULLIF()`, and percentage-point calculations.

## Repository Structure

```text
## Repository Structure

```text
pricing_profitability_analysis/
│
├── README.md
│
├── data/
│   ├── README.md
│   └── raw/
│       └── [Synthetic CSV datasets]
│
├── documentation/
│   ├── data_dictionary
│   └── database_schema
│
├── sql/
│   ├── 01_product_pricing_analysis.sql
│   ├── 02_price_waterfall_validation.sql
│   ├── 03_price_waterfall_outlier_analysis.sql
│   ├── 04_customer_profitability_analysis.sql
│   └── 05_cost_margin_trend_analysis.sql
│
└── dashboards/                    # Planned
    └── Power BI dashboard         # In development

*Note: The datasets used in this project are synthetic and intended for educational and portfolio demonstration purposes.*
```

