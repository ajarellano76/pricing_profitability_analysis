-- 01_product_pricing_analysis
-- Purpose: Analyze product-level pricing, revenue, profitability, and price realization
-- to identify key drivers of financial perfromance and pontential pricing opportunities.

WITH product_metrics AS (
    SELECT
        p.product_name,
        SUM(o.quantity) AS total_units,
        SUM(o.revenue) AS total_revenue,
        SUM(o.list_unit_price * o.quantity) AS total_list_value,
        SUM(o.total_cost) AS total_cost,
        SUM(o.gross_profit) AS total_gross_profit,
        SUM((o.list_unit_price * o.quantity) * o.discount_pct) AS total_discount_dollars,
        SUM((o.list_unit_price * o.quantity) * o.promotion_pct) AS total_promotion_dollars,
        SUM((o.list_unit_price * o.quantity) * o.rebate_pct) AS total_rebate_dollars
    FROM orders AS o
    INNER JOIN products AS p
        ON o.product_id = p.product_id
    GROUP BY p.product_name
),

pricing_reconciliation AS (
SELECT
    product_name,
    total_units,
    total_revenue,
    total_list_value,
    total_cost,
    total_gross_profit,
    total_discount_dollars,
    total_promotion_dollars,
    total_rebate_dollars,
    ROUND(total_revenue / total_units, 2) AS avg_selling_price,
    ROUND(total_revenue / total_list_value * 100, 2) AS price_realization_pct,
    ROUND(100 - ((total_revenue / total_list_value) * 100), 2) AS discount_from_list_pct,
    ROUND(total_discount_dollars / total_list_value * 100, 2) AS weighted_discount_pct,
    ROUND(total_gross_profit / total_revenue * 100, 2) AS gross_margin_pct,
    ROUND(total_gross_profit / total_units, 2) AS gross_profit_per_unit, 
    ROUND(total_cost / total_units, 2) AS cost_per_unit,
    ROUND(total_gross_profit - (total_revenue - total_cost), 2) AS gross_profit_variance,
    ROUND((total_list_value - total_revenue), 2) AS actual_dollar_gap,
    ROUND(total_discount_dollars + total_promotion_dollars + total_rebate_dollars, 2) AS calculated_adjustment_dollars
FROM product_metrics
WHERE total_revenue >= 1000000
)

SELECT
    *,
    ROUND(calculated_adjustment_dollars - actual_dollar_gap, 2) AS price_adjustment_variance
FROM pricing_reconciliation
ORDER BY gross_margin_pct DESC
