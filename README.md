# Pricing & Profitability Analysis
Pricing and profitability analysis using MySQL and Microsoft Power BI to evaluate revenue, margins, price realization, and pricing performance.

## Executive Summary

This project evaluates pricing effectiveness and profitability across a synthetic B2B sales dataset containing **10,000 transactions, 750 customers, and 50 products** from 2023 through 2025.

Using MySQL, I analyzed revenue performance, gross margins, price realization, customer profitability, manufacturing cost trends, and product-level pricing pressure.

### Key Business Findings

| Performance Metric | 2023 | 2025 | Change |
|---|---:|---:|---:|
| Total revenue | $13.02M | $13.06M | +0.30% |
| Average selling price | $362.82 | $374.73 | +3.28% |
| Average manufacturing unit cost | $218.48 | $242.86 | +11.16% |
| Gross profit | $4.85M | $4.49M | −7.36% |
| Gross margin | 37.23% | 34.39% | −2.84 pp |

### Key Insights

**1. Profitability declined despite higher average selling prices.**

Gross margin fell by 2.84 percentage points between 2023 and 2025, while average selling price increased by 3.28%. Manufacturing unit costs also increased, highlighting the importance of investigating pricing, cost, and product-mix changes together.

**2. High-revenue categories warrant closer pricing review.**

Power Tools generated approximately $4.76 million in 2025 revenue but experienced a 3.37-percentage-point decline in gross margin between 2023 and 2025. Compressors experienced the largest category margin decline at 3.56 percentage points.

**3. Customer profitability varies significantly by segment.**

Strategic Enterprise customers recorded a 32.82% gross margin and 84.78% price realization across the analysis period, both below company-wide benchmarks of 35.93% and 89.59%, respectively.

**4. Product-level analysis identified potential pricing pressure.**

Product 689082 experienced 3.65% average selling price growth compared with 12.36% manufacturing cost growth, producing a negative price-cost growth gap of 8.71 percentage points.

### Business Recommendations

The findings support prioritizing pricing and profitability reviews for high-revenue categories with declining margins, customer segments performing below company-wide benchmarks, and products where manufacturing cost growth exceeds realized selling price growth.

Before recommending specific price changes, further analysis should evaluate transaction-level profitability, discounting, product mix, customer demand, and competitive positioning.

**Methodology note:** Average selling price includes freight revenue and may be affected by sales mix. Manufacturing unit cost trends use unweighted monthly product-level averages, while gross margin calculations use recorded order-level financial results. These comparisons identify areas for investigation rather than establishing direct causation.

## Business Questions

This project investigates six core areas of pricing and profitability:

1. **Product Profitability:** Which products generate the most revenue and gross profit, and how effectively do they convert list-price value into realized revenue?
2. **Pricing Waterfall:** How do discounts, promotions, rebates, and freight affect realized revenue?
3. **Pricing Validation:** Can recorded revenue be reconciled to reconstructed pricing calculations, and where do material discrepancies occur?
4. **Customer Profitability:** Which customers and segments generate the strongest margins, and which accounts perform below company-wide benchmarks?
5. **Cost & Margin Trends:** How have manufacturing costs and gross margins changed between 2023 and 2025?
6. **Price Trends:** Has average selling price growth kept pace with manufacturing cost inflation, and which products warrant further pricing investigation?


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

**SQL File:** [01_product_pricing_analysis.sql](sql/01_product_pricing_analysis.sql)

Business Question: Which products generate the greatest revenue and gross profit, and how effectively do they convert list-price value into realized revenue while maintaining profitability?

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

**SQL File:** [02_price_waterfall_validation.sql](sql/02_price_waterfall_validation.sql)

Business Question: How do discounts, promotions, rebates, and freight charges affect realized revenue, and can the underlying pricing waterfall accurately reconstruct recorded transaction revenue?

Reconstructs order-level revenue from:

**List Price → Discount → Promotion → Rebate → Freight → Revenue**

