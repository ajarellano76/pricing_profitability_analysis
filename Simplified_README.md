# Pricing & Profitability Analysis

**Tools:** MySQL | MySQL Workbench | Power BI (Planned)

## Executive Summary

Gross margins declined despite increasing average selling prices, raising questions about whether pricing performance is keeping pace with manufacturing costs.

Using MySQL, I analyzed 10,000 transactions across 50 products and 750 customers to evaluate pricing performance, profitability, and manufacturing cost trends between 2023 and 2025.

The analysis revealed that:

- **Gross margin declined from 37.23% to 34.39%**, a decrease of 2.84 percentage points.
- **Average selling price increased 3.28%**, while average manufacturing unit costs increased 11.16%.
- **Power Tools and Compressors** experienced significant margin declines and relatively weak selling price growth.
- Several products experienced manufacturing cost increases that outpaced selling price growth.

Based on these findings, I recommend prioritizing pricing reviews for high-revenue categories experiencing margin pressure, investigating discounting and product mix, and identifying opportunities to improve price realization.

## Business Problem

Maintaining profitable pricing is essential for companies operating in competitive B2B markets.

As manufacturing costs change, businesses need to understand whether selling prices, discounts, and customer purchasing patterns are supporting sustainable profitability.

This analysis addresses three primary questions:

1. Which products and customers generate the greatest revenue and profitability?
2. How effectively does the company convert list prices into realized revenue?
3. Is selling price growth keeping pace with manufacturing cost inflation?

The goal is to identify potential pricing opportunities and provide data-driven recommendations that support profitability.

## Methodology

I used MySQL to analyze a synthetic relational dataset containing 10,000 orders from 2023 through 2025.

The analysis included:

- **Product & Customer Profitability:** Evaluated revenue, gross profit, gross margins, and customer performance.
- **Price Waterfall Analysis:** Examined how discounts, promotions, rebates, and freight contribute to realized revenue.
- **Pricing Validation:** Reconstructed transaction revenue and investigated reconciliation discrepancies.
- **Cost & Margin Trends:** Measured manufacturing cost inflation and changes in gross margins.
- **Price Trend Analysis:** Compared selling price growth with manufacturing cost inflation to identify potential pricing pressure.

### SQL Analysis Files

| Analysis | SQL Script |
|---|---|
| Product Pricing & Profitability | [01 — Product Analysis](sql/01_product_pricing_analysis.sql) |
| Price Waterfall Validation | [02 — Waterfall Validation](sql/02_price_waterfall_validation.sql) |
| Price Waterfall Outliers | [03 — Outlier Analysis](sql/03_price_waterfall_outlier_analysis.sql) |
| Customer Profitability | [04 — Customer Analysis](sql/04_customer_profitability_analysis.sql) |
| Cost & Margin Trends | [05 — Cost & Margin Analysis](sql/05_cost_margin_trend_analysis.sql) |
| Price Trends | [06 — Price Trend Analysis](sql/06_price_trend_analysis.sql) |

## Skills Demonstrated

**SQL:** CTEs, joins, window functions, conditional aggregation, `CASE WHEN`, data validation, and revenue reconciliation.

**Pricing Analytics:** Gross margin analysis, average selling price (ASP), price realization, price waterfall analysis, customer segmentation, profitability benchmarking, and cost inflation analysis.

**Data Visualization:** Power BI dashboard development planned for the next project phase.

## Results & Business Recommendations

### 1. Investigate margin compression

Company-wide gross margin declined by 2.84 percentage points between 2023 and 2025, while average selling price increased 3.28%.

Average manufacturing unit costs increased 11.16% over the same period. Although these metrics use different weighting methods, the trends suggest that further investigation into pricing, costs, and product mix is warranted.

**Recommendation:** Review product-level margins, realized prices, and cost changes to identify where pricing actions may help protect profitability.

### 2. Prioritize high-revenue categories

Power Tools generated approximately $4.76 million in 2025 revenue while experiencing a 3.37-percentage-point decline in gross margin.

Compressors experienced the largest category margin decline at 3.56 percentage points, with average selling price growth of just 0.02%.

**Recommendation:** Prioritize Power Tools for its revenue exposure and review Compressors for potential pricing or cost-related pressure.

### 3. Evaluate customer pricing performance

Strategic Enterprise customers had the lowest segment gross margin at 32.82% and price realization at 84.78%, compared with company-wide benchmarks of 35.93% and 89.59%.

**Recommendation:** Investigate customer-level discounting, purchasing patterns, and profitability before considering pricing adjustments.

### 4. Identify products experiencing cost pressure

Product 689082 experienced 12.36% manufacturing cost growth compared with 3.65% average selling price growth, resulting in a negative price-cost growth gap of 8.71 percentage points.

**Recommendation:** Use product-level price-cost growth gaps to prioritize further profitability reviews rather than automatically increasing prices.

## Next Steps

- Develop an interactive Power BI dashboard to monitor revenue, gross margins, price realization, and pricing trends.
- Expand the analysis to evaluate discount effectiveness and pricing opportunities.
- Investigate competitor pricing and identify products with potential pricing improvement opportunities.
- Develop recommendations supported by transaction-level profitability and pricing performance.

pricing_profitability_analysis/
├── README.md
├── Simplified_README.md
├── data/
├── documentation/
└── sql/
    ├── 01_product_pricing_analysis.sql
    ├── 02_price_waterfall_validation.sql
    ├── 03_price_waterfall_outlier_analysis.sql
    ├── 04_customer_profitability_analysis.sql
    ├── 05_cost_margin_trend_analysis.sql
    └── 06_price_trend_analysis.sql

---

*This project uses synthetic data created for educational and portfolio purposes. Average selling price includes freight revenue. Manufacturing cost trends use unweighted monthly product-level averages, while gross margin calculations use recorded transaction-level financial results. Findings identify potential areas for investigation rather than proven causes of margin changes.*
