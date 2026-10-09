-- 04_customer_profitability_analysis.sql
-- Project: Pricing & Profitability Analysis
--
-- Purpose:
-- Evaluate customer-level revenue, profitability, price
-- realization, annual sales potential, and pricing performance.
--
-- Data period: January 2023 - December 2025
--
-- Notes:
-- 1. The dataset is synthetic.
-- 2. Annual sales potential is assumed constant across years.
-- 3. Price realization includes the effects of pricing
--    adjustments and freight reflected in recorded revenue.
-- 4. Pricing review candidates are not confirmed pricing issues.


-- ============================================================
-- RESULT 1: OVERALL CUSTOMER PROFITABILITY
--
-- Business Question:
-- Which customers generate the most revenue, and are the
-- highest-revenue customers also the most profitable?
--
-- Purpose:
-- Compare customer revenue, gross profit, gross margin,
-- order behavior, and price realization across 2023-2025.
-- ============================================================

SELECT
    o.customer_id,
    c.customer_name,
    c.customer_segment,
    c.customer_tier,
    c.annual_sales_potential,

    SUM(o.revenue) AS total_revenue,
    SUM(o.gross_profit) AS total_gross_profit,

    ROUND(
        SUM(o.gross_profit) /
        NULLIF(SUM(o.revenue), 0) * 100,
        2
    ) AS gross_margin_pct,

    COUNT(o.order_id) AS order_count,

    ROUND(
        SUM(o.revenue) / NULLIF(COUNT(o.order_id), 0),
        2
    ) AS avg_order_value,

    ROUND(
        SUM(o.revenue) /
        NULLIF(SUM(o.list_unit_price * o.quantity), 0) * 100,
        2
    ) AS price_realization_pct

FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id

GROUP BY
    o.customer_id,
    c.customer_name,
    c.customer_segment,
    c.customer_tier,
    c.annual_sales_potential

ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- RESULT 2: ANNUAL SALES POTENTIAL CAPTURE
--
-- Business Question:
-- How does each customer's annual revenue compare with
-- their estimated annual sales potential?
--
-- Purpose:
-- Evaluate customer revenue relative to annual potential
-- separately for each calendar year.
--
-- Assumption:
-- Annual sales potential is treated as constant for
-- 2023, 2024, and 2025.
--
-- Caution:
-- Capture above 100% may indicate underestimated potential
-- or differences in the synthetic data assumptions.
-- ============================================================

SELECT
    o.customer_id,
    c.customer_name,
    YEAR(o.order_date) AS order_year,
    c.annual_sales_potential,

    SUM(o.revenue) AS annual_revenue,

    ROUND(
        SUM(o.revenue) /
        NULLIF(c.annual_sales_potential, 0) * 100,
        2
    ) AS annual_potential_capture_pct

FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id

GROUP BY
    o.customer_id,
    c.customer_name,
    YEAR(o.order_date),
    c.annual_sales_potential

ORDER BY annual_revenue DESC
LIMIT 10;


-- ============================================================
-- RESULT 3: CUSTOMER PROFITABILITY BY SEGMENT
--
-- Business Questions:
-- Which customer segments generate the most revenue?
-- Which segments deliver the strongest gross margins?
-- How does price realization vary across segments?
--
-- Purpose:
-- Compare segment-level financial performance and identify
-- potential differences in pricing and profitability.
-- ============================================================

SELECT
    c.customer_segment,

    COUNT(DISTINCT o.customer_id) AS customer_count,
    SUM(o.revenue) AS total_revenue,
    SUM(o.gross_profit) AS total_gross_profit,

    ROUND(
        SUM(o.gross_profit) /
        NULLIF(SUM(o.revenue), 0) * 100,
        2
    ) AS gross_margin_pct,

    ROUND(
        SUM(o.revenue) /
        NULLIF(SUM(o.list_unit_price * o.quantity), 0) * 100,
        2
    ) AS price_realization_pct

FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id

GROUP BY
    c.customer_segment

ORDER BY total_revenue DESC;


-- ============================================================
-- RESULT 4: COMPANY-WIDE PRICING BENCHMARKS
--
-- Business Question:
-- What are the overall gross margin and price realization
-- benchmarks across the full dataset?
--
-- Purpose:
-- Establish company-wide benchmarks for evaluating
-- individual customer pricing performance.
-- ============================================================

