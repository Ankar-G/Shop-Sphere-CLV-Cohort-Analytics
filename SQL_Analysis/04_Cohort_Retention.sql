									        -- Shop Sphere – CLV & Cohort Analytics --
													-- Cohort Analysis --


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




-- 39. Cohort Retention Analysis
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE order_status = 'DELIVERED'
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
    WHERE o.order_status = 'DELIVERED'
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





-- 40 — Cohort Retention Rate
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE order_status = 'DELIVERED'
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
    WHERE o.order_status = 'DELIVERED'
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





-- 41 — Repeat Purchase Timing
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
    customer_id,
    order_date AS current_order_date,
    next_order_date,
    DATEDIFF(next_order_date, order_date) AS days_to_next_purchase
FROM purchase_history
WHERE next_order_date IS NOT NULL
ORDER BY customer_id, order_date;




-- 42 — Average Repeat-Purchase Interval
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
    ROUND(AVG(DATEDIFF(next_order_date, order_date)), 2)
        AS avg_days_between_purchases
FROM purchase_history
WHERE next_order_date IS NOT NULL;