Transaction-level testing indicates that percentage-based pricing adjustments are 
applied sequentially rather than independently against the original list value.

The reconstructed calculation is:

`List Value × (1 − Discount) × (1 − Promotion) × (1 − Rebate) + Freight`

This analysis establishes the pricing logic used for subsequent revenue 
reconciliation.

### 03 — Price Waterfall Outlier Analysis

**SQL File:** [03_price_waterfall_outlier_analysis.sql](sql/03_price_waterfall_outlier_analysis.sql)

Business Question: Which transactions exhibit the largest discrepancies between reconstructed and recorded revenue, and how does the number of pricing adjustments relate to reconciliation variance?

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


### 04 — Customer Profitability Analysis

**SQL File:** [04_customer_profitability_analysis.sql](sql/04_customer_profitability_analysis.sql)

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


### 05 — Cost & Margin Trend Analysis

**SQL File:** [05_cost_margin_trend_analysis.sql](sql/05_cost_margin_trend_analysis.sql)

Business Question: How have manufacturing costs and gross margins changed between 2023 and 2025, and which products and categories are experiencing the greatest margin pressure that may warrant further pricing investigation?

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

### 06 — Price Trend Analysis

**File:** [`sql/06_price_trend_analysis.sql`](sql/06_price_trend_analysis.sql)

**Business Question:** How have average selling prices (ASP) and price realization changed between 2023 and 2025, and which products and categories are experiencing manufacturing cost growth that outpaces realized selling price growth, potentially creating pricing pressure?

**Analyses performed:**
- Annual average selling price trends
- Year-over-year ASP growth using SQL window functions
- Product-level ASP changes
- Annual price realization trends
- Category-level ASP performance
- Product-level ASP growth versus manufacturing cost inflation

**Key findings:**
- Company-wide ASP increased from **$362.82 in 2023 to $374.73 in 2025**, an increase of approximately 3.28%.
- Price realization was **89.52% in 2023, 89.78% in 2024, and 89.47% in 2025**, indicating a slight decline after 2024.
- Compressors experienced just **0.02% ASP growth** from 2023 to 2025, alongside a **3.56-percentage-point decline in gross margin**.
- Power Tools experienced **2.13% ASP growth** and a **3.37-percentage-point decline in gross margin**, making it another priority for pricing review.
- Product **689082** had the largest negative price-cost growth gap among the products analyzed, at **−8.71 percentage points**.

**Business implications:**

The analysis identifies products and categories where realized selling price growth may not be keeping pace with manufacturing cost inflation. These findings can help prioritize further investigation into pricing adjustments, discounting practices, product mix, and profitability.

**Methodology note:** ASP is calculated as total revenue divided by units sold and includes freight revenue. Manufacturing costs are annual averages of monthly product costs. Price-cost growth gaps are screening indicators, not direct measures of gross margin deterioration.

## Technical Skills Demonstrated

**SQL & Data Analysis**
- Relational database design and multi-table joins
- Common Table Expressions (CTEs)
- Window functions (`LAG()`, `RANK()`)
- Conditional aggregation and `CASE WHEN`
- Data validation and reconciliation
- Handling null values and division by zero with `NULLIF()`

**Pricing & Commercial Analytics**
- Revenue and gross profit analysis
- Gross margin and profitability benchmarking
- Average selling price (ASP) analysis
- Price realization and pricing waterfall analysis
- Customer segmentation and profitability screening
- Manufacturing cost inflation analysis
- Year-over-year growth and percentage-point comparisons
- Product-level pricing pressure identification

**Tools**
- MySQL
- MySQL Workbench
- GitHub
- Microsoft Power BI — Planned

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
│   ├── 05_cost_margin_trend_analysis.sql
│   └── 06_price_trend_analysis.sql
│
└── dashboards/             
    └── Power BI dashboard         # In development

*Note: The datasets used in this project are synthetic and intended for educational and portfolio demonstration purposes.*
```

