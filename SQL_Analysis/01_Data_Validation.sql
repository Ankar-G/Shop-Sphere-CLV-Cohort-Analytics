                                                -- Shop Sphere – CLV & Cohort Analytics --
													-- Data Quality & Validation  -- 


-- 1.  Numbers Of Rows
SELECT
    (SELECT COUNT(*) FROM customers) AS customers_rows,
    (SELECT COUNT(*) FROM orders) AS orders_rows,
    (SELECT COUNT(*) FROM order_items) AS order_items_rows,
    (SELECT COUNT(*) FROM products) AS products_rows,
    (SELECT COUNT(*) FROM returns) AS returns_rows;




-- 2. Checking duplicate customer id
SELECT 
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;




-- 3. Check duplicate Order IDs
SELECT 
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;




-- 4. Check duplicate Product IDs
SELECT 
    product_id,
    COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;




-- 5. Check duplicate Return IDs
SELECT 
    return_id,
    COUNT(*) AS duplicate_count
FROM returns
GROUP BY return_id
HAVING COUNT(*) > 1;




-- 6. Check NULL values in customers
SELECT
    SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(signup_date IS NULL) AS signup_date_nulls,
    SUM(gender IS NULL) AS gender_nulls,
    SUM(age IS NULL) AS age_nulls,
    SUM(city IS NULL) AS city_nulls,
    SUM(state IS NULL) AS state_nulls,
    SUM(acquisition_channel IS NULL) AS acquisition_channel_nulls,
    SUM(acquisition_campaign IS NULL) AS acquisition_campaign_nulls
FROM customers;





-- 7. Check NULL values in orders

SELECT
    SUM(order_id IS NULL) AS order_id_nulls,
    SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(order_date IS NULL) AS order_date_nulls,
    SUM(order_status IS NULL) AS order_status_nulls,
    SUM(payment_method IS NULL) AS payment_method_nulls,
    SUM(shipping_type IS NULL) AS shipping_type_nulls,
    SUM(discount IS NULL) AS discount_nulls,
    SUM(shipping_cost IS NULL) AS shipping_cost_nulls,
    SUM(order_value IS NULL) AS order_value_nulls
FROM orders;





-- 8. Check NULL values in order_items
SELECT
    SUM(order_id IS NULL) AS order_id_nulls,
    SUM(product_id IS NULL) AS product_id_nulls,
    SUM(quantity IS NULL) AS quantity_nulls,
    SUM(unit_price IS NULL) AS unit_price_nulls,
    SUM(discount IS NULL) AS discount_nulls,
    SUM(item_revenue IS NULL) AS item_revenue_nulls
FROM order_items;





-- 9. Check NULL values in products
SELECT
    SUM(product_id IS NULL) AS product_id_nulls,
    SUM(category IS NULL) AS category_nulls,
    SUM(subcategory IS NULL) AS subcategory_nulls,
    SUM(brand IS NULL) AS brand_nulls,
    SUM(cost_price IS NULL) AS cost_price_nulls,
    SUM(selling_price IS NULL) AS selling_price_nulls
FROM products;





-- 10. Check NULL values in returns
SELECT
    SUM(return_id IS NULL) AS return_id_nulls,
    SUM(order_id IS NULL) AS order_id_nulls,
    SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(return_date IS NULL) AS return_date_nulls,
    SUM(return_reason IS NULL) AS return_reason_nulls,
    SUM(refund_amount IS NULL) AS refund_amount_nulls
FROM returns;





-- 11. Check invalid customer references in orders
SELECT COUNT(*) AS invalid_customer_ids
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;





-- 12. Check invalid Order IDs in order_items
SELECT COUNT(*) AS invalid_order_ids
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;




-- 13. Check invalid Product IDs in order_items
SELECT COUNT(*) AS invalid_product_ids
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;




-- 14. Check invalid Order IDs in returns
SELECT COUNT(*) AS invalid_order_ids
FROM returns r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;





-- 15. Check invalid Customer IDs in returns
SELECT COUNT(*) AS invalid_customer_ids
FROM returns r
LEFT JOIN customers c
    ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL;





-- 16. Check invalid/negative values in orders
SELECT
    SUM(discount < 0) AS negative_discounts,
    SUM(shipping_cost < 0) AS negative_shipping_costs,
    SUM(order_value < 0) AS negative_order_values
FROM orders;





-- 17. Check invalid values in order_items
SELECT
    SUM(quantity <= 0) AS invalid_quantity,
    SUM(unit_price < 0) AS negative_unit_price,
    SUM(discount < 0) AS negative_discount,
    SUM(item_revenue < 0) AS negative_item_revenue
FROM order_items;




-- 18. Check invalid product pricing
SELECT
    SUM(cost_price <= 0) AS invalid_cost_price,
    SUM(selling_price <= 0) AS invalid_selling_price,
    SUM(selling_price < cost_price) AS selling_below_cost
FROM products;




-- 19. Check invalid return/refund amounts
SELECT
    SUM(refund_amount < 0) AS negative_refunds,
    SUM(refund_amount = 0) AS zero_refunds
FROM returns;




-- 20. Check order date range
SELECT
    MIN(order_date) AS earliest_order_date,
    MAX(order_date) AS latest_order_date
FROM orders;


-- 21. Check customer signup date range
SELECT
    MIN(signup_date) AS earliest_signup_date,
    MAX(signup_date) AS latest_signup_date
FROM customers;



-- 22. Check invalid customer ages
SELECT
    MIN(age) AS minimum_age,
    MAX(age) AS maximum_age,
    SUM(age < 18 OR age > 100) AS invalid_age_count
FROM customers;





-- 23. Checking valid order statuses
SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;





-- 24. Checking whether order values are consistent with order items
SELECT
    COUNT(*) AS mismatched_orders
FROM orders o
JOIN (
    SELECT
        order_id,
        SUM(item_revenue) AS calculated_item_revenue
    FROM order_items
    GROUP BY order_id
) oi
    ON o.order_id = oi.order_id
WHERE ABS(o.order_value - oi.calculated_item_revenue) > 0.01;


