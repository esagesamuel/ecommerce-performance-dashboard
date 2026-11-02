--Customer level summary
WITH customer_summary AS (
    SELECT
        customer_id,
        MIN(invoice_date) AS first_purchase_date,
        MAX(invoice_date) AS latest_purchase_date,
        COUNT(DISTINCT invoice_no) AS purchase_frequency,
        SUM(quantity) AS units_purchased,
        ROUND(SUM(line_revenue), 2) AS customer_revenue
    FROM ecommerce.transactions
    WHERE line_status = 'Valid Sale'
      AND customer_id IS NOT NULL
      AND TRIM(customer_id) <> ''
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS identified_customers,
    ROUND(AVG(purchase_frequency), 2) AS average_purchase_frequency,
    ROUND(AVG(units_purchased), 2) AS average_units_per_customer,
    ROUND(AVG(customer_revenue), 2) AS average_customer_revenue,
    ROUND(MIN(customer_revenue), 2) AS minimum_customer_revenue,
    ROUND(MAX(customer_revenue), 2) AS maximum_customer_revenue
FROM customer_summary;

-- Reapeat customer rate
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) AS total_orders
    FROM ecommerce.transactions
    WHERE line_status = 'Valid Sale'
      AND customer_id IS NOT NULL
      AND TRIM(customer_id) <> ''
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS identified_customers,
    COUNT(*) FILTER (WHERE total_orders = 1) AS one_time_customers,
    COUNT(*) FILTER (WHERE total_orders > 1) AS repeat_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE total_orders > 1) /
        NULLIF(COUNT(*), 0),
        2
    ) AS repeat_customer_rate_pct
FROM customer_orders;

-- Revenue from new and repeat customers
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) AS total_orders,
        SUM(line_revenue) AS customer_revenue
    FROM ecommerce.transactions
    WHERE line_status = 'Valid Sale'
      AND customer_id IS NOT NULL
      AND TRIM(customer_id) <> ''
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS customer_segment,
    COUNT(*) AS customers,
    ROUND(SUM(customer_revenue), 2) AS gross_revenue,
    ROUND(AVG(customer_revenue), 2) AS average_customer_revenue
FROM customer_orders
GROUP BY
    CASE
        WHEN total_orders = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END
ORDER BY gross_revenue DESC;

-- Top customers by revenue
SELECT
    customer_id,
    ROUND(SUM(line_revenue), 2) AS customer_revenue,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(quantity) AS units_purchased,
    MIN(invoice_date) AS first_purchase_date,
    MAX(invoice_date) AS latest_purchase_date
FROM ecommerce.transactions
WHERE line_status = 'Valid Sale'
  AND customer_id IS NOT NULL
  AND TRIM(customer_id) <> ''
GROUP BY customer_id
ORDER BY customer_revenue DESC
LIMIT 20;

--RFM customer metrics
--Recency: days since the customer’s latest purchase
--Frequency: number of distinct orders
--Monetary: total customer revenue
WITH analysis_date AS (
    SELECT MAX(invoice_date) + 1 AS reference_date
    FROM ecommerce.transactions
    WHERE line_status = 'Valid Sale'
),
rfm AS (
    SELECT
        t.customer_id,
        a.reference_date - MAX(t.invoice_date) AS recency_days,
        COUNT(DISTINCT t.invoice_no) AS frequency,
        ROUND(SUM(t.line_revenue), 2) AS monetary_value
    FROM ecommerce.transactions AS t
    CROSS JOIN analysis_date AS a
    WHERE t.line_status = 'Valid Sale'
      AND t.customer_id IS NOT NULL
      AND TRIM(t.customer_id) <> ''
    GROUP BY t.customer_id, a.reference_date
)
SELECT *
FROM rfm
ORDER BY monetary_value DESC;

--RFM scoring
WITH analysis_date AS (
    SELECT MAX(invoice_date) + 1 AS reference_date
    FROM ecommerce.transactions
    WHERE line_status = 'Valid Sale'
),
rfm AS (
    SELECT
        t.customer_id,
        a.reference_date - MAX(t.invoice_date) AS recency_days,
        COUNT(DISTINCT t.invoice_no) AS frequency,
        ROUND(SUM(t.line_revenue), 2) AS monetary_value
    FROM ecommerce.transactions AS t
    CROSS JOIN analysis_date AS a
    WHERE t.line_status = 'Valid Sale'
      AND t.customer_id IS NOT NULL
      AND TRIM(t.customer_id) <> ''
    GROUP BY t.customer_id, a.reference_date
),
rfm_scores AS (
    SELECT
        *,
        6 - NTILE(5) OVER (ORDER BY recency_days ASC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
    FROM rfm
)
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary_value,
    recency_score,
    frequency_score,
    monetary_score,
    CONCAT(
        recency_score,
        frequency_score,
        monetary_score
    ) AS rfm_score
FROM rfm_scores
ORDER BY monetary_value DESC;