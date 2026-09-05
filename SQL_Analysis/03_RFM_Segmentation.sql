                                                -- Shop Sphere – CLV & Cohort Analytics --
													-- RFM Segementation --



-- 35. RFM Customer Segmentation
WITH customer_rfm AS (
    SELECT
        customer_id,
        DATEDIFF(
            (SELECT MAX(order_date) FROM orders),
            MAX(order_date)
        ) AS recency,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(order_value) AS monetary
    FROM orders
    WHERE order_status = 'DELIVERED'
    GROUP BY customer_id
)
SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY recency DESC) AS recency_score,
    NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
    NTILE(5) OVER (ORDER BY monetary ASC) AS monetary_score
FROM customer_rfm;



-- 36. RFM Customer Segments
WITH customer_rfm AS (
    SELECT
        customer_id,
        DATEDIFF(
            (SELECT MAX(order_date) FROM orders),
            MAX(order_date)
        ) AS recency,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(order_value) AS monetary
    FROM orders
    WHERE order_status = 'DELIVERED'
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



-- 37. Segment Performance
WITH customer_rfm AS (
    SELECT
        customer_id,
        DATEDIFF(
            (SELECT MAX(order_date) FROM orders),
            MAX(order_date)
        ) AS recency,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(order_value) AS monetary
    FROM orders
    WHERE order_status = 'DELIVERED'
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



-- 38. Customer Cohort Assignment
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE order_status = 'DELIVERED'
    GROUP BY customer_id
)
SELECT
    customer_id,
    first_order_date,
    DATE_FORMAT(first_order_date, '%Y-%m-01') AS cohort_month
FROM first_purchase
ORDER BY cohort_month, customer_id;