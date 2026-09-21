SELECT COUNT(*) FROM supply_chain;


-- # What is the overall business performance of the supply chain?
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::numeric, 2) AS total_revenue,
    ROUND(SUM(order_profit_per_order)::numeric, 2) AS total_profit,
    SUM(order_item_quantity) AS total_units_sold,
    ROUND(
        SUM(sales)::numeric / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value,
    ROUND(
        (SUM(order_profit_per_order) / SUM(sales) * 100)::numeric,
        2
    ) AS profit_margin
FROM supply_chain;


-- #How effectively is the supply chain meeting delivery expectations?
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END) AS late_risk_orders,
    ROUND(
        100.0 * SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS late_delivery_risk_rate,
    ROUND(AVG(days_for_shipping_real), 2) AS avg_actual_shipping_days,
    ROUND(AVG(days_for_shipment_scheduled), 2) AS avg_scheduled_shipping_days,
    ROUND(AVG(shipping_delay), 2) AS avg_shipping_delay
FROM supply_chain;



-- #Which product categories drive the most revenue and profit?
SELECT
    category_name,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::numeric, 2) AS total_revenue,
    ROUND(SUM(order_profit_per_order)::numeric, 2) AS total_profit,
    ROUND(
        (SUM(order_profit_per_order) / NULLIF(SUM(sales), 0) * 100)::numeric,
        2
    ) AS profit_margin
FROM supply_chain
GROUP BY category_name
ORDER BY total_revenue DESC
LIMIT 10;



-- #Which regions generate the most revenue and profit?
SELECT
    order_region,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::numeric, 2) AS total_revenue,
    ROUND(SUM(order_profit_per_order)::numeric, 2) AS total_profit,
    ROUND(
        (SUM(order_profit_per_order) / NULLIF(SUM(sales), 0) * 100)::numeric,
        2
    ) AS profit_margin,
    ROUND(AVG(shipping_delay), 2) AS avg_shipping_delay
FROM supply_chain
GROUP BY order_region
ORDER BY total_revenue DESC;


-- #How do shipping modes differ in shipping time, delay, and late-delivery risk?
SELECT
    shipping_mode,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::numeric, 2) AS total_revenue,
    ROUND(SUM(order_profit_per_order)::numeric, 2) AS total_profit,
    ROUND(AVG(days_for_shipping_real), 2) AS avg_shipping_days,
    ROUND(AVG(shipping_delay), 2) AS avg_shipping_delay,
    ROUND(
        100.0 * AVG(late_delivery_risk),
        2
    ) AS late_delivery_risk_rate
FROM supply_chain
GROUP BY shipping_mode
ORDER BY total_orders DESC;


-- # How does discount level relate to revenue and profit margin?
SELECT
    discount_band,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::numeric, 2) AS total_revenue,
    ROUND(SUM(order_profit_per_order)::numeric, 2) AS total_profit,
    ROUND(
        (SUM(order_profit_per_order) / NULLIF(SUM(sales), 0) * 100)::numeric,
        2
    ) AS profit_margin
FROM supply_chain
GROUP BY discount_band
ORDER BY
    CASE discount_band
        WHEN 'No Discount' THEN 1
        WHEN 'Low (1-5%)' THEN 2
        WHEN 'Medium (6-10%)' THEN 3
        WHEN 'High (11-20%)' THEN 4
        WHEN 'Very High (21-25%)' THEN 5
    END;


-- # How has revenue changed over time?
SELECT
    order_year,
    ROUND(SUM(sales)::numeric, 2) AS total_revenue,
    ROUND(SUM(order_profit_per_order)::numeric, 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders
FROM supply_chain
GROUP BY order_year
ORDER BY order_year;


-- # Which products generate the most revenue?
SELECT
    product_name,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::numeric, 2) AS total_revenue,
    ROUND(SUM(order_profit_per_order)::numeric, 2) AS total_profit
FROM supply_chain
GROUP BY product_name
ORDER BY total_revenue DESC
LIMIT 10;



--  Where are delivery risks highest?
SELECT
    order_region,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        100.0 * AVG(late_delivery_risk),
        2
    ) AS late_delivery_risk_rate,
    ROUND(AVG(shipping_delay), 2) AS avg_shipping_delay
FROM supply_chain
GROUP BY order_region
HAVING COUNT(DISTINCT order_id) >= 500
ORDER BY late_delivery_risk_rate DESC;



-- ##Which customer segments generate the most value

SELECT
    customer_segment,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::numeric, 2) AS total_revenue,
    ROUND(SUM(order_profit_per_order)::numeric, 2) AS total_profit,
    ROUND(
        SUM(sales)::numeric / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM supply_chain
GROUP BY customer_segment
ORDER BY total_revenue DESC;