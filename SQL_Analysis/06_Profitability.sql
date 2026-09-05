                                           -- Shop Sphere – CLV & Cohort Analytics --
													-- Profitability --



-- 101 — Overall Profitability Summary
SELECT
    ROUND(SUM(order_value), 2) AS total_revenue,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(
        SUM(order_value) - SUM(discount),
        2
    ) AS revenue_after_discount
FROM orders
WHERE order_status = 'Delivered';





-- 102 — Profitability by Product Category
SELECT
    oi.product_id,
    ROUND(SUM(oi.item_revenue), 2) AS total_revenue,
    ROUND(SUM(oi.discount), 2) AS total_discount,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(AVG(oi.unit_price), 2) AS avg_unit_price
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY oi.product_id
ORDER BY total_revenue DESC;





-- 103 — Revenue by Product Category
SELECT
    oi.product_id,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.item_revenue), 2) AS total_revenue,
    ROUND(AVG(oi.item_revenue), 2) AS avg_item_revenue
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY oi.product_id
ORDER BY total_revenue DESC;






-- 104 — Shipping Cost by Order
SELECT
    order_id,
    order_value,
    shipping_cost,
    ROUND(
        shipping_cost * 100.0 / NULLIF(order_value, 0),
        2
    ) AS shipping_cost_pct
FROM orders
WHERE order_status = 'Delivered'
ORDER BY shipping_cost_pct DESC;





-- 105 — Shipping Cost by Shipping Type
SELECT
    shipping_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_revenue,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(AVG(shipping_cost), 2) AS avg_shipping_cost,
    ROUND(
        SUM(shipping_cost) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS shipping_cost_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY shipping_type
ORDER BY shipping_cost_pct DESC;





-- 106 — Discount Impact on Revenue
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
GROUP BY discount_segment
ORDER BY total_revenue DESC;





-- 107 — Revenue After Discount by Segment
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
    ROUND(
        SUM(order_value) - SUM(discount),
        2
    ) AS revenue_after_discount
FROM orders
WHERE order_status = 'Delivered'
GROUP BY discount_segment
ORDER BY revenue_after_discount DESC;





-- 108 — Shipping Cost Impact by Customer
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_revenue,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(shipping_cost) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS shipping_cost_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id
ORDER BY shipping_cost_pct DESC;





-- 109 — Revenue & Shipping Cost by Acquisition Channel
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.order_value), 2) AS total_revenue,
    ROUND(SUM(o.shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(o.shipping_cost) * 100.0 /
        NULLIF(SUM(o.order_value), 0),
        2
    ) AS shipping_cost_pct
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel
ORDER BY shipping_cost_pct DESC;





-- 110 — Revenue After Discount & Shipping Cost
SELECT
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS revenue_after_discount_shipping
FROM orders
WHERE order_status = 'Delivered';





-- 111 — Net Revenue by Shipping Type
SELECT
    shipping_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS net_revenue_after_costs
FROM orders
WHERE order_status = 'Delivered'
GROUP BY shipping_type
ORDER BY net_revenue_after_costs DESC;





-- 112 — Net Revenue by Payment Method
SELECT
    payment_method,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS net_revenue_after_costs
FROM orders
WHERE order_status = 'Delivered'
GROUP BY payment_method
ORDER BY net_revenue_after_costs DESC;





-- 113 — Net Revenue by Acquisition Campaign
SELECT
    c.acquisition_campaign,
    c.acquisition_channel,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.order_value), 2) AS total_order_value,
    ROUND(SUM(o.discount), 2) AS total_discount,
    ROUND(SUM(o.shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(o.order_value)
        - SUM(o.discount)
        - SUM(o.shipping_cost),
        2
    ) AS net_revenue_after_costs
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY
    c.acquisition_campaign,
    c.acquisition_channel
ORDER BY net_revenue_after_costs DESC;





-- 114 — Net Revenue by Customer
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS net_revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id
ORDER BY net_revenue DESC;





-- 115 — Net Revenue by Product
WITH product_revenue AS (
    SELECT
        oi.product_id,
        SUM(oi.item_revenue) AS product_revenue
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY oi.product_id
),
order_costs AS (
    SELECT
        oi.product_id,
        SUM(o.shipping_cost) AS shipping_cost,
        SUM(o.discount) AS order_discount
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY oi.product_id
)
SELECT
    pr.product_id,
    ROUND(pr.product_revenue, 2) AS product_revenue,
    ROUND(oc.order_discount, 2) AS order_discount,
    ROUND(oc.shipping_cost, 2) AS shipping_cost,
    ROUND(
        pr.product_revenue
        - oc.order_discount
        - oc.shipping_cost,
        2
    ) AS net_revenue
FROM product_revenue pr
JOIN order_costs oc
    ON pr.product_id = oc.product_id
ORDER BY net_revenue DESC;





-- 116 — Monthly Revenue & Cost Analysis
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS net_revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY order_month
ORDER BY order_month;





-- 117 — Monthly Net Revenue Growth
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
FROM monthly_data
ORDER BY order_month;






-- 118 — Discount Rate by Acquisition Channel
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.order_value), 2) AS total_order_value,
    ROUND(SUM(o.discount), 2) AS total_discount,
    ROUND(
        SUM(o.discount) * 100.0 /
        NULLIF(SUM(o.order_value), 0),
        2
    ) AS discount_rate_pct
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel
ORDER BY discount_rate_pct DESC;





