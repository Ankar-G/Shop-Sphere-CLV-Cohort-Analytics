											-- Shop Sphere – CLV & Cohort Analytics --
													-- CLV Analysis --

-- 65 — Historical Customer Lifetime Value (CLV)
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS historical_clv
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id
ORDER BY historical_clv DESC;





-- 66 — CLV by Customer Segment
WITH customer_value AS (
    SELECT
        customer_id,
        SUM(order_value) AS historical_clv
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN historical_clv >= 50000 THEN 'High CLV'
        WHEN historical_clv >= 15000 THEN 'Medium CLV'
        ELSE 'Low CLV'
    END AS clv_segment,
    COUNT(*) AS customers,
    ROUND(SUM(historical_clv), 2) AS total_clv,
    ROUND(AVG(historical_clv), 2) AS avg_clv
FROM customer_value
GROUP BY clv_segment
ORDER BY avg_clv DESC;






-- 67 — Average Order Value by Customer
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_revenue,
    ROUND(AVG(order_value), 2) AS average_order_value
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id
ORDER BY average_order_value DESC;






-- 68 — CLV by Acquisition Channel
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_clv,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT c.customer_id),
        2
    ) AS avg_clv
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel
ORDER BY avg_clv DESC;





-- 69 — CLV by Customer Tenure
WITH customer_clv AS (
    SELECT
        customer_id,
        SUM(order_value) AS clv
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
customer_tenure AS (
    SELECT
        c.customer_id,
        DATEDIFF(
            MAX(o.order_date),
            c.signup_date
        ) AS tenure_days
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.signup_date
)
SELECT
    CASE
        WHEN ct.tenure_days < 90 THEN '0-3 Months'
        WHEN ct.tenure_days < 180 THEN '3-6 Months'
        WHEN ct.tenure_days < 365 THEN '6-12 Months'
        ELSE '1+ Year'
    END AS tenure_segment,
    COUNT(*) AS customers,
    ROUND(AVG(cc.clv), 2) AS avg_clv,
    ROUND(SUM(cc.clv), 2) AS total_clv
FROM customer_tenure ct
JOIN customer_clv cc
    ON ct.customer_id = cc.customer_id
GROUP BY tenure_segment
ORDER BY avg_clv DESC;





-- 70 — CLV by Purchase Frequency
WITH customer_metrics AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(order_value) AS clv
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN total_orders = 1 THEN '1 Order'
        WHEN total_orders BETWEEN 2 AND 3 THEN '2-3 Orders'
        WHEN total_orders BETWEEN 4 AND 6 THEN '4-6 Orders'
        ELSE '7+ Orders'
    END AS purchase_frequency_segment,
    COUNT(*) AS customers,
    ROUND(AVG(clv), 2) AS avg_clv,
    ROUND(SUM(clv), 2) AS total_clv
FROM customer_metrics
GROUP BY purchase_frequency_segment
ORDER BY avg_clv DESC;





-- 71 — CLV by Average Order Value
WITH customer_metrics AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(order_value) AS total_clv,
        AVG(order_value) AS avg_order_value
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN avg_order_value < 1000 THEN 'Low AOV'
        WHEN avg_order_value < 2500 THEN 'Medium AOV'
        ELSE 'High AOV'
    END AS aov_segment,
    COUNT(*) AS customers,
    ROUND(AVG(total_clv), 2) AS avg_clv,
    ROUND(SUM(total_clv), 2) AS total_clv
FROM customer_metrics
GROUP BY aov_segment
ORDER BY avg_clv DESC;





-- 72 — CLV by Customer Acquisition Campaign
SELECT
    c.acquisition_campaign,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_clv,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT c.customer_id),
        2
    ) AS avg_clv
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_campaign
ORDER BY avg_clv DESC;





-- 73 — CLV by Customer Age Group
SELECT
    CASE
        WHEN c.age < 25 THEN '18-24'
        WHEN c.age < 35 THEN '25-34'
        WHEN c.age < 45 THEN '35-44'
        WHEN c.age < 55 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_clv,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT c.customer_id),
        2
    ) AS avg_clv
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY age_group
ORDER BY avg_clv DESC;





