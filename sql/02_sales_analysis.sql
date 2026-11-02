-- Executive KPI summary
WITH valid_sales AS (
    SELECT *
    FROM ecommerce.transactions
    WHERE line_status = 'Valid Sale'
)
SELECT
    ROUND(SUM(line_revenue), 2) AS gross_revenue,
    COUNT(DISTINCT invoice_no) AS completed_orders,
    SUM(quantity) AS units_sold,
    COUNT(DISTINCT customer_id) AS identified_customers,
    ROUND(
        SUM(line_revenue) / NULLIF(COUNT(DISTINCT invoice_no), 0),
        2
    ) AS average_order_value,
    ROUND(
        SUM(quantity)::numeric /
        NULLIF(COUNT(DISTINCT invoice_no), 0),
        2
    ) AS average_items_per_order,
    ROUND(
        SUM(line_revenue) /
        NULLIF(COUNT(DISTINCT customer_id), 0),
        2
    ) AS revenue_per_identified_customer
FROM valid_sales;

-- Cancellation summary
SELECT
    COUNT(DISTINCT invoice_no)
        FILTER (WHERE invoice_status = 'Cancelled') AS cancelled_orders,

    COUNT(DISTINCT invoice_no) AS all_invoices,

    ROUND(
        100.0 *
        COUNT(DISTINCT invoice_no)
            FILTER (WHERE invoice_status = 'Cancelled') /
        NULLIF(COUNT(DISTINCT invoice_no), 0),
        2
    ) AS cancellation_rate_pct,

    ROUND(
        ABS(SUM(line_revenue)
            FILTER (WHERE line_status = 'Cancelled/Returned')),
        2
    ) AS cancelled_returned_value
FROM ecommerce.transactions;

-- Monthly sales trend
SELECT
    DATE_TRUNC('month', invoice_date)::date AS sales_month,
    ROUND(SUM(line_revenue), 2) AS gross_revenue,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(quantity) AS units_sold,
    ROUND(
        SUM(line_revenue) /
        NULLIF(COUNT(DISTINCT invoice_no), 0),
        2
    ) AS average_order_value
FROM ecommerce.transactions
WHERE line_status = 'Valid Sale'
GROUP BY DATE_TRUNC('month', invoice_date)
ORDER BY sales_month;

-- Monthly cancellation trend
SELECT
    DATE_TRUNC('month', invoice_date)::date AS sales_month,
    COUNT(DISTINCT invoice_no)
        FILTER (WHERE invoice_status = 'Cancelled') AS cancelled_orders,
    ABS(
        ROUND(
            SUM(line_revenue)
                FILTER (WHERE line_status = 'Cancelled/Returned'),
            2
        )
    ) AS cancelled_returned_value
FROM ecommerce.transactions
GROUP BY DATE_TRUNC('month', invoice_date)
ORDER BY sales_month;

-- Sales by country
SELECT
    country,
    ROUND(SUM(line_revenue), 2) AS gross_revenue,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(quantity) AS units_sold,
    COUNT(DISTINCT customer_id) AS identified_customers,
    ROUND(
        SUM(line_revenue) /
        NULLIF(COUNT(DISTINCT invoice_no), 0),
        2
    ) AS average_order_value
FROM ecommerce.transactions
WHERE line_status = 'Valid Sale'
GROUP BY country
ORDER BY gross_revenue DESC;

-- Top products by revenue
SELECT
    stock_code,
    product_description,
    ROUND(SUM(line_revenue), 2) AS gross_revenue,
    SUM(quantity) AS units_sold,
    COUNT(DISTINCT invoice_no) AS orders_containing_product,
    ROUND(AVG(unit_price), 2) AS average_unit_price
FROM ecommerce.transactions
WHERE line_status = 'Valid Sale'
  AND product_description IS NOT NULL
GROUP BY stock_code, product_description
ORDER BY gross_revenue DESC
LIMIT 20;

--Top products by units sold
SELECT
    stock_code,
    product_description,
    SUM(quantity) AS units_sold,
    ROUND(SUM(line_revenue), 2) AS gross_revenue,
    COUNT(DISTINCT invoice_no) AS orders_containing_product
FROM ecommerce.transactions
WHERE line_status = 'Valid Sale'
  AND product_description IS NOT NULL
GROUP BY stock_code, product_description
ORDER BY units_sold DESC
LIMIT 20;

-- Sales by day of week
SELECT
    EXTRACT(ISODOW FROM invoice_date)::integer AS weekday_number,
    TO_CHAR(invoice_date, 'FMDay') AS weekday,
    ROUND(SUM(line_revenue), 2) AS gross_revenue,
    COUNT(DISTINCT invoice_no) AS total_orders
FROM ecommerce.transactions
WHERE line_status = 'Valid Sale'
GROUP BY
    EXTRACT(ISODOW FROM invoice_date),
    TO_CHAR(invoice_date, 'FMDay')
ORDER BY weekday_number;

-- Sales by hour
SELECT
    invoice_hour,
    ROUND(SUM(line_revenue), 2) AS gross_revenue,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(quantity) AS units_sold
FROM ecommerce.transactions
WHERE line_status = 'Valid Sale'
GROUP BY invoice_hour
ORDER BY invoice_hour;

-- ============================================================
-- UK revenue contribution
-- ============================================================

SELECT
    ROUND(
        SUM(
            CASE
                WHEN country = 'United Kingdom'
                THEN line_revenue
                ELSE 0
            END
        ),
        2
    ) AS uk_revenue,

    ROUND(
        SUM(line_revenue),
        2
    ) AS total_gross_revenue,

    ROUND(
        100.0
        * SUM(
            CASE
                WHEN country = 'United Kingdom'
                THEN line_revenue
                ELSE 0
            END
        )
        / NULLIF(SUM(line_revenue), 0),
        2
    ) AS uk_revenue_share_pct

FROM ecommerce.transactions
WHERE line_status = 'Valid Sale';



