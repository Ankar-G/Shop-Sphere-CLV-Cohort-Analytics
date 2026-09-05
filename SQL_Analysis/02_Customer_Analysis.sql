                                                -- Shop Sphere – CLV & Cohort Analytics --
													 -- Customer Analysis  --



-- 25. Customer Order & Revenue Summary
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(order_value) AS total_revenue,
    AVG(order_value) AS average_order_value,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM orders
WHERE order_status = 'DELIVERED'
GROUP BY customer_id;



-- 26. Customer Revenue Ranking
SELECT
    customer_id,
    SUM(order_value) AS total_revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id
ORDER BY total_revenue DESC;



-- 27. Revenue Contribution by Customer
SELECT
    customer_id,
    SUM(order_value) AS customer_revenue,
    ROUND(
        SUM(order_value) * 100.0 /
        (SELECT SUM(order_value)
         FROM orders
         WHERE order_status = 'DELIVERED'),
        2
    ) AS revenue_contribution_pct
FROM orders
WHERE order_status = 'DELIVERED'
GROUP BY customer_id
ORDER BY customer_revenue DESC;



-- 28. Customer Order Frequency
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        COUNT(DISTINCT order_id) * 1.0 /
        NULLIF(DATEDIFF(MAX(order_date), MIN(order_date)) / 30.0, 0),
        2
    ) AS orders_per_month
FROM orders
WHERE order_status = 'DELIVERED'
GROUP BY customer_id
ORDER BY orders_per_month DESC;



-- 29. Customer Recency
SELECT
    customer_id,
    MAX(order_date) AS last_order_date,
    DATEDIFF(
        (SELECT MAX(order_date) FROM orders),
        MAX(order_date)
    ) AS days_since_last_order
FROM orders
WHERE order_status = 'DELIVERED'
GROUP BY customer_id
ORDER BY days_since_last_order ASC;



-- 30. Customer Tenure
SELECT
    c.customer_id,
    c.signup_date,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date,
    DATEDIFF(
        MAX(o.order_date),
        c.signup_date
    ) AS customer_tenure_days
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'DELIVERED'
GROUP BY
    c.customer_id,
    c.signup_date
ORDER BY customer_tenure_days DESC;



-- 31. Repeat Purchase Customers
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
WHERE order_status = 'DELIVERED'
GROUP BY customer_id
HAVING COUNT(DISTINCT order_id) > 1
ORDER BY total_orders DESC;



-- 32. Repeat Purchase Rate
SELECT
    ROUND(
        COUNT(CASE WHEN total_orders > 1 THEN 1 END) * 100.0
        / COUNT(*),
        2
    ) AS repeat_purchase_rate_pct
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    WHERE order_status = 'DELIVERED'
    GROUP BY customer_id
) customer_orders;



-- 33. Customer Revenue Segmentation
SELECT
    customer_id,
    SUM(order_value) AS total_revenue,
    CASE
        WHEN SUM(order_value) >= 50000 THEN 'High Value'
        WHEN SUM(order_value) >= 15000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_value_segment
FROM orders
WHERE order_status = 'DELIVERED'
GROUP BY customer_id
ORDER BY total_revenue DESC;




-- 34. Revenue Contribution by Customer Segment
SELECT
    customer_value_segment,
    COUNT(*) AS customers,
    SUM(total_revenue) AS total_revenue,
    ROUND(
        SUM(total_revenue) * 100.0 /
        (SELECT SUM(total_revenue)
         FROM (
             SELECT
                 customer_id,
                 SUM(order_value) AS total_revenue
             FROM orders
             WHERE order_status = 'Delivered'
             GROUP BY customer_id
         ) x),
        2
    ) AS revenue_contribution_pct
FROM (
    SELECT
        customer_id,
        SUM(order_value) AS total_revenue,
        CASE
            WHEN SUM(order_value) >= 50000 THEN 'High Value'
            WHEN SUM(order_value) >= 15000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_value_segment
    FROM orders
    WHERE order_status = 'DELIVERED'
    GROUP BY customer_id
) customer_segments
GROUP BY customer_value_segment
ORDER BY total_revenue DESC;
