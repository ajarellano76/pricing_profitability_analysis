-- 05_cost_margin_trend_analysis.sql

-- Question: How have product costs and gross margins changed from 2023-2025,
-- & which products or categories may be experiencing margin pressure? 

-- Question: How have manufacturing unit costs changed between 2023 and 2025,
-- & which products experienced the greatest cost increases?

-- ============================================================
-- RESULT 1: ANNUAL MANUFACTURING COST TRENDS
--
-- Business Question:
-- How have average manufacturing unit costs changed
-- between 2023 and 2025?
--
-- Purpose:
-- Establish annual cost benchmarks and evaluate
-- manufacturing cost trends across products.
--
-- Note:
-- Average unit cost is not weighted by sales volume.

-- METHODOLOGY NOTE:
--
-- Manufacturing cost trends are calculated using monthly
-- product-level unit costs from cost_history.
--
-- Gross margin trends are calculated using recorded
-- revenue, total_cost, and gross_profit from orders.
--
-- Manufacturing cost averages are not sales-volume weighted.
-- Gross margin percentages are revenue weighted.
--
-- These analyses identify related financial trends but
-- do not establish that manufacturing cost inflation
-- directly caused gross margin deterioration.
-- ============================================================

SELECT
    YEAR(effective_date)        AS cost_year,
    ROUND(AVG(unit_cost), 2)    AS avg_unit_cost,
    MIN(unit_cost)              AS min_unit_cost,
    MAX(unit_cost)              AS max_unit_cost,
    COUNT(DISTINCT product_id)  AS product_coverage
FROM cost_history
GROUP BY cost_year
ORDER BY cost_year;

-- ============================================================
-- RESULT 2: YEAR-OVER-YEAR MANUFACTURING COST CHANGES
--
-- Business Question:
-- How quickly have average manufacturing costs increased
-- from one year to the next?
--
-- Key Findings:
-- Average manufacturing costs increased 5.69% in 2024
-- and 5.17% in 2025.
-- Cost growth slowed slightly but remained positive.
--
-- Note:
-- These figures represent UNWEIGHTED averages across
-- monthly product cost observations.
-- ============================================================

WITH annual_costs AS (
    SELECT
        YEAR(effective_date) AS cost_year,
        AVG(unit_cost) AS avg_unit_cost
    FROM cost_history
    GROUP BY YEAR(effective_date)
),

cost_comparison AS (
    SELECT
        cost_year,
        avg_unit_cost,
        LAG(avg_unit_cost) OVER (
            ORDER BY cost_year
        ) AS previous_year_cost
    FROM annual_costs
)

SELECT
    cost_year,
    ROUND(avg_unit_cost, 2) AS avg_unit_cost,
    ROUND(previous_year_cost, 2) AS previous_year_cost,
    ROUND(
        (avg_unit_cost - previous_year_cost) /
        NULLIF(previous_year_cost, 0) * 100, 
        2
    ) AS yoy_cost_change_pct

FROM cost_comparison
ORDER BY cost_year;

-- ============================================================
-- RESULT 3: PRODUCT-LEVEL COST INFLATION
--
-- Business Question:
-- Which products experienced the largest percentage increases
-- in manufacturing unit cost between 2023 and 2025?
--
-- Key Findings:
-- Utility Mower 50 had the highest cumulative cost increase
-- at 15.10%.
--
-- Impact Wrench 19 had the largest dollar increase among
-- the top 10 percentage-inflation products, at $66.21.
--
-- Five of the top 10 products belonged to Power Tools.
--
-- Pricing Implication:
-- Products with substantial manufacturing cost increases
-- may warrant pricing reviews to determine whether selling
-- prices have kept pace with cost inflation.
--
-- Note:
-- Cost inflation alone does NOT establish margin erosion.
-- ============================================================

WITH product_annual_costs AS (
    SELECT
        ch.product_id,
        p.product_name,
        p.product_category,
        YEAR(ch.effective_date) AS cost_year,
        AVG(ch.unit_cost) AS avg_unit_cost
    FROM cost_history AS ch
    INNER JOIN products AS p
        ON ch.product_id = p.product_id
    GROUP BY
        ch.product_id,
        p.product_name,
        p.product_category,
        YEAR(ch.effective_date)
),

product_cost_comparison AS (
    SELECT
        product_id,
        product_name,
        product_category,

        MAX(CASE
            WHEN cost_year = 2023 THEN avg_unit_cost
        END) AS cost_2023,

        MAX(CASE
            WHEN cost_year = 2025 THEN avg_unit_cost
        END) AS cost_2025

    FROM product_annual_costs
    GROUP BY
        product_id,
        product_name,
        product_category
)


SELECT
    product_id,
    product_name,
    product_category,
    ROUND(cost_2023, 2) AS cost_2023,
    ROUND(cost_2025, 2) AS cost_2025,

    ROUND(
        cost_2025 - cost_2023,
        2
    ) AS cost_increase_dollars,

    ROUND(
        (cost_2025 - cost_2023)
        / NULLIF(cost_2023, 0) * 100,
        2
    ) AS cost_increase_pct

