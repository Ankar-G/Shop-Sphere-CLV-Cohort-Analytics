											-- Shop Sphere – CLV & Cohort Analytics --
													-- Final Views --
                                                    
                                                    
-- V1. Core customer-level revenue, orders, AOV, first/last purchase

CREATE VIEW vw_customer_order_revenue_summary AS
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(order_value) AS total_revenue,
    AVG(order_value) AS average_order_value,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id;





-- V2. Measures purchase frequency, important for customer behaviour/CLV
CREATE VIEW vw_customer_order_frequency AS
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        COUNT(DISTINCT order_id) * 1.0 /
        NULLIF(DATEDIFF(MAX(order_date), MIN(order_date)) / 30.0, 0),
        2
    ) AS orders_per_month
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id;




-- V3. Recency is a core CLV/RFM metric
CREATE VIEW vw_customer_recency AS
SELECT
    customer_id,
    MAX(order_date) AS last_order_date,
    DATEDIFF(
        (SELECT MAX(order_date) FROM orders WHERE order_status = 'Delivered'),
        MAX(order_date)
    ) AS days_since_last_order
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id;




-- V4. Important repeat-purchase/retention KPI
CREATE VIEW vw_repeat_purchase_rate AS
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
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
) customer_orders;




-- V5. Excellent visualization of revenue and customers by value segment
CREATE VIEW vw_revenue_by_customer_segment AS
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
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
) customer_segments
GROUP BY customer_value_segment
ORDER BY total_revenue DESC;





