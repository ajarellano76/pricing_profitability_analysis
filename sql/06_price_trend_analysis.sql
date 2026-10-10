-- ============================================================
-- 06_price_trend_analysis.sql
-- PRICING & PROFITABILITY ANALYTICS PORTFOLIO
--
-- Objective:
-- Analyze realized selling price trends from 2023 to 2025
-- and identify products where manufacturing cost inflation
-- exceeded average selling price growth.
--
-- Data Sources:
-- orders, products, cost_history
--
-- Analysis Period:
-- January 1, 2023 - December 31, 2025
--
-- Methodology:
-- ASP = Total Revenue / Total Units Sold
-- Price Realization = Revenue / Total List Value
-- Price-Cost Gap = ASP Growth % - Cost Growth %
--
-- Important Limitations:
-- Revenue includes freight fees.
-- ASP trends may reflect changes in product mix.
-- Manufacturing costs are unweighted monthly averages.
-- Price-cost growth gaps are screening indicators,
-- not direct measures of actual gross margin changes.
--
-- Dataset:
-- Synthetic data used for portfolio demonstration.
-- ============================================================

-- ============================================================
-- RESULT 1: ANNUAL AVERAGE SELLING PRICE
--
-- Business Question:
-- How has average selling price changed from 2023 to 2025?

-- Key Findings:
-- ASP increased from $362.82 in 2023 to $374.73 in 2025.
-- Total ASP growth was approximately 3.28%.
-- Unit sales declined from 35,898 to 34,861.
--
-- Pricing Implication:
-- Revenue per unit increased despite lower unit volume.
-- Further product-level analysis is required to distinguish
-- pricing changes from shifts in product mix.
--
-- Methodology:
-- ASP = SUM(revenue) / SUM(quantity).
-- Revenue includes freight fees.
-- ============================================================

SELECT
    YEAR(order_date) AS order_year,

    SUM(revenue) AS total_revenue,
    SUM(quantity) AS total_units,

    ROUND(
        SUM(revenue) / NULLIF(SUM(quantity), 0), 
        2) AS avg_selling_price,
    COUNT(*) AS total_orders

FROM orders
WHERE order_date >= '2023-01-01'
  AND order_date < '2026-01-01'
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- ============================================================
-- RESULT 2: YEAR-OVER-YEAR AVERAGE SELLING PRICE CHANGES
--
-- Business Question:
-- How quickly has average revenue per unit increased
-- between 2023 and 2025?
--
-- Key Findings:
-- ASP increased 1.41% in 2024 and 1.84% in 2025.
-- Annual ASP growth accelerated by 0.43 percentage points.
--
-- Pricing Implication:
-- ASP growth was slower than the unweighted manufacturing
-- cost inflation observed in SQL 05.
--
-- Note:
-- ASP includes freight revenue and is affected by
-- changes in product mix.
-- ============================================================

WITH annual_asp AS (
    SELECT
        YEAR(order_date) AS order_year,
        SUM(revenue) /
        NULLIF(SUM(quantity), 0) AS avg_selling_price

    FROM orders

    WHERE order_date >= '2023-01-01'
      AND order_date < '2026-01-01'

    GROUP BY YEAR(order_date)
),

asp_comparison AS (
    SELECT
        order_year,
        avg_selling_price,

        LAG(avg_selling_price) OVER (
            ORDER BY order_year
        ) AS previous_year_asp

    FROM annual_asp
)

SELECT
    order_year,

    ROUND(avg_selling_price, 2) AS avg_selling_price,

    ROUND(previous_year_asp, 2) AS previous_year_asp,

    ROUND(
        (avg_selling_price - previous_year_asp) /
        NULLIF(previous_year_asp, 0) * 100,
        2
    ) AS yoy_asp_change_pct

FROM asp_comparison
ORDER BY order_year;

-- ============================================================
-- RESULT 3: PRODUCT-LEVEL AVERAGE SELLING PRICE TRENDS
--
-- Business Question:
-- Which products experienced the largest ASP increases
-- between 2023 and 2025?
--
-- Key Findings:
-- Seal Kit 06 had the highest ASP growth at 10.08%.
-- Five of the top 10 products belong to Power Tools.
-- Three of the top 10 belong to Industrial Pumps.
--
-- Pricing Implication:
-- Product-level ASP trends provide more granular insight
-- than company-wide averages, which are affected by mix.
--
-- Note:
-- ASP includes freight revenue and reflects realized
-- revenue per unit, not necessarily official list prices.
-- ============================================================

WITH product_annual_asp AS (
    SELECT
        o.product_id,
        p.product_name,
        p.product_category,
        YEAR(o.order_date) AS order_year,

        SUM(o.revenue) /
        NULLIF(SUM(o.quantity), 0) AS avg_selling_price

    FROM orders AS o

    INNER JOIN products AS p
        ON o.product_id = p.product_id

    WHERE o.order_date >= '2023-01-01'
      AND o.order_date < '2026-01-01'

    GROUP BY
        o.product_id,
        p.product_name,
        p.product_category,
        YEAR(o.order_date)
),

product_price_comparison AS (
    SELECT
        product_id,
        product_name,
        product_category,

        MAX(CASE
            WHEN order_year = 2023 THEN avg_selling_price
        END) AS asp_2023,

        MAX(CASE
            WHEN order_year = 2025 THEN avg_selling_price
        END) AS asp_2025

    FROM product_annual_asp

    GROUP BY
        product_id,
        product_name,
        product_category
)

SELECT
    product_id,
    product_name,
    product_category,

    ROUND(asp_2023, 2) AS asp_2023,
    ROUND(asp_2025, 2) AS asp_2025,

    ROUND(
        (asp_2025 - asp_2023) /
        NULLIF(asp_2023, 0) * 100,
        2
    ) AS asp_change_pct

FROM product_price_comparison

WHERE asp_2023 IS NOT NULL
  AND asp_2025 IS NOT NULL

ORDER BY asp_change_pct DESC
LIMIT 10;

-- ============================================================
-- RESULT 4: ANNUAL PRICE REALIZATION TRENDS
--
-- Business Question:
-- Is the company capturing a greater percentage of its
-- listed product value over time?
--
-- Key Findings:
-- 2023 price realization: 89.52%
-- 2024 price realization: 89.78%
-- 2025 price realization: 89.47%
--
-- Pricing Implication:
-- Price realization improved in 2024 but declined in 2025,
-- finishing slightly below the 2023 level.
--
-- Note:
-- Revenue includes freight. Changes in realization may
-- reflect discounts, promotions, rebates, product mix,
-- and freight rather than list-price changes alone.
-- ============================================================

SELECT
    YEAR(order_date) AS order_year,

    SUM(revenue) AS total_revenue,

    SUM(list_unit_price * quantity) AS total_list_value,

    ROUND(
        SUM(revenue) /
        NULLIF(SUM(list_unit_price * quantity), 0) * 100,
        2
    ) AS price_realization_pct,

    COUNT(*) AS total_orders

FROM orders

WHERE order_date >= '2023-01-01'
  AND order_date < '2026-01-01'

GROUP BY YEAR(order_date)
ORDER BY order_year;

-- ============================================================
-- RESULT 5: CATEGORY-LEVEL AVERAGE SELLING PRICE TRENDS
--
-- Business Question:
-- Which categories experienced the weakest ASP growth
-- between 2023 and 2025?
--
-- Key Findings:
-- Compressors: +0.02% ASP, -3.56 pp gross margin.
-- Power Tools: +2.13% ASP, -3.37 pp gross margin.
-- Replacement Parts: +8.00% ASP, -2.82 pp gross margin.
--
-- Pricing Implication:
-- Compressors and Power Tools are candidates for further
-- pricing review due to weak ASP growth and margin declines.
--
-- Note:
-- Category ASP is affected by product mix, freight, and
-- transaction-level pricing adjustments.
-- ============================================================

WITH category_annual_asp AS (
    SELECT
        p.product_category,
        YEAR(o.order_date) AS order_year,

        SUM(o.revenue) /
        NULLIF(SUM(o.quantity), 0) AS avg_selling_price

    FROM orders AS o

    INNER JOIN products AS p
        ON o.product_id = p.product_id

    WHERE o.order_date >= '2023-01-01'
      AND o.order_date < '2026-01-01'

    GROUP BY
        p.product_category,
        YEAR(o.order_date)
),

category_price_comparison AS (
    SELECT
        product_category,

        MAX(CASE
            WHEN order_year = 2023 THEN avg_selling_price
        END) AS asp_2023,

        MAX(CASE
            WHEN order_year = 2025 THEN avg_selling_price
        END) AS asp_2025

    FROM category_annual_asp

    GROUP BY product_category
)

SELECT
    product_category,

    ROUND(asp_2023, 2) AS asp_2023,
    ROUND(asp_2025, 2) AS asp_2025,

    ROUND(
        (asp_2025 - asp_2023) /
        NULLIF(asp_2023, 0) * 100,
        2
    ) AS asp_change_pct

