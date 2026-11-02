WITH valid_sales AS (
    SELECT *
    FROM ecommerce.transactions
    WHERE line_status = 'Valid Sale'
),
customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) AS total_orders
    FROM valid_sales
    WHERE customer_id IS NOT NULL
      AND TRIM(customer_id) <> ''
    GROUP BY customer_id
),
monthly_sales AS (
    SELECT
        DATE_TRUNC('month', invoice_date)::date AS sales_month,
        SUM(line_revenue) AS revenue
    FROM valid_sales
    GROUP BY DATE_TRUNC('month', invoice_date)
),
country_sales AS (
    SELECT
        country,
        SUM(line_revenue) AS revenue
    FROM valid_sales
    GROUP BY country
),
product_sales AS (
    SELECT
        stock_code,
        product_description,
        SUM(line_revenue) AS revenue
    FROM valid_sales
    GROUP BY stock_code, product_description
),
customer_sales AS (
    SELECT
        customer_id,
        SUM(line_revenue) AS revenue
    FROM valid_sales
    WHERE customer_id IS NOT NULL
      AND TRIM(customer_id) <> ''
    GROUP BY customer_id
),
findings AS (
    SELECT
        1 AS display_order,
        'Total transaction lines' AS metric,
        COUNT(*)::text AS metric_value
    FROM ecommerce.transactions

    UNION ALL

    SELECT
        2,
        'Date range',
        MIN(invoice_date)::text || ' to ' || MAX(invoice_date)::text
    FROM ecommerce.transactions

    UNION ALL

    SELECT
        3,
        'Unique invoices',
        COUNT(DISTINCT invoice_no)::text
    FROM ecommerce.transactions

    UNION ALL

    SELECT
        4,
        'Identified customers',
        COUNT(DISTINCT customer_id)::text
    FROM valid_sales
    WHERE customer_id IS NOT NULL
      AND TRIM(customer_id) <> ''

    UNION ALL

    SELECT
        5,
        'Gross revenue',
        ROUND(SUM(line_revenue), 2)::text
    FROM valid_sales

    UNION ALL

    SELECT
        6,
        'Completed orders',
        COUNT(DISTINCT invoice_no)::text
    FROM valid_sales

    UNION ALL

    SELECT
        7,
        'Units sold',
        SUM(quantity)::text
    FROM valid_sales

    UNION ALL

    SELECT
        8,
        'Average order value',
        ROUND(
            SUM(line_revenue) /
            NULLIF(COUNT(DISTINCT invoice_no), 0),
            2
        )::text
    FROM valid_sales

    UNION ALL

    SELECT
        9,
        'Cancellation rate',
        ROUND(
            100.0 * COUNT(
                DISTINCT CASE
                    WHEN invoice_status = 'Cancelled'
                    THEN invoice_no
                END
            ) /
            NULLIF(COUNT(DISTINCT invoice_no), 0),
            2
        )::text || '%'
    FROM ecommerce.transactions

    UNION ALL

    SELECT
        10,
        'Cancelled or returned value',
        ROUND(
            ABS(
                SUM(
                    CASE
                        WHEN line_status = 'Cancelled/Returned'
                        THEN line_revenue
                        ELSE 0
                    END
                )
            ),
            2
        )::text
    FROM ecommerce.transactions

    UNION ALL

    SELECT
        11,
        'Repeat customers',
        COUNT(*) FILTER (WHERE total_orders > 1)::text
    FROM customer_orders

    UNION ALL

    SELECT
        12,
        'Repeat customer rate',
        ROUND(
            100.0 * COUNT(*) FILTER (WHERE total_orders > 1) /
            NULLIF(COUNT(*), 0),
            2
        )::text || '%'
    FROM customer_orders

    UNION ALL

    SELECT
        13,
        'Highest-revenue month',
        TO_CHAR(sales_month, 'YYYY-MM')
            || ' — '
            || ROUND(revenue, 2)::text
    FROM (
        SELECT sales_month, revenue
        FROM monthly_sales
        ORDER BY revenue DESC
        LIMIT 1
    ) AS best_month

    UNION ALL

    SELECT
        14,
        'Highest-revenue country',
        country || ' — ' || ROUND(revenue, 2)::text
    FROM (
        SELECT country, revenue
        FROM country_sales
        ORDER BY revenue DESC
        LIMIT 1
    ) AS best_country

    UNION ALL

    SELECT
        15,
        'Highest-revenue product',
        COALESCE(product_description, stock_code)
            || ' — '
            || ROUND(revenue, 2)::text
    FROM (
        SELECT stock_code, product_description, revenue
        FROM product_sales
        ORDER BY revenue DESC
        LIMIT 1
    ) AS best_product

    UNION ALL

    SELECT
        16,
        'Highest-value customer',
        customer_id || ' — ' || ROUND(revenue, 2)::text
    FROM (
        SELECT customer_id, revenue
        FROM customer_sales
        ORDER BY revenue DESC
        LIMIT 1
    ) AS best_customer
)
SELECT
    display_order,
    metric,
    metric_value
FROM findings
ORDER BY display_order;