FROM product_cost_comparison
ORDER BY cost_increase_pct DESC
LIMIT 10;

-- ============================================================
-- RESULT 4: ANNUAL GROSS MARGIN TRENDS
--
-- Business Question:
-- How have revenue, costs, gross profit, and gross
-- margins changed annually between 2023 and 2025?
--
-- Purpose:
-- Evaluate annual profitability trends and identify
-- potential margin pressure.
--
-- Key Findings:
-- Revenue remained relatively flat, increasing 0.30%.
-- Total recorded costs increased approximately 4.84%.
-- Gross profit declined approximately 7.36%.
-- Gross margin decreased from 37.23% to 34.39%,
-- representing a decline of 2.84 percentage points.
--
-- Pricing Implication:
-- Rising costs alongside relatively flat revenue
-- suggest profitability pressure that warrants further
-- investigation into pricing, discounts, and product mix.
--
-- Note:
-- The analysis establishes margin deterioration but
-- does not isolate its underlying causes.
-- ============================================================

SELECT
    YEAR(order_date) AS order_year,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(total_cost), 2) AS total_cost,
    ROUND(SUM(gross_profit), 2) AS total_gross_profit,

    ROUND(
        SUM(gross_profit) /
        NULLIF(SUM(revenue), 0) * 100,
        2
    ) AS gross_margin_pct,

    COUNT(*) AS total_orders

FROM orders
GROUP BY order_year
ORDER BY order_year;

-- ============================================================
-- RESULT 5: GROSS MARGIN TRENDS BY PRODUCT CATEGORY
--
-- Business Question:
-- How have annual gross margins changed 
-- within each product category?
--
-- Key Findings:
-- All seven product categories experienced margin declines.
--
-- Compressors had the largest decline at 3.56
-- percentage points.
--
-- Power Tools declined 3.37 percentage points and
-- generated approximately $4.76M in 2025 revenue.
--
-- Hydraulic Components maintained the highest 2025
-- gross margin at 39.78%.
--
-- Pricing Implication:
-- Power Tools may warrant priority review due to its
-- combination of substantial revenue and margin decline.
--
-- Note:
-- Margin deterioration does not establish whether
-- changes in prices, costs, discounts, or product mix
-- were responsible.
-- ============================================================

SELECT
    p.product_category,
    YEAR(o.order_date) AS order_year,
    ROUND(SUM(o.revenue), 2) AS total_revenue,
    ROUND(SUM(o.gross_profit), 2) AS total_gross_profit,

    ROUND(
        SUM(o.gross_profit) /
        NULLIF(SUM(o.revenue), 0) * 100,
        2
    ) AS gross_margin_pct
 
FROM orders AS o
INNER JOIN products AS p
    ON o.product_id = p.product_id

GROUP BY
    p.product_category,
    YEAR(o.order_date)

ORDER BY
    p.product_category,
    order_year;

-- ============================================================
-- RESULT 6: CATEGORY GROSS MARGIN DETERIORATION RANKINGS
--
-- Business Question:
-- Which categories experienced the greatest cumulative margin 
-- deterioration between 2023 and 2025?
--
-- Key Findings:
-- All seven product categories experienced margin declines.
--
-- Compressors experienced the greatest deterioration,
-- declining 3.56 percentage points.
--
-- Power Tools ranked second, declining 3.37 percentage
-- points, while generating approximately $4.76M
-- in 2025 revenue.
--
-- Hydraulic Components experienced the smallest decline
-- at 1.80 percentage points.
--
-- Pricing Implication:
-- Power Tools may be a high-priority category for
-- pricing review because of its substantial revenue
-- and deteriorating profitability.
--
-- Note:
-- These results identify margin deterioration but do
-- not establish its underlying causes.
-- ============================================================


WITH category_annual_margins AS (
    SELECT
        p.product_category,
        YEAR(o.order_date) AS order_year,
        SUM(o.gross_profit) /
        NULLIF(SUM(o.revenue), 0) * 100 AS gross_margin_pct
    FROM orders AS o
    INNER JOIN products AS p
        ON o.product_id = p.product_id
    GROUP BY
        p.product_category,
        YEAR(o.order_date)
),

category_margin_comparison AS (
    SELECT
        product_category,

        MAX(CASE
            WHEN order_year = 2023 THEN gross_margin_pct
        END) AS margin_2023,

        MAX(CASE
            WHEN order_year = 2025 THEN gross_margin_pct
        END) AS margin_2025

    FROM category_annual_margins
    GROUP BY product_category
)

SELECT
    product_category,
    ROUND(margin_2023, 2) AS margin_2023,
    ROUND(margin_2025, 2) AS margin_2025,

    ROUND(
        margin_2025 - margin_2023,
        2
    ) AS margin_change_pp

FROM category_margin_comparison
ORDER BY margin_change_pp ASC;