FROM category_price_comparison

WHERE asp_2023 IS NOT NULL
  AND asp_2025 IS NOT NULL

ORDER BY asp_change_pct ASC;


-- ============================================================
-- RESULT 6: PRODUCT-LEVEL PRICE VS. COST INFLATION
--
-- Business Question:
-- Which products experienced manufacturing cost growth
-- exceeding realized ASP growth between 2023 and 2025?
--
-- Key Findings:
-- Product 689082: ASP +3.65%, cost +12.36%, gap -8.71 pp.
-- Product 844857: ASP +6.92%, cost +15.10%, gap -8.18 pp.
-- Product 161127: ASP +6.02%, cost +13.31%, gap -7.29 pp.
--
-- Pricing Implication:
-- Products with the largest negative price-cost growth
-- gaps are candidates for additional pricing and
-- profitability investigation.
--
-- Methodology:
-- ASP = SUM(revenue) / SUM(quantity).
-- Manufacturing cost = AVG(monthly unit_cost).
-- Price-cost gap = ASP growth % - cost growth %.
--
-- Limitations:
-- ASP includes freight revenue and reflects transaction mix.
-- Manufacturing costs are unweighted monthly averages.
-- Growth-rate gaps do not directly measure margin changes.
-- ============================================================

-- First CTE
WITH annual_product_cost AS (
    SELECT
        product_id,
        YEAR(effective_date) AS cost_year,
        AVG(unit_cost) AS avg_unit_cost

    FROM cost_history

    WHERE effective_date >= '2023-01-01'
      AND effective_date < '2026-01-01'

    GROUP BY
        product_id,
        YEAR(effective_date)
),

-- Second CTE
annual_product_asp AS (
    SELECT
        o.product_id,
        YEAR(o.order_date) AS order_year,

        SUM(o.revenue) /
        NULLIF(SUM(o.quantity), 0) AS avg_selling_price

    FROM orders AS o

    WHERE o.order_date >= '2023-01-01'
      AND o.order_date < '2026-01-01'

    GROUP BY
        o.product_id,
        YEAR(o.order_date)
),

-- Third CTE
product_price_cost_trend AS (
    SELECT
        a.product_id,
        a.order_year,
        a.avg_selling_price,
        c.avg_unit_cost

    FROM annual_product_asp AS a

    INNER JOIN annual_product_cost AS c
        ON a.product_id = c.product_id
       AND a.order_year = c.cost_year
),

-- Fourth CTE
product_growth_comparison AS (
    SELECT
        product_id,

        MAX(CASE
            WHEN order_year = 2023 THEN avg_selling_price
        END) AS asp_2023,

        MAX(CASE
            WHEN order_year = 2025 THEN avg_selling_price
        END) AS asp_2025,

        MAX(CASE
            WHEN order_year = 2023 THEN avg_unit_cost
        END) AS cost_2023,

        MAX(CASE
            WHEN order_year = 2025 THEN avg_unit_cost
        END) AS cost_2025

    FROM product_price_cost_trend

    GROUP BY product_id
)

-- Final table
SELECT
    pgc.product_id,
    p.product_name,
    p.product_category,

    ROUND(pgc.asp_2023, 2) AS asp_2023,
    ROUND(pgc.asp_2025, 2) AS asp_2025,

    ROUND(pgc.cost_2023, 2) AS cost_2023,
    ROUND(pgc.cost_2025, 2) AS cost_2025,


    ROUND(
        (asp_2025 - asp_2023) /
        NULLIF(asp_2023, 0) * 100,
        2
    ) AS asp_growth_pct,

    ROUND(
        (cost_2025 - cost_2023) /
        NULLIF(cost_2023, 0) * 100,
        2
    ) AS cost_growth_pct,

    ROUND(
        (
            (asp_2025 - asp_2023) /
            NULLIF(asp_2023, 0)
            -
            (cost_2025 - cost_2023) /
            NULLIF(cost_2023, 0)
        ) * 100,
        2
    ) AS price_cost_gap_pp

FROM product_growth_comparison AS pgc

INNER JOIN products AS p
    ON pgc.product_id = p.product_id

WHERE pgc.asp_2023 > 0
  AND pgc.asp_2025 IS NOT NULL
  AND pgc.cost_2023 > 0
  AND pgc.cost_2025 IS NOT NULL

ORDER BY price_cost_gap_pp ASC
LIMIT 10;
