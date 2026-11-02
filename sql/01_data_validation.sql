-- Overall data summary
select 
	count(*) as total_rows,
	count(distinct row_id) as unique_row_ids,
	count(distinct invoice_no) as unique_invoices,
	count(distinct customer_id) as identified_customers,
	min(invoice_datetime) as earliest_transaction,
	max(invoice_datetime) as latest_transaction
from ecommerce.transactions;

-- Check for duplicates
SELECT
    row_id,
    COUNT(*) AS occurrences
FROM ecommerce.transactions
GROUP BY row_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- Check for required fields
SELECT
    COUNT(*) FILTER (WHERE row_id IS NULL) AS missing_row_id,
    COUNT(*) FILTER (WHERE invoice_no IS NULL OR TRIM(invoice_no) = '') AS missing_invoice_no,
    COUNT(*) FILTER (WHERE stock_code IS NULL OR TRIM(stock_code) = '') AS missing_stock_code,
    COUNT(*) FILTER (
        WHERE product_description IS NULL
           OR TRIM(product_description) = ''
    ) AS missing_description,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS missing_quantity,
    COUNT(*) FILTER (WHERE invoice_datetime IS NULL) AS missing_invoice_datetime,
    COUNT(*) FILTER (WHERE unit_price IS NULL) AS missing_unit_price,
    COUNT(*) FILTER (WHERE country IS NULL OR TRIM(country) = '') AS missing_country,
    COUNT(*) FILTER (WHERE customer_id IS NULL OR TRIM(customer_id) = '') AS missing_customer_id
FROM ecommerce.transactions;

-- Validate calculated revenue
SELECT
    row_id,
    quantity,
    unit_price,
    line_revenue,
    ROUND(quantity * unit_price, 2) AS expected_revenue
FROM ecommerce.transactions
WHERE line_revenue <> ROUND(quantity * unit_price, 2)
ORDER BY row_id
LIMIT 100;

-- Validate date-derived columns
SELECT
    row_id,
    invoice_datetime,
    invoice_date,
    invoice_year,
    invoice_month_number,
    invoice_month,
    invoice_quarter,
    invoice_hour,
    invoice_day
FROM ecommerce.transactions
WHERE invoice_date <> invoice_datetime::date
   OR invoice_year <> EXTRACT(YEAR FROM invoice_datetime)::integer
   OR invoice_month_number <> EXTRACT(MONTH FROM invoice_datetime)::integer
   OR invoice_quarter <> EXTRACT(QUARTER FROM invoice_datetime)::integer
   OR invoice_hour <> EXTRACT(HOUR FROM invoice_datetime)::integer
   OR LOWER(invoice_month) <> LOWER(TO_CHAR(invoice_datetime, 'FMMonth'))
   OR LOWER(invoice_day) <> LOWER(TO_CHAR(invoice_datetime, 'FMDay'))
ORDER BY row_id
LIMIT 100;

-- Transaction classifications
select 
	line_status,
	count(*) as transaction_lines,
	count(distinct invoice_no) as distinct_invoices,
	sum(quantity) as total_quantity,
	round(sum(line_revenue), 2) as total_value
from ecommerce.transactions 
group by line_status
order by transaction_lines desc;

-- Invoice classifications
SELECT
    invoice_status,
    COUNT(*) AS transaction_lines,
    COUNT(DISTINCT invoice_no) AS distinct_invoices,
    ROUND(SUM(line_revenue), 2) AS total_value
FROM ecommerce.transactions
GROUP BY invoice_status
ORDER BY transaction_lines DESC;

-- Customer coverage
SELECT
    customer_type,
    COUNT(*) AS transaction_lines,
    COUNT(DISTINCT customer_id) AS distinct_customers,
    ROUND(SUM(line_revenue), 2) AS total_value
FROM ecommerce.transactions
GROUP BY customer_type
ORDER BY transaction_lines DESC;