-- 74 — CLV by Gender
SELECT
    c.gender,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_clv,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT c.customer_id),
        2
    ) AS avg_clv
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.gender
ORDER BY avg_clv DESC;





-- 75. CLV by Customer Location
SELECT
    c.state,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_clv,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT c.customer_id),
        2
    ) AS avg_clv
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.state
ORDER BY avg_clv DESC;





-- 76 — CLV by Return Behavior
WITH customer_clv AS (
    SELECT
        customer_id,
        SUM(order_value) AS clv
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
return_customers AS (
    SELECT DISTINCT customer_id
    FROM returns
)
SELECT
    CASE
        WHEN rc.customer_id IS NOT NULL THEN 'Returned'
        ELSE 'No Return'
    END AS return_behavior,
    COUNT(*) AS customers,
    ROUND(AVG(cc.clv), 2) AS avg_clv,
    ROUND(SUM(cc.clv), 2) AS total_clv
FROM customer_clv cc
LEFT JOIN return_customers rc
    ON cc.customer_id = rc.customer_id
GROUP BY return_behavior
ORDER BY avg_clv DESC;




-- 77 — CLV by Discount Behavior
WITH customer_metrics AS (
    SELECT
        customer_id,
        SUM(order_value) AS clv,
        AVG(discount) AS avg_discount
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN avg_discount = 0 THEN 'No Discount'
        WHEN avg_discount < 10 THEN 'Low Discount'
        WHEN avg_discount < 25 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_segment,
    COUNT(*) AS customers,
    ROUND(AVG(clv), 2) AS avg_clv,
    ROUND(SUM(clv), 2) AS total_clv,
    ROUND(AVG(avg_discount), 2) AS avg_discount
FROM customer_metrics
GROUP BY discount_segment
ORDER BY avg_clv DESC;





-- 78 — CLV by Payment Method
SELECT
    o.payment_method,
    COUNT(DISTINCT o.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_clv,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT o.customer_id),
        2
    ) AS avg_clv,
    ROUND(AVG(o.order_value), 2) AS avg_order_value
FROM orders o
WHERE o.order_status = 'Delivered'
GROUP BY o.payment_method
ORDER BY avg_clv DESC;





-- 79 — CLV by Shipping Type
SELECT
    o.shipping_type,
    COUNT(DISTINCT o.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_clv,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT o.customer_id),
        2
    ) AS avg_clv,
    ROUND(AVG(o.order_value), 2) AS avg_order_value
FROM orders o
WHERE o.order_status = 'Delivered'
GROUP BY o.shipping_type
ORDER BY avg_clv DESC;





-- 80 — CLV by Order Status
SELECT
    order_status,
    COUNT(DISTINCT customer_id) AS customers,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_value,
    ROUND(AVG(order_value), 2) AS avg_order_value
FROM orders
GROUP BY order_status
ORDER BY total_value DESC;






-- 81 — CLV by Customer Cohort
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    DATE_FORMAT(fp.first_order_date, '%Y-%m-01') AS cohort_month,
    COUNT(DISTINCT o.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_clv,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT o.customer_id),
        2
    ) AS avg_clv
FROM first_purchase fp
JOIN orders o
    ON fp.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY cohort_month
ORDER BY cohort_month;





-- 82 — CLV by Customer Segment (RFM)
WITH customer_metrics AS (
    SELECT
        customer_id,
        DATEDIFF(
            (SELECT MAX(order_date) FROM orders),
            MAX(order_date)
        ) AS recency,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(order_value) AS monetary
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS monetary_score
    FROM customer_metrics
),
segmented AS (
    SELECT *,
        CASE
            WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4
                THEN 'Champions'
            WHEN recency_score >= 3 AND frequency_score >= 4 AND monetary_score >= 3
                THEN 'Loyal Customers'
            WHEN recency_score >= 4 AND frequency_score <= 2 AND monetary_score >= 3
                THEN 'Potential Loyalists'
            WHEN recency_score >= 4 AND frequency_score <= 2 AND monetary_score <= 2
                THEN 'New Customers'
            WHEN recency_score <= 2 AND frequency_score >= 3 AND monetary_score >= 3
                THEN 'At Risk'
            WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score <= 2
                THEN 'Lost'
            ELSE 'Others'
        END AS customer_segment
    FROM rfm_scores
)
SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(SUM(monetary), 2) AS total_clv,
    ROUND(AVG(monetary), 2) AS avg_clv
