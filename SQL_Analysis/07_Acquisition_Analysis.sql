                                            -- Shop Sphere – CLV & Cohort Analytics --
													-- Acquision Analysis --




-- 43 — Revenue by Acquisition Channel
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.order_value) AS total_revenue,
    ROUND(AVG(o.order_value), 2) AS avg_order_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'DELIVERED'
GROUP BY c.acquisition_channel
ORDER BY total_revenue DESC;




-- 44 — Customer Acquisition Channel Performance
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers_acquired,
    COUNT(DISTINCT CASE 
        WHEN o.order_status = 'Delivered' THEN c.customer_id 
    END) AS purchasing_customers,
    ROUND(
        COUNT(DISTINCT CASE 
            WHEN o.order_status = 'Delivered' THEN c.customer_id 
        END) * 100.0 /
        COUNT(DISTINCT c.customer_id),
        2
    ) AS purchase_conversion_rate_pct
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.acquisition_channel
ORDER BY customers_acquired DESC;





-- 45 — Acquisition Campaign Performance
SELECT
    c.acquisition_campaign,
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers_acquired,
    COUNT(DISTINCT CASE
        WHEN o.order_status = 'Delivered' THEN c.customer_id
    END) AS purchasing_customers,
    SUM(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_value
        ELSE 0
    END) AS total_revenue,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
            ELSE 0
        END) / COUNT(DISTINCT c.customer_id),
        2
    ) AS revenue_per_acquired_customer
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.acquisition_campaign,
    c.acquisition_channel
ORDER BY total_revenue DESC;





-- 46 — Customer Value by Acquisition Channel
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_revenue,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT c.customer_id),
        2
    ) AS revenue_per_customer
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel
ORDER BY revenue_per_customer DESC;






-- 47 — Acquisition Channel: Repeat Purchase Rate
WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.acquisition_channel,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
        AND o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.acquisition_channel
)
SELECT
    acquisition_channel,
    COUNT(*) AS customers,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(
        SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS repeat_purchase_rate_pct
FROM customer_orders
GROUP BY acquisition_channel
ORDER BY repeat_purchase_rate_pct DESC;





-- 48 — Acquisition Channel: Average Customer Revenue
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.acquisition_channel,
        COALESCE(SUM(
            CASE 
                WHEN o.order_status = 'Completed' THEN o.order_value
                ELSE 0
            END
        ), 0) AS total_revenue
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.acquisition_channel
)
SELECT
    acquisition_channel,
    COUNT(*) AS customers,
    ROUND(AVG(total_revenue), 2) AS avg_customer_revenue,
    ROUND(MAX(total_revenue), 2) AS highest_customer_revenue
FROM customer_revenue
GROUP BY acquisition_channel
ORDER BY avg_customer_revenue DESC;






-- 49 — Acquisition Campaign: Repeat Purchase Performance
WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.acquisition_campaign,
        c.acquisition_channel,
        COUNT(DISTINCT CASE
            WHEN o.order_status = 'Delivered' THEN o.order_id
        END) AS total_orders
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id,
        c.acquisition_campaign,
        c.acquisition_channel
)
SELECT
    acquisition_campaign,
    acquisition_channel,
    COUNT(*) AS customers,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(
        SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS repeat_purchase_rate_pct
FROM customer_orders
GROUP BY
    acquisition_campaign,
    acquisition_channel
ORDER BY repeat_purchase_rate_pct DESC;






-- 50 — Acquisition Channel: Customer Retention
WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.acquisition_channel,
        COUNT(DISTINCT CASE
            WHEN o.order_status = 'Delivered' THEN o.order_id
        END) AS total_orders
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.acquisition_channel
)
SELECT
    acquisition_channel,
    COUNT(*) AS customers,
    SUM(CASE WHEN total_orders >= 2 THEN 1 ELSE 0 END) AS retained_customers,
    ROUND(
        SUM(CASE WHEN total_orders >= 2 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS retention_rate_pct
FROM customer_orders
GROUP BY acquisition_channel
ORDER BY retention_rate_pct DESC;






-- 51 — Acquisition Channel Overall Performance
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.acquisition_channel,
        COUNT(DISTINCT CASE
            WHEN o.order_status = 'Delivered' THEN o.order_id
        END) AS total_orders,
        COALESCE(SUM(
            CASE
                WHEN o.order_status = 'Delivered' THEN o.order_value
                ELSE 0
            END
        ), 0) AS total_revenue
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.acquisition_channel
)
SELECT
    acquisition_channel,
    COUNT(*) AS customers_acquired,
    SUM(CASE WHEN total_orders > 0 THEN 1 ELSE 0 END) AS purchasing_customers,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(
        SUM(CASE WHEN total_orders > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS purchase_rate_pct,
    ROUND(
        SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS repeat_purchase_rate_pct,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_customer
FROM customer_metrics
GROUP BY acquisition_channel
ORDER BY total_revenue DESC;






-- 52 — Acquisition Channel: High-Value Customer Rate
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.acquisition_channel,
        COALESCE(SUM(
            CASE
                WHEN o.order_status = 'Delivered'
                THEN o.order_value
                ELSE 0
            END
        ), 0) AS total_revenue
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.acquisition_channel
)
SELECT
    acquisition_channel,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN total_revenue >= 50000 THEN 1 ELSE 0 END) AS high_value_customers,
    ROUND(
        SUM(CASE WHEN total_revenue >= 50000 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS high_value_customer_rate_pct
FROM customer_revenue
GROUP BY acquisition_channel
ORDER BY high_value_customer_rate_pct DESC;







-- 53 — Acquisition Campaign Revenue Efficiency
SELECT
    c.acquisition_campaign,
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers_acquired,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
            ELSE 0
        END), 2
    ) AS total_revenue,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
            ELSE 0
        END) / COUNT(DISTINCT c.customer_id),
        2
    ) AS revenue_per_acquired_customer
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.acquisition_campaign,
    c.acquisition_channel
ORDER BY revenue_per_acquired_customer DESC;






-- 54 — Acquisition Channel: Average Order Value
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(o.order_value), 2) AS avg_order_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel
ORDER BY avg_order_value DESC;





-- 55 — Acquisition Campaign Customer Value
SELECT
    c.acquisition_campaign,
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_revenue,
    ROUND(AVG(o.order_value), 2) AS avg_order_value,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT c.customer_id),
        2
    ) AS revenue_per_customer
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY
    c.acquisition_campaign,
    c.acquisition_channel
ORDER BY revenue_per_customer DESC;





-- 56 — Acquisition Channel Customer Count & Revenue Share
WITH channel_data AS (
    SELECT
        c.acquisition_channel,
        COUNT(DISTINCT c.customer_id) AS customers,
        SUM(o.order_value) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.acquisition_channel
)
SELECT
    acquisition_channel,
    customers,
    ROUND(revenue, 2) AS total_revenue,
    ROUND(
        customers * 100.0 / SUM(customers) OVER (),
        2
    ) AS customer_share_pct,
    ROUND(
        revenue * 100.0 / SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct
FROM channel_data
ORDER BY revenue_share_pct DESC;





-- 57 — Acquisition Channel: Customer Lifetime Activity
WITH customer_activity AS (
    SELECT
        c.customer_id,
        c.acquisition_channel,
        MIN(o.order_date) AS first_order_date,
        MAX(o.order_date) AS last_order_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.acquisition_channel
)
SELECT
    acquisition_channel,
    COUNT(*) AS customers,
    ROUND(
        AVG(DATEDIFF(last_order_date, first_order_date)),
        2
    ) AS avg_active_days
FROM customer_activity
GROUP BY acquisition_channel
ORDER BY avg_active_days DESC;




-- 58 — Acquisition Channel: Average Purchase Frequency
WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.acquisition_channel,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.acquisition_channel
)
SELECT
    acquisition_channel,
    COUNT(*) AS purchasing_customers,
    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer
FROM customer_orders
GROUP BY acquisition_channel
ORDER BY avg_orders_per_customer DESC;





-- 59 — Acquisition Channel: Return Rate
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    COUNT(DISTINCT r.order_id) AS returned_orders,
    ROUND(
        COUNT(DISTINCT r.order_id) * 100.0 /
        COUNT(DISTINCT o.order_id),
        2
    ) AS return_rate_pct
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
LEFT JOIN returns r
    ON o.order_id = r.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel
ORDER BY return_rate_pct DESC;





-- 60 — Acquisition Channel: Refund Impact
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT r.return_id) AS total_returns,
    ROUND(SUM(r.refund_amount), 2) AS total_refund_amount,
    ROUND(AVG(r.refund_amount), 2) AS avg_refund_amount
FROM customers c
JOIN returns r
    ON c.customer_id = r.customer_id
GROUP BY c.acquisition_channel
ORDER BY total_refund_amount DESC;





-- 61 — Acquisition Channel: Net Revenue After Refunds
WITH revenue AS (
    SELECT
        c.acquisition_channel,
        SUM(o.order_value) AS gross_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.acquisition_channel
),
refunds AS (
    SELECT
        c.acquisition_channel,
        SUM(r.refund_amount) AS total_refunds
    FROM customers c
    JOIN returns r
        ON c.customer_id = r.customer_id
    GROUP BY c.acquisition_channel
)
SELECT
    rev.acquisition_channel,
    ROUND(rev.gross_revenue, 2) AS gross_revenue,
    ROUND(COALESCE(ref.total_refunds, 0), 2) AS total_refunds,
    ROUND(
        rev.gross_revenue - COALESCE(ref.total_refunds, 0),
        2
    ) AS net_revenue
FROM revenue rev
LEFT JOIN refunds ref
    ON rev.acquisition_channel = ref.acquisition_channel
ORDER BY net_revenue DESC;






-- 62 — Acquisition Channel: CLV Proxy
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_revenue,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT c.customer_id),
        2
    ) AS revenue_per_customer
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel
ORDER BY revenue_per_customer DESC;






-- 63 — Best Acquisition Channel Summary
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(o.order_value), 2) AS total_revenue,
    ROUND(AVG(o.order_value), 2) AS avg_order_value,
    ROUND(
        SUM(o.order_value) / COUNT(DISTINCT c.customer_id),
        2
    ) AS revenue_per_customer
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel
ORDER BY revenue_per_customer DESC;





-- 64 — Acquisition Campaign Performance Summary
SELECT
    c.acquisition_campaign,
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT CASE
        WHEN o.order_status = 'Delivered' THEN o.order_id
    END) AS completed_orders,
    ROUND(SUM(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_value
        ELSE 0
    END), 2) AS total_revenue,
    ROUND(AVG(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_value
    END), 2) AS avg_order_value,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
            ELSE 0
        END) / COUNT(DISTINCT c.customer_id),
        2
    ) AS revenue_per_customer
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.acquisition_campaign,
    c.acquisition_channel
ORDER BY total_revenue DESC;