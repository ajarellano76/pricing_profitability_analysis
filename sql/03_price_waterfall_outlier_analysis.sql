-- 03_price_waterfall_outlier_analysis.sql
-- Purpose: Evaluate the accuracy of the reconstructed pricing waterfall
-- and identify material revenue reconciliation outliers.
--
-- Revenue reconciliation indicates that discounts, promotions, and rebates
-- are applied sequentially to list value, with freight subsequently added.
--
-- Across 10,000 orders, the reconstructed pricing waterfall produced an
-- average absolute revenue variance of $0.13 and a maximum absolute variance
-- of $4.63 versus recorded revenue.
--
-- Outliers are evaluated using both absolute dollar variance and percentage
-- variance to distinguish financial magnitude from relative materiality.


-- ============================================================
-- Result 1: Revenue Reconciliation Summary
-- Evaluate overall accuracy of the reconstructed pricing waterfall
-- ============================================================

SELECT
    ROUND(
        AVG(
            ABS(
                revenue - (
                    (list_unit_price * quantity)
                    * (1 - discount_pct)
                    * (1 - promotion_pct)
                    * (1 - rebate_pct)
                    + freight_fee
                )
            )
        ),
        2
    ) AS avg_absolute_revenue_variance,

    ROUND(
        MAX(
            ABS(
                revenue - (
                    (list_unit_price * quantity)
                    * (1 - discount_pct)
                    * (1 - promotion_pct)
                    * (1 - rebate_pct)
                    + freight_fee
                )
            )
        ),
        2
    ) AS max_absolute_revenue_variance,

    ROUND(
        MIN(
            ABS(
                revenue - (
                    (list_unit_price * quantity)
                    * (1 - discount_pct)
                    * (1 - promotion_pct)
                    * (1 - rebate_pct)
                    + freight_fee
                )
            )
        ),
        2
    ) AS min_absolute_revenue_variance,

    ROUND(
        SUM(
            ABS(
                revenue - (
                    (list_unit_price * quantity)
                    * (1 - discount_pct)
                    * (1 - promotion_pct)
                    * (1 - rebate_pct)
                    + freight_fee
                )
            )
        ),
        2
    ) AS sum_absolute_revenue_variance

FROM orders;


-- ============================================================
-- Result 2: Top 10 Dollar Variance Outliers
-- Rank transactions by absolute financial discrepancy
-- ============================================================

WITH revenue_reconciliation AS (
    SELECT
        order_id,
        revenue,

        ROUND(
            (list_unit_price * quantity)
            * (1 - discount_pct)
            * (1 - promotion_pct)
            * (1 - rebate_pct)
            + freight_fee,
            2
        ) AS sequential_calculated_revenue,

        ROUND(
            revenue - (
                (list_unit_price * quantity)
                * (1 - discount_pct)
                * (1 - promotion_pct)
                * (1 - rebate_pct)
                + freight_fee
            ),
            2
        ) AS revenue_variance

    FROM orders
),

variance_metrics AS (
    SELECT
        order_id,
        revenue,
        sequential_calculated_revenue,
        revenue_variance,

        ABS(revenue_variance) AS absolute_dollar_variance,

        ROUND(
            (ABS(revenue_variance) / NULLIF(revenue, 0)) * 100,
            4
        ) AS absolute_variance_pct

    FROM revenue_reconciliation
)

-- Final Result #2

SELECT
    order_id,
    revenue,
    sequential_calculated_revenue,
    revenue_variance,
    absolute_dollar_variance,
    absolute_variance_pct,

    RANK() OVER (
        ORDER BY absolute_dollar_variance DESC
    ) AS dollar_variance_rank,

    RANK() OVER (
        ORDER BY absolute_variance_pct DESC
    ) AS pct_variance_rank

FROM variance_metrics
ORDER BY dollar_variance_rank
LIMIT 10;


-- ============================================================
-- Result 3: Top 10 Percentage Variance Outliers
-- Rank transactions by relative discrepancy to recorded revenue
-- ============================================================

WITH revenue_reconciliation AS (
    SELECT
        order_id,
        revenue,

        ROUND(
            (list_unit_price * quantity)
            * (1 - discount_pct)
            * (1 - promotion_pct)
            * (1 - rebate_pct)
            + freight_fee,
            2
        ) AS sequential_calculated_revenue,

        ROUND(
            revenue - (
                (list_unit_price * quantity)
                * (1 - discount_pct)
                * (1 - promotion_pct)
                * (1 - rebate_pct)
                + freight_fee
            ),
            2
        ) AS revenue_variance

    FROM orders
),

variance_metrics AS (
    SELECT
        order_id,
        revenue,
        sequential_calculated_revenue,
        revenue_variance,

        ABS(revenue_variance) AS absolute_dollar_variance,

        ROUND(
            (ABS(revenue_variance) / NULLIF(revenue, 0)) * 100,
            4
        ) AS absolute_variance_pct

    FROM revenue_reconciliation
)

-- Final Result #3

SELECT
    order_id,
    revenue,
    sequential_calculated_revenue,
    revenue_variance,
    absolute_dollar_variance,
    absolute_variance_pct,

    RANK() OVER (
        ORDER BY absolute_dollar_variance DESC
    ) AS dollar_variance_rank,

    RANK() OVER (
        ORDER BY absolute_variance_pct DESC
    ) AS pct_variance_rank

FROM variance_metrics
ORDER BY pct_variance_rank
LIMIT 10;


-- ============================================================
-- Result 4: Variance by Pricing Adjustment Count
-- Evaluate whether reconciliation variance increases as additional
-- discounts, promotions, and rebates are applied to an order
-- ============================================================

WITH adjustment_analysis AS (
    SELECT
        order_id,

        CASE
            WHEN discount_pct > 0 THEN 1
            ELSE 0
        END
        +
        CASE
            WHEN promotion_pct > 0 THEN 1
            ELSE 0
        END
        +
        CASE
            WHEN rebate_pct > 0 THEN 1
            ELSE 0
        END AS adjustment_count,

        ABS(
            revenue - (
                (list_unit_price * quantity)
                * (1 - discount_pct)
                * (1 - promotion_pct)
                * (1 - rebate_pct)
                + freight_fee
            )
        ) AS absolute_revenue_variance

    FROM orders
)

-- Final Result #4

SELECT
    adjustment_count,
    COUNT(*) AS order_count,

    ROUND(
        AVG(absolute_revenue_variance),
        2
    ) AS avg_absolute_variance,

    ROUND(
        MAX(absolute_revenue_variance),
        2
    ) AS max_absolute_variance

FROM adjustment_analysis
GROUP BY adjustment_count
ORDER BY adjustment_count;

-- ============================================================
-- Key Finding
-- ============================================================

-- Average absolute revenue variance increased as additional pricing
-- adjustments were applied:
--
-- 0 adjustments: $0.02 average absolute variance
-- 1 adjustment:  $0.11 average absolute variance
-- 2 adjustments: $0.14 average absolute variance
-- 3 adjustments: $0.18 average absolute variance
--
-- This indicates that reconciliation variance tends to increase with
-- pricing adjustment complexity. The relationship is associative and
-- does not by itself establish that additional adjustments cause the
-- observed variance.

-- ============================================================
-- SUMMARY: 03_price_waterfall_outlier_analysis

-- Result 1 → Is our reconstructed waterfall accurate overall?

-- Result 2 → Where are the largest dollar discrepancies?

-- Result 3 → Where are the largest relative discrepancies?

-- Result 4 → Is discrepancy magnitude associated with pricing complexity?
-- ============================================================