-- 119 — Discount Rate by Shipping Type
SELECT
    shipping_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(
        SUM(discount) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS discount_rate_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY shipping_type
ORDER BY discount_rate_pct DESC;





-- 120 — Discount Rate by Payment Method
SELECT
    payment_method,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(
        SUM(discount) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS discount_rate_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY payment_method
ORDER BY discount_rate_pct DESC;





-- 121 — Customer Net Revenue Segmentation
WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(order_value) AS total_order_value,
        SUM(discount) AS total_discount,
        SUM(shipping_cost) AS total_shipping_cost
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN total_order_value - total_discount - total_shipping_cost < 5000
            THEN 'Low Net Revenue'
        WHEN total_order_value - total_discount - total_shipping_cost < 20000
            THEN 'Medium Net Revenue'
        ELSE 'High Net Revenue'
    END AS revenue_segment,
    COUNT(*) AS customers,
    ROUND(
        SUM(total_order_value - total_discount - total_shipping_cost),
        2
    ) AS total_net_revenue,
    ROUND(
        AVG(total_order_value - total_discount - total_shipping_cost),
        2
    ) AS avg_net_revenue
FROM customer_revenue
GROUP BY revenue_segment
ORDER BY avg_net_revenue DESC;





-- 122 — Profitability by Customer Acquisition Channel
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT o.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_order_value,
    ROUND(SUM(o.discount), 2) AS total_discount,
    ROUND(SUM(o.shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(o.order_value)
        - SUM(o.discount)
        - SUM(o.shipping_cost),
        2
    ) AS contribution_revenue,
    ROUND(
        (
            SUM(o.order_value)
            - SUM(o.discount)
            - SUM(o.shipping_cost)
        ) * 100.0 /
        NULLIF(SUM(o.order_value), 0),
        2
    ) AS contribution_margin_pct
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.acquisition_channel
ORDER BY contribution_revenue DESC;





-- 123 — Profitability by Customer
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS contribution_revenue,
    ROUND(
        (
            SUM(order_value)
            - SUM(discount)
            - SUM(shipping_cost)
        ) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS contribution_margin_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id
ORDER BY contribution_revenue DESC;






-- 124 — Monthly Contribution Margin
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS contribution_revenue,
    ROUND(
        (
            SUM(order_value)
            - SUM(discount)
            - SUM(shipping_cost)
        ) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS contribution_margin_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY order_month
ORDER BY order_month;





-- 125 — High-Discount Orders & Contribution
SELECT
    COUNT(DISTINCT order_id) AS high_discount_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS contribution_revenue
FROM orders
WHERE order_status = 'Delivered'
  AND discount >= 25;
  
  
  
  
  
  -- 126 — Low-Value Orders with High Shipping Cost
  SELECT
    COUNT(DISTINCT order_id) AS affected_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(shipping_cost) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS shipping_cost_pct
FROM orders
WHERE order_status = 'Delivered'
  AND order_value < 1000
  AND shipping_cost > order_value * 0.20;
  
  
  
  
  
  
  -- 27 — Customer Contribution by Acquisition Campaign
SELECT
    c.acquisition_campaign,
    c.acquisition_channel,
    COUNT(DISTINCT o.customer_id) AS customers,
    ROUND(SUM(o.order_value), 2) AS total_order_value,
    ROUND(SUM(o.discount), 2) AS total_discount,
    ROUND(SUM(o.shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(o.order_value)
        - SUM(o.discount)
        - SUM(o.shipping_cost),
        2
    ) AS contribution_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY
    c.acquisition_campaign,
    c.acquisition_channel
ORDER BY contribution_revenue DESC;






-- 128 — Contribution by Payment Method
SELECT
    payment_method,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS contribution_revenue,
    ROUND(
        (
            SUM(order_value)
            - SUM(discount)
            - SUM(shipping_cost)
        ) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS contribution_margin_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY payment_method
ORDER BY contribution_revenue DESC;





-- 129 — Contribution by Shipping Type
SELECT
    shipping_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS contribution_revenue,
    ROUND(
        (
            SUM(order_value)
            - SUM(discount)
            - SUM(shipping_cost)
        ) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS contribution_margin_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY shipping_type
ORDER BY contribution_revenue DESC;





-- 130 — Contribution by Customer
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS contribution_revenue,
    ROUND(
        (
            SUM(order_value)
            - SUM(discount)
            - SUM(shipping_cost)
        ) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS contribution_margin_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id
ORDER BY contribution_revenue DESC;





-- 131 — Contribution by Month
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS contribution_revenue,
    ROUND(
        (
            SUM(order_value)
            - SUM(discount)
            - SUM(shipping_cost)
        ) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS contribution_margin_pct
FROM orders
WHERE order_status = 'Delivered'
GROUP BY order_month
ORDER BY order_month;






-- 132 — Overall Contribution Summary
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS contribution_revenue,
    ROUND(
        (
            SUM(order_value)
            - SUM(discount)
            - SUM(shipping_cost)
        ) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS contribution_margin_pct
FROM orders
WHERE order_status = 'Delivered';






-- 133 — Negative Contribution Orders
SELECT
    order_id,
    customer_id,
    order_value,
    discount,
    shipping_cost,
    ROUND(
        order_value - discount - shipping_cost,
        2
    ) AS contribution_revenue
FROM orders
WHERE order_status = 'Delivered'
  AND (order_value - discount - shipping_cost) < 0
ORDER BY contribution_revenue ASC;






-- 134 — Negative Contribution Order Summary
SELECT
    COUNT(DISTINCT order_id) AS negative_contribution_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS total_negative_contribution
FROM orders
WHERE order_status = 'Delivered'
  AND (order_value - discount - shipping_cost) < 0;
  
  
  
  
  
--  135 — Negative Contribution by Shipping Type
  SELECT
    shipping_type,
    COUNT(DISTINCT order_id) AS negative_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS contribution_revenue
FROM orders
WHERE order_status = 'Delivered'
  AND (order_value - discount - shipping_cost) < 0
GROUP BY shipping_type
ORDER BY contribution_revenue ASC;





-- 136 — Negative Contribution by Payment Method
SELECT
    payment_method,
    COUNT(DISTINCT order_id) AS negative_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS contribution_revenue
FROM orders
WHERE order_status = 'Delivered'
  AND (order_value - discount - shipping_cost) < 0
GROUP BY payment_method
ORDER BY contribution_revenue ASC;





-- 137 — Negative Contribution by Acquisition Channel
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT o.order_id) AS negative_orders,
    ROUND(SUM(o.order_value), 2) AS total_order_value,
    ROUND(SUM(o.discount), 2) AS total_discount,
    ROUND(SUM(o.shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(o.order_value)
        - SUM(o.discount)
        - SUM(o.shipping_cost),
        2
    ) AS contribution_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
  AND (o.order_value - o.discount - o.shipping_cost) < 0
GROUP BY c.acquisition_channel
ORDER BY contribution_revenue ASC;





-- 138 — Negative Contribution by Discount Segment
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
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS contribution_revenue
FROM orders
WHERE order_status = 'Delivered'
  AND (order_value - discount - shipping_cost) < 0
GROUP BY discount_segment
ORDER BY contribution_revenue ASC;





-- 139 — High Shipping Cost Orders
SELECT
    order_id,
    customer_id,
    order_value,
    shipping_cost,
    ROUND(
        shipping_cost * 100.0 /
        NULLIF(order_value, 0),
        2
    ) AS shipping_cost_pct,
    ROUND(
        order_value - discount - shipping_cost,
        2
    ) AS contribution_revenue
FROM orders
WHERE order_status = 'Delivered'
  AND shipping_cost > order_value * 0.20
ORDER BY shipping_cost_pct DESC;






-- 140 — High Shipping Cost Order Summary
SELECT
    COUNT(DISTINCT order_id) AS high_shipping_cost_orders,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(shipping_cost) * 100.0 /
        NULLIF(SUM(order_value), 0),
        2
    ) AS shipping_cost_pct,
    ROUND(
        SUM(order_value)
        - SUM(discount)
        - SUM(shipping_cost),
        2
    ) AS contribution_revenue
FROM orders
WHERE order_status = 'Delivered'
  AND shipping_cost > order_value * 0.20;
  
  
  
  
  

-- 141 — Overall Profitability Dashboard KPIs
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(SUM(discount), 2) AS total_discount,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(
        SUM(order_value) - SUM(discount) - SUM(shipping_cost),
        2
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





-- 



select * from order_items;
select * from orders;






-- 