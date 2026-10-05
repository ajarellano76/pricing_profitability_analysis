-- 02 price_waterfall_validation.sql
-- Purpose: Validate how discounts, promotions, rebates, and freight
-- Contribute to the difference between list value and actual revenue.

SELECT
    order_id,
    quantity,
    list_unit_price,
    (list_unit_price * quantity) AS list_value,
    discount_pct,
    (list_unit_price * quantity) * discount_pct AS discount_dollars,
    promotion_pct,
    (list_unit_price * quantity) * promotion_pct AS promotion_dollars,
    rebate_pct,
    (list_unit_price * quantity) * rebate_pct AS rebate_dollars,
    freight_fee,
    ROUND(((list_unit_price * quantity) - ((list_unit_price * quantity) * discount_pct) - ((list_unit_price * quantity) * promotion_pct) - ((list_unit_price * quantity) * rebate_pct) + freight_fee), 2) AS calculated_revenue,
    ROUND(((list_unit_price * quantity) * (1 - discount_pct) * (1 - promotion_pct) * (1 - rebate_pct) + freight_fee), 2) AS sequential_calculated_revenue,
    ROUND(revenue - (((list_unit_price * quantity) * (1 - discount_pct) * (1 - promotion_pct) * (1 - rebate_pct) + freight_fee)), 2) AS revenue_variance,
    revenue
FROM orders
LIMIT 10;