-- V6. Core customer-level RFM segments
CREATE VIEW vw_rfm_customer_segments AS
WITH customer_rfm AS (
    SELECT
        customer_id,
        DATEDIFF(
            (SELECT MAX(order_date) FROM orders WHERE order_status = 'Delivered'),
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
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS monetary_score
    FROM customer_rfm
)
SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    CASE
        WHEN recency_score >= 4
             AND frequency_score >= 4
             AND monetary_score >= 4
            THEN 'Champions'
        WHEN recency_score >= 3
             AND frequency_score >= 4
             AND monetary_score >= 3
            THEN 'Loyal Customers'
        WHEN recency_score >= 4
             AND frequency_score <= 2
             AND monetary_score >= 3
            THEN 'Potential Loyalists'
        WHEN recency_score >= 4
             AND frequency_score <= 2
             AND monetary_score <= 2
            THEN 'New Customers'
        WHEN recency_score <= 2
             AND frequency_score >= 3
             AND monetary_score >= 3
            THEN 'At Risk'
        WHEN recency_score <= 2
             AND frequency_score <= 2
             AND monetary_score <= 2
            THEN 'Lost'
        ELSE 'Others'
    END AS customer_segment
FROM rfm_scores;




-- V7: RFM Segment Performance
CREATE VIEW vw_rfm_segment_performance AS
WITH customer_rfm AS (
    SELECT
        customer_id,
        DATEDIFF(
            (SELECT MAX(order_date) FROM orders WHERE order_status = 'Delivered'),
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
    FROM customer_rfm
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
    COUNT(*) AS customer_count,
    SUM(monetary) AS total_revenue,
    ROUND(AVG(monetary), 2) AS avg_customer_revenue
FROM segmented
GROUP BY customer_segment
ORDER BY total_revenue DESC;





-- V8: Cohort Retention Analysis
CREATE VIEW vw_cohort_retention_analysis AS
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
customer_activity AS (
    SELECT DISTINCT
        o.customer_id,
        DATE_FORMAT(fp.first_order_date, '%Y-%m-01') AS cohort_month,
        DATE_FORMAT(o.order_date, '%Y-%m-01') AS activity_month
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
    WHERE o.order_status = 'Delivered'
),
cohort_data AS (
    SELECT
        cohort_month,
        activity_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM customer_activity
    GROUP BY cohort_month, activity_month
)
SELECT
    cohort_month,
    activity_month,
    active_customers
FROM cohort_data
ORDER BY cohort_month, activity_month;





-- V9: Cohort Retention Rate
CREATE VIEW vw_cohort_retention_rate AS
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
customer_activity AS (
    SELECT DISTINCT
        o.customer_id,
        DATE_FORMAT(fp.first_order_date, '%Y-%m-01') AS cohort_month,
        DATE_FORMAT(o.order_date, '%Y-%m-01') AS activity_month
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
    WHERE o.order_status = 'Delivered'
),
cohort_data AS (
    SELECT
        cohort_month,
        activity_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM customer_activity
    GROUP BY cohort_month, activity_month
),
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_customers
    FROM customer_activity
    WHERE activity_month = cohort_month
    GROUP BY cohort_month
)
SELECT
    cd.cohort_month,
    cd.activity_month,
    cd.active_customers,
    cs.cohort_customers,
    ROUND(
        cd.active_customers * 100.0 / cs.cohort_customers,
        2
    ) AS retention_rate_pct
FROM cohort_data cd
JOIN cohort_size cs
    ON cd.cohort_month = cs.cohort_month
ORDER BY cd.cohort_month, cd.activity_month;





-- V10: Average Repeat-Purchase Interval
CREATE VIEW vw_avg_repeat_purchase_interval AS
WITH purchase_history AS (
    SELECT
        customer_id,
        order_date,
        LEAD(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS next_order_date
    FROM orders
    WHERE order_status = 'Delivered'
)
SELECT
    ROUND(
        AVG(DATEDIFF(next_order_date, order_date)),
        2
    ) AS avg_days_between_purchases
FROM purchase_history
WHERE next_order_date IS NOT NULL;




-- -- V11: CLV by Acquisition Channel
CREATE VIEW vw_clv_by_acquisition_channel AS
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
GROUP BY c.acquisition_channel;


-- V12: CLV by Purchase Frequency
CREATE VIEW vw_clv_by_purchase_frequency AS
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
GROUP BY purchase_frequency_segment;





-- V13: CLV by Average Order Value
CREATE VIEW vw_clv_by_aov AS
WITH customer_metrics AS (
    SELECT
        customer_id,
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
GROUP BY aov_segment;





-- V14: CLV by Return Behavior
CREATE VIEW vw_clv_by_return_behavior AS
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
GROUP BY return_behavior;





-- V15: CLV by Discount Behavior
CREATE VIEW vw_clv_by_discount_behavior AS
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
GROUP BY discount_segment;





-- V16: Customer CLV Distribution
CREATE VIEW vw_customer_clv_distribution AS
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
GROUP BY clv_range;





-- V17: Top 10 Customers by CLV
CREATE VIEW vw_top_10_customers_clv AS
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS clv
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id
ORDER BY clv DESC
LIMIT 10;




-- V18: CLV Contribution of Top 10 Customers
CREATE VIEW vw_top_10_clv_contribution AS
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





-- V19: Overall CLV Summary
CREATE VIEW vw_overall_clv_summary AS
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





-- USE shop_sphere;


-- V20 — Overall Profitability Summary
CREATE OR REPLACE VIEW vw_overall_profitability_summary AS
SELECT
    ROUND(SUM(order_value), 2) AS total_revenue,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(order_value) - SUM(discount), 2) AS revenue_after_discount
FROM orders
WHERE order_status = 'Delivered';





-- V21 — Shipping Cost by Shipping Type
CREATE OR REPLACE VIEW vw_shipping_cost_by_type AS
SELECT
    shipping_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_revenue,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(AVG(shipping_cost), 2) AS avg_shipping_cost,
    ROUND(
        SUM(shipping_cost) * 100.0 /
        NULLIF(SUM(order_value), 0), 2
    ) AS shipping_cost_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY shipping_type;





-- V22 — Discount Impact on Revenue
CREATE OR REPLACE VIEW vw_discount_impact_on_revenue AS
SELECT
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount < 10 THEN 'Low Discount'
        WHEN discount < 25 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_segment,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_revenue,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(AVG(order_value), 2) AS avg_order_value
FROM orders
WHERE order_status = 'Delivered'
GROUP BY discount_segment;





-- V23 — Revenue After Discount by Segment
CREATE OR REPLACE VIEW vw_revenue_after_discount_segment AS
SELECT
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount < 10 THEN 'Low Discount'
        WHEN discount < 25 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_segment,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS gross_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(order_value) - SUM(discount), 2) AS revenue_after_discount
FROM orders
WHERE order_status = 'Delivered'
GROUP BY discount_segment;





-- V24 — Revenue & Shipping Cost by Acquisition Channel
CREATE OR REPLACE VIEW vw_revenue_shipping_by_acquisition_channel AS
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.order_value), 2) AS total_revenue,
    ROUND(SUM(o.shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(o.shipping_cost) * 100.0 /
        NULLIF(SUM(o.order_value), 0), 2
    ) AS shipping_cost_pct
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel;





-- V25 — Revenue After Discount & Shipping Cost
CREATE OR REPLACE VIEW vw_revenue_after_discount_shipping AS
SELECT
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS revenue_after_discount_shipping
FROM orders
WHERE order_status = 'Delivered';





-- V6 — Net Revenue by Shipping Type
CREATE OR REPLACE VIEW vw_net_revenue_by_shipping_type AS
SELECT
    shipping_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS net_revenue_after_costs
FROM orders
WHERE order_status = 'Delivered'
GROUP BY shipping_type;





-- V27 — Net Revenue by Payment Method
CREATE OR REPLACE VIEW vw_net_revenue_by_payment_method AS
SELECT
    payment_method,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS net_revenue_after_costs
FROM orders
WHERE order_status = 'Delivered'
GROUP BY payment_method;





-- V28 — Net Revenue by Acquisition Campaign
CREATE OR REPLACE VIEW vw_net_revenue_by_acquisition_campaign AS
SELECT
    c.acquisition_campaign,
    c.acquisition_channel,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.order_value), 2) AS total_order_value,
    ROUND(SUM(o.discount), 2) AS total_discount,
    ROUND(SUM(o.shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(o.order_value) - SUM(o.discount) - SUM(o.shipping_cost), 2
    ) AS net_revenue_after_costs
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_campaign, c.acquisition_channel;





-- V29 — Net Revenue by Customer
CREATE OR REPLACE VIEW vw_net_revenue_by_customer AS
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS net_revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id;




-- V30 — Monthly Revenue & Cost Analysis
CREATE OR REPLACE VIEW vw_monthly_revenue_cost AS
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS net_revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY DATE_FORMAT(order_date, '%Y-%m');




-- V31 — Monthly Net Revenue Growth
CREATE OR REPLACE VIEW vw_monthly_net_revenue_growth AS
WITH monthly_data AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        SUM(order_value) - SUM(discount) - SUM(shipping_cost) AS net_revenue
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    order_month,
    ROUND(net_revenue, 2) AS net_revenue,
    ROUND(
        (net_revenue - LAG(net_revenue) OVER (ORDER BY order_month))
        * 100.0 /
        NULLIF(LAG(net_revenue) OVER (ORDER BY order_month), 0),
        2
    ) AS month_over_month_growth_pct
FROM monthly_data;





-- V32 — Discount Rate by Acquisition Channel
CREATE OR REPLACE VIEW vw_discount_rate_by_acquisition_channel AS
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.order_value), 2) AS total_order_value,
    ROUND(SUM(o.discount), 2) AS total_discount,
    ROUND(
        SUM(o.discount) * 100.0 /
        NULLIF(SUM(o.order_value), 0), 2
    ) AS discount_rate_pct
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel;