SELECT
    ROUND(
        SUM(gross_profit) /
        NULLIF(SUM(revenue), 0) * 100,
        2
    ) AS overall_gross_margin_pct,

    ROUND(
        SUM(revenue) /
        NULLIF(SUM(list_unit_price * quantity), 0) * 100,
        2
    ) AS overall_price_realization_pct

FROM orders;


-- ============================================================
-- RESULT 5: CUSTOMER PRICING REVIEW CANDIDATES
--
-- Business Question:
-- Which higher-revenue customers fall below both company-wide
-- gross margin and price realization benchmarks?
--
-- Purpose:
-- Identify customer accounts for further investigation
-- into pricing, product mix, costs, and commercial terms.
--
-- Screening Rules:
-- 1. Total customer revenue >= $50,000
-- 2. Gross margin below company-wide benchmark
-- 3. Price realization below company-wide benchmark
--
-- Notes:
-- The revenue threshold is an exploratory screening choice.
-- Benchmarks are calculated dynamically from the orders table.
-- Full-precision ratios are used for screening.
-- ============================================================

WITH customer_metrics AS (
    SELECT
        o.customer_id,
        c.customer_name,
        c.customer_segment,
        c.customer_tier,

        SUM(o.revenue) AS total_revenue,
        SUM(o.gross_profit) AS total_gross_profit,

        SUM(o.gross_profit) /
        NULLIF(SUM(o.revenue), 0) * 100
            AS gross_margin_pct,

        SUM(o.revenue) /
        NULLIF(SUM(o.list_unit_price * o.quantity), 0) * 100
            AS price_realization_pct

    FROM orders AS o
    INNER JOIN customers AS c
        ON o.customer_id = c.customer_id

    GROUP BY
        o.customer_id,
        c.customer_name,
        c.customer_segment,
        c.customer_tier
),

company_benchmarks AS (
    SELECT
        SUM(gross_profit) /
        NULLIF(SUM(revenue), 0) * 100
            AS benchmark_gross_margin_pct,

        SUM(revenue) /
        NULLIF(SUM(list_unit_price * quantity), 0) * 100
            AS benchmark_price_realization_pct

    FROM orders
)

SELECT
    cm.customer_id,
    cm.customer_name,
    cm.customer_segment,
    cm.customer_tier,
    cm.total_revenue,
    cm.total_gross_profit,

    ROUND(cm.gross_margin_pct, 2)
        AS gross_margin_pct,

    ROUND(cb.benchmark_gross_margin_pct, 2)
        AS benchmark_gross_margin_pct,

    ROUND(cm.price_realization_pct, 2)
        AS price_realization_pct,

    ROUND(cb.benchmark_price_realization_pct, 2)
        AS benchmark_price_realization_pct

FROM customer_metrics AS cm
CROSS JOIN company_benchmarks AS cb

WHERE cm.total_revenue >= 50000
    AND cm.gross_margin_pct < cb.benchmark_gross_margin_pct
    AND cm.price_realization_pct < cb.benchmark_price_realization_pct

ORDER BY cm.total_revenue DESC
LIMIT 20;

-- ============================================================
-- KEY FINDINGS
-- ============================================================
--
-- 1. Company-wide gross margin was 35.93%, with price
--    realization of 89.59% across 2023-2025.
--
-- 2. Contractors generated the highest segment revenue
--    ($10.26M), while Small Business customers achieved
--    the highest gross margin (38.86%).
--
-- 3. Strategic Enterprise customers recorded the lowest
--    gross margin (32.82%) and price realization (84.78%).
--
-- 4. Customer-level screening identified accounts with
--    at least $50,000 in revenue and both profitability
--    metrics below company-wide benchmarks.
--
-- 5. Differences in profitability warrant investigation
--    of product mix, costs, and commercial pricing terms.
--    The screening does not establish causation.
--
-- LIMITATIONS
-- - Synthetic dataset; findings are illustrative.
-- - Annual sales potential is assumed constant by year.
-- - Customer screening uses three-year cumulative revenue.
-- - The top-20 output is not a count of all qualifying
--   customers.
-- ============================================================