FROM segmented
GROUP BY customer_segment
ORDER BY avg_clv DESC;





-- 83 — Customer CLV Distribution
WITH customer_clv AS (
    SELECT
        customer_id,
        SUM(order_value) AS clv
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN clv < 10000 THEN 'Below 10K'
        WHEN clv < 25000 THEN '10K-25K'
        WHEN clv < 50000 THEN '25K-50K'
        WHEN clv < 100000 THEN '50K-100K'
        ELSE '100K+'
    END AS clv_range,
    COUNT(*) AS customers,
    ROUND(SUM(clv), 2) AS total_clv,
    ROUND(AVG(clv), 2) AS avg_clv
FROM customer_clv
GROUP BY clv_range
ORDER BY MIN(clv);






-- Top 10 Customers by CLV
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS clv
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id
ORDER BY clv DESC
LIMIT 10;





-- 85 — Top 10 Customers by CLV
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS clv
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id
ORDER BY clv DESC
LIMIT 10;





-- 86 — CLV Contribution of Top 10 Customers
WITH customer_clv AS (
    SELECT
        customer_id,
        SUM(order_value) AS clv
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
top_10 AS (
    SELECT
        customer_id,
        clv
    FROM customer_clv
    ORDER BY clv DESC
    LIMIT 10
)
SELECT
    ROUND(SUM(t.clv), 2) AS top_10_clv,
    ROUND(
        SUM(t.clv) * 100.0 /
        (SELECT SUM(clv) FROM customer_clv),
        2
    ) AS top_10_clv_contribution_pct
FROM top_10 t;





-- 87 — Average Historical CLV
WITH customer_clv AS (
    SELECT
        customer_id,
        SUM(order_value) AS clv
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS total_customers,
    ROUND(SUM(clv), 2) AS total_clv,
    ROUND(AVG(clv), 2) AS average_historical_clv
FROM customer_clv;





-- 88 — CLV by Acquisition Channel
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_clv,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT c.customer_id),
        2
    ) AS avg_clv
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel
ORDER BY avg_clv DESC;






-- 89 — CLV by Acquisition Campaign
SELECT
    c.acquisition_campaign,
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_clv,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT c.customer_id),
        2
    ) AS avg_clv
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY
    c.acquisition_campaign,
    c.acquisition_channel
ORDER BY avg_clv DESC;






-- 90 — CLV by Customer Purchase Frequency
SELECT
    CASE
        WHEN total_orders = 1 THEN '1 Order'
        WHEN total_orders BETWEEN 2 AND 3 THEN '2-3 Orders'
        WHEN total_orders BETWEEN 4 AND 6 THEN '4-6 Orders'
        ELSE '7+ Orders'
    END AS frequency_segment,
    COUNT(*) AS customers,
    ROUND(AVG(clv), 2) AS avg_clv,
    ROUND(SUM(clv), 2) AS total_clv
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(order_value) AS clv
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
) customer_data
GROUP BY frequency_segment
ORDER BY avg_clv DESC;





-- 91 — CLV by Average Order Value
SELECT
    CASE
        WHEN avg_order_value < 1000 THEN 'Low AOV'
        WHEN avg_order_value < 2500 THEN 'Medium AOV'
        ELSE 'High AOV'
    END AS aov_segment,
    COUNT(*) AS customers,
    ROUND(AVG(clv), 2) AS avg_clv,
    ROUND(SUM(clv), 2) AS total_clv
FROM (
    SELECT
        customer_id,
        SUM(order_value) AS clv,
        AVG(order_value) AS avg_order_value
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
) customer_data
GROUP BY aov_segment
ORDER BY avg_clv DESC;





-- 92 — CLV by Customer Tenure
WITH customer_data AS (
    SELECT
        c.customer_id,
        DATEDIFF(MAX(o.order_date), c.signup_date) AS tenure_days,
        SUM(o.order_value) AS clv
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.signup_date
)
SELECT
    CASE
        WHEN tenure_days < 90 THEN '0-3 Months'
        WHEN tenure_days < 180 THEN '3-6 Months'
        WHEN tenure_days < 365 THEN '6-12 Months'
        ELSE '1+ Year'
    END AS tenure_segment,
    COUNT(*) AS customers,
    ROUND(AVG(clv), 2) AS avg_clv,
    ROUND(SUM(clv), 2) AS total_clv
FROM customer_data
GROUP BY tenure_segment
ORDER BY avg_clv DESC;






-- 93 — CLV by Age Group
SELECT
    CASE
        WHEN c.age < 25 THEN '18-24'
        WHEN c.age < 35 THEN '25-34'
        WHEN c.age < 45 THEN '35-44'
        WHEN c.age < 55 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_clv,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT c.customer_id),
        2
    ) AS avg_clv
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY age_group
ORDER BY avg_clv DESC;





--  94 — CLV by Gender
SELECT
    c.gender,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_clv,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT c.customer_id),
        2
    ) AS avg_clv
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.gender
ORDER BY avg_clv DESC;





-- 95 — CLV by State
SELECT
    c.state,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_clv,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT c.customer_id),
        2
    ) AS avg_clv
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.state
ORDER BY avg_clv DESC;






-- 96 — CLV by Return Behavior
WITH customer_clv AS (
    SELECT
        customer_id,
        SUM(order_value) AS clv
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
return_customers AS (
    SELECT DISTINCT customer_id
    FROM returns
)
SELECT
    CASE
        WHEN r.customer_id IS NOT NULL THEN 'Returned'
        ELSE 'No Return'
    END AS return_behavior,
    COUNT(*) AS customers,
    ROUND(AVG(c.clv), 2) AS avg_clv,
    ROUND(SUM(c.clv), 2) AS total_clv
FROM customer_clv c
LEFT JOIN return_customers r
    ON c.customer_id = r.customer_id
GROUP BY return_behavior
ORDER BY avg_clv DESC;





-- 97 — CLV by Discount Behavior8
WITH customer_metrics AS (
    SELECT
        customer_id,
        SUM(order_value) AS clv,
        AVG(discount) AS avg_discount
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN avg_discount = 0 THEN 'No Discount'
        WHEN avg_discount < 10 THEN 'Low Discount'
        WHEN avg_discount < 25 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_segment,
    COUNT(*) AS customers,
    ROUND(AVG(clv), 2) AS avg_clv,
    ROUND(SUM(clv), 2) AS total_clv,
    ROUND(AVG(avg_discount), 2) AS avg_discount
FROM customer_metrics
GROUP BY discount_segment
ORDER BY avg_clv DESC;





-- 98 — CLV by Payment Method
SELECT
    payment_method,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(order_value), 2) AS total_clv,
    ROUND(
        SUM(order_value) / COUNT(DISTINCT customer_id),
        2
    ) AS avg_clv
FROM orders
WHERE order_status = 'Delivered'
GROUP BY payment_method
ORDER BY avg_clv DESC;






-- 99 — CLV by Shipping Type
SELECT
    shipping_type,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(order_value), 2) AS total_clv,
    ROUND(
        SUM(order_value) / COUNT(DISTINCT customer_id),
        2
    ) AS avg_clv
FROM orders
WHERE order_status = 'Delivered'
GROUP BY shipping_type
ORDER BY avg_clv DESC;





-- 100 — Overall CLV Summary
WITH customer_clv AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(order_value) AS clv
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS total_customers,
    SUM(total_orders) AS total_orders,
    ROUND(SUM(clv), 2) AS total_clv,
    ROUND(AVG(clv), 2) AS average_clv,
    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer,
    ROUND(MAX(clv), 2) AS highest_customer_clv
FROM customer_clv; 




  