-- V33 — Profitability by Customer Acquisition Channel
CREATE OR REPLACE VIEW vw_profitability_by_acquisition_channel AS
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT o.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_order_value,
    ROUND(SUM(o.discount), 2) AS total_discount,
    ROUND(SUM(o.shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(o.order_value) - SUM(o.discount) - SUM(o.shipping_cost), 2
    ) AS contribution_revenue,
    ROUND(
        (
            SUM(o.order_value) - SUM(o.discount) - SUM(o.shipping_cost)
        ) * 100.0 /
        NULLIF(SUM(o.order_value), 0),
        2
    ) AS contribution_margin_pct
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel;





-- V34 — Profitability by Customer
CREATE OR REPLACE VIEW vw_profitability_by_customer AS
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS contribution_revenue,
    ROUND(
        (
            SUM(order_value) - SUM(discount) - SUM(shipping_cost)
        ) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS contribution_margin_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id;





-- V35 — Monthly Contribution Margin
CREATE OR REPLACE VIEW vw_monthly_contribution_margin AS
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS contribution_revenue,
    ROUND(
        (
            SUM(order_value) - SUM(discount) - SUM(shipping_cost)
        ) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS contribution_margin_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY DATE_FORMAT(order_date, '%Y-%m');





-- V36 — High-Discount Orders & Contribution
CREATE OR REPLACE VIEW vw_high_discount_orders AS
SELECT
    COUNT(DISTINCT order_id) AS high_discount_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS contribution_revenue
FROM orders
WHERE order_status = 'Delivered'
  AND discount >= 25;
  
  
  


-- V37 — Low-Value Orders with High Shipping Cost
CREATE OR REPLACE VIEW vw_low_value_high_shipping_orders AS
SELECT
    COUNT(DISTINCT order_id) AS affected_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(shipping_cost) * 100.0 /
        NULLIF(SUM(order_value), 0), 2
    ) AS shipping_cost_pct
FROM orders
WHERE order_status = 'Delivered'
  AND order_value < 1000
  AND shipping_cost > order_value * 0.20;
  
  


-- V38 — Customer Contribution by Acquisition Campaign
CREATE OR REPLACE VIEW vw_customer_contribution_by_campaign AS
SELECT
    c.acquisition_campaign,
    c.acquisition_channel,
    COUNT(DISTINCT o.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_order_value,
    ROUND(SUM(o.discount), 2) AS total_discount,
    ROUND(SUM(o.shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(o.order_value) - SUM(o.discount) - SUM(o.shipping_cost), 2
    ) AS contribution_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_campaign, c.acquisition_channel;





-- V39 — Contribution by Payment Method
CREATE OR REPLACE VIEW vw_contribution_by_payment_method AS
SELECT
    payment_method,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS contribution_revenue,
    ROUND(
        (
            SUM(order_value) - SUM(discount) - SUM(shipping_cost)
        ) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS contribution_margin_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY payment_method;





-- V40 — Contribution by Shipping Type
CREATE OR REPLACE VIEW vw_contribution_by_shipping_type AS
SELECT
    shipping_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS contribution_revenue,
    ROUND(
        (
            SUM(order_value) - SUM(discount) - SUM(shipping_cost)
        ) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS contribution_margin_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY shipping_type;





-- V41 — Contribution by Customer
CREATE OR REPLACE VIEW vw_contribution_by_customer AS
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS contribution_revenue,
    ROUND(
        (
            SUM(order_value) - SUM(discount) - SUM(shipping_cost)
        ) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS contribution_margin_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id;





-- V42 — Contribution by Month
CREATE OR REPLACE VIEW vw_contribution_by_month AS
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS contribution_revenue,
    ROUND(
        (
            SUM(order_value) - SUM(discount) - SUM(shipping_cost)
        ) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS contribution_margin_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY DATE_FORMAT(order_date, '%Y-%m');





-- V43 — Overall Contribution Summary
CREATE OR REPLACE VIEW vw_overall_contribution_summary AS
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS contribution_revenue,
    ROUND(
        (
            SUM(order_value) - SUM(discount) - SUM(shipping_cost)
        ) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS contribution_margin_pct
FROM orders
WHERE order_status = 'Delivered';





-- v44 — Negative Contribution Orders
CREATE OR REPLACE VIEW vw_negative_contribution_orders AS
SELECT
    order_id,
    customer_id,
    order_value,
    discount,
    shipping_cost,
    ROUND(
        order_value - discount - shipping_cost, 2
    ) AS contribution_revenue
FROM orders
WHERE order_status = 'Delivered'
  AND (order_value - discount - shipping_cost) < 0;
  
  
  


-- v45 — Negative Contribution Order Summary
CREATE OR REPLACE VIEW vw_negative_contribution_summary AS
SELECT
    COUNT(DISTINCT order_id) AS negative_contribution_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS total_negative_contribution
FROM orders
WHERE order_status = 'Delivered'
  AND (order_value - discount - shipping_cost) < 0;
  
  



-- v47 — Negative Contribution by Shipping Type
CREATE OR REPLACE VIEW vw_negative_contribution_by_shipping AS
SELECT
    shipping_type,
    COUNT(DISTINCT order_id) AS negative_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS contribution_revenue
FROM orders
WHERE order_status = 'Delivered'
  AND (order_value - discount - shipping_cost) < 0
GROUP BY shipping_type;




-- v48 — Negative Contribution by Payment Method
CREATE OR REPLACE VIEW vw_negative_contribution_by_payment AS
SELECT
    payment_method,
    COUNT(DISTINCT order_id) AS negative_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS contribution_revenue
FROM orders
WHERE order_status = 'Delivered'
  AND (order_value - discount - shipping_cost) < 0
GROUP BY payment_method;




-- v49 — Negative Contribution by Acquisition Channel
CREATE OR REPLACE VIEW vw_negative_contribution_by_acquisition AS
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT o.order_id) AS negative_orders,
    ROUND(SUM(o.order_value), 2) AS total_order_value,
    ROUND(SUM(o.discount), 2) AS total_discount,
    ROUND(SUM(o.shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(o.order_value) - SUM(o.discount) - SUM(o.shipping_cost), 2
    ) AS contribution_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
  AND (o.order_value - o.discount - o.shipping_cost) < 0
GROUP BY c.acquisition_channel;




-- v50 — Negative Contribution by Discount Segment
CREATE OR REPLACE VIEW vw_negative_contribution_by_discount AS
SELECT
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount < 10 THEN 'Low Discount'
        WHEN discount < 25 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_segment,
    COUNT(DISTINCT order_id) AS negative_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS contribution_revenue
FROM orders
WHERE order_status = 'Delivered'
  AND (order_value - discount - shipping_cost) < 0
GROUP BY discount_segment;




-- v51 — High Shipping Cost Orders
CREATE OR REPLACE VIEW vw_high_shipping_cost_orders AS
SELECT
    order_id,
    customer_id,
    order_value,
    shipping_cost,
    ROUND(
        shipping_cost * 100.0 /
        NULLIF(order_value, 0), 2
    ) AS shipping_cost_pct,
    ROUND(
        order_value - discount - shipping_cost, 2
    ) AS contribution_revenue
FROM orders
WHERE order_status = 'Delivered'
  AND shipping_cost > order_value * 0.20;
  
  


-- v52 — High Shipping Cost Order Summary
CREATE OR REPLACE VIEW vw_high_shipping_cost_summary AS
SELECT
    COUNT(DISTINCT order_id) AS high_shipping_cost_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(shipping_cost) * 100.0 /
        NULLIF(SUM(order_value), 0), 2
    ) AS shipping_cost_pct,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS contribution_revenue
FROM orders
WHERE order_status = 'Delivered'
  AND shipping_cost > order_value * 0.20;
  
  
  


-- v53 — Overall Profitability Dashboard KPIs
CREATE OR REPLACE VIEW vw_profitability_dashboard_kpis AS
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost), 2
    ) AS contribution_revenue,
    ROUND(
        (SUM(order_value) - SUM(discount) - SUM(shipping_cost))
        * 100.0 / NULLIF(SUM(order_value), 0),
        2
    ) AS contribution_margin_pct,
    SUM(
        CASE
            WHEN order_value - discount - shipping_cost < 0
            THEN 1 ELSE 0
        END
    ) AS negative_contribution_orders
FROM orders
WHERE order_status = 'Delivered';



-- v54. Channel Performance
CREATE VIEW vw_acq_channel_performance AS
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers_acquired,
    COUNT(DISTINCT CASE WHEN o.order_status = 'Delivered'
        THEN c.customer_id END) AS purchasing_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN o.order_status = 'Delivered'
        THEN c.customer_id END) * 100.0 /
        COUNT(DISTINCT c.customer_id), 2
    ) AS purchase_conversion_rate_pct
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.acquisition_channel;




-- v55. Campaign Performance
CREATE VIEW vw_acq_campaign_performance AS
SELECT
    c.acquisition_campaign,
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers_acquired,
    COUNT(DISTINCT CASE WHEN o.order_status = 'Delivered'
        THEN c.customer_id END) AS purchasing_customers,
    ROUND(SUM(CASE WHEN o.order_status = 'Delivered'
        THEN o.order_value ELSE 0 END), 2) AS total_revenue,
    ROUND(
        SUM(CASE WHEN o.order_status = 'Delivered'
        THEN o.order_value ELSE 0 END) /
        COUNT(DISTINCT c.customer_id), 2
    ) AS revenue_per_customer
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.acquisition_campaign, c.acquisition_channel;




-- V56. Overall Channel Performance
CREATE VIEW vw_acq_channel_overall AS
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers_acquired,
    COUNT(DISTINCT CASE WHEN o.order_status = 'Delivered'
        THEN c.customer_id END) AS purchasing_customers,
    COUNT(DISTINCT CASE WHEN o.order_status = 'Delivered'
        THEN o.order_id END) AS total_orders,
    ROUND(SUM(CASE WHEN o.order_status = 'Delivered'
        THEN o.order_value ELSE 0 END), 2) AS total_revenue,
    ROUND(AVG(CASE WHEN o.order_status = 'Delivered'
        THEN o.order_value END), 2) AS avg_order_value
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.acquisition_channel;




-- V57. High-Value Customer Rate
CREATE VIEW vw_acq_high_value_rate AS
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT CASE
        WHEN o.order_status = 'Delivered'
        AND o.order_value >= 50000 THEN c.customer_id
    END) AS high_value_customers
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.acquisition_channel;




-- V58. Customer & Revenue Share
CREATE VIEW vw_acq_customer_revenue_share AS
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel;




-- V59. Purchase Frequency
CREATE VIEW vw_acq_purchase_frequency AS
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(
        COUNT(DISTINCT o.order_id) /
        COUNT(DISTINCT c.customer_id), 2
    ) AS avg_orders_per_customer
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel;




-- V60. Return Rate
CREATE VIEW vw_acq_return_rate AS
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT r.order_id) AS returned_orders,
    ROUND(
        COUNT(DISTINCT r.order_id) * 100.0 /
        COUNT(DISTINCT o.order_id), 2
    ) AS return_rate_pct
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN returns r ON o.order_id = r.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel;




-- V61. Net Revenue After Refunds
CREATE VIEW vw_acq_net_revenue_refunds AS
SELECT
    c.acquisition_channel,
    ROUND(SUM(o.order_value), 2) AS gross_revenue,
    ROUND(COALESCE(SUM(r.refund_amount), 0), 2) AS total_refunds,
    ROUND(
        SUM(o.order_value) - COALESCE(SUM(r.refund_amount), 0), 2
    ) AS net_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN returns r ON c.customer_id = r.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel;