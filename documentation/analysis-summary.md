# E-commerce Performance Analysis Summary

## Project Objective

This project analyses transactional e-commerce data to identify revenue trends, product and market performance, customer purchasing behaviour, repeat purchases, and cancellation or return exposure. The analysis was completed using Power Query, PostgreSQL, SQL, and Power BI.

## Dataset Overview

- **Reporting period:** 1 December 2010 to 9 December 2011
- **Transaction lines:** 535,187
- **Unique invoices:** 24,446
- **Identified customers:** 4,338
- **Data source:** UCI Online Retail dataset

The dataset contains transaction-level records from a UK-based online retailer. Anonymous transactions were retained for sales analysis but excluded from customer-level analysis.

## Executive KPIs

| KPI | Result |
|---|---:|
| Gross revenue | 10,642,110.80 |
| Estimated net revenue after cancellations/returns | 9,748,131.07 |
| Completed orders | 19,960 |
| Units sold | 5,572,420 |
| Average order value | 533.17 |
| Cancellation rate | 15.69% |
| Cancelled or returned value | 893,979.73 |

Net revenue is calculated as gross revenue less the absolute cancelled or returned value.

## Sales Trend Findings

1. **November 2011 was the highest-revenue month**, generating 1,503,866.78.
2. The reporting period begins partway through December 2010 and ends on 9 December 2011. These two months are partial periods and should not be compared directly with complete months.
3. The cancellation rate of 15.69% and cancelled or returned value of 893,979.73 represent meaningful commercial exposure and should be monitored alongside gross sales.
4. Monthly revenue should be reviewed together with order volume and average order value to distinguish growth caused by more orders from growth caused by larger baskets.

## Product Findings

1. **DOTCOM POSTAGE was the highest-revenue product**, generating 206,248.77.
2. Product performance should be assessed using both revenue and units sold because high-volume products are not necessarily the highest-value products.
3. Products with high cancellation or return value should be investigated for possible fulfilment, description, quality, or customer-expectation issues.
4. Postage-related revenue should be distinguished from merchandise performance when evaluating product demand and inventory decisions.

## Market Findings

1. **The United Kingdom was the highest-revenue market**, generating 9,001,744.09.
2. The United Kingdom contributed approximately **84.59% of gross revenue**, demonstrating substantial geographic concentration.
3. International markets should be analysed separately from the United Kingdom so their performance is not obscured by the dominant domestic market.
4. Country performance should be compared using revenue, completed orders, average order value, customer count, and cancellation rate rather than revenue alone.

## Customer Findings

| Customer metric | Result |
|---|---:|
| Identified customers | 4,338 |
| Repeat customers | 2,845 |
| One-time customers | 1,493 |
| Repeat customer rate | 65.58% |
| Highest-value customer | Customer 14646 |
| Highest customer revenue | 280,206.02 |

1. Repeat customers form the majority of identified customers, with a repeat-customer rate of 65.58%.
2. The remaining 34.42% of identified customers purchased only once during the reporting period.
3. Customer 14646 generated the highest customer revenue at 280,206.02.
4. High-value and repeat customers should be prioritised for retention, while one-time and lapsed customers provide opportunities for targeted re-engagement.

## Business Recommendations

1. **Strengthen customer retention:** Develop loyalty, replenishment, or personalised communication campaigns for repeat and high-value customers.
2. **Convert one-time customers:** Analyse the products and order characteristics associated with first purchases, then use targeted follow-up offers to encourage a second order.
3. **Investigate cancellation exposure:** Review products and markets with high cancellation value or cancellation rates to identify operational or product-information issues.
4. **Separate postage from merchandise reporting:** Treat postage-related lines separately when analysing inventory and product demand.
5. **Reduce geographic concentration risk:** Evaluate promising international markets independently and assess opportunities for controlled expansion beyond the United Kingdom.
6. **Plan for peak demand:** Use the strong November performance to guide inventory, staffing, and promotional planning for future peak periods.
7. **Monitor a balanced KPI set:** Track gross revenue, net revenue, orders, average order value, repeat-customer rate, and cancellation exposure together.

## Limitations

- The dataset covers a limited historical period and should not be treated as current commercial performance.
- December 2010 and December 2011 are incomplete reporting months.
- Some transactions do not contain customer identifiers and cannot be used in customer-level analysis.
- The dataset does not include product costs, marketing expenditure, acquisition channels, website sessions, or shopping-cart activity.
- Profit, conversion rate, customer-acquisition cost, advertising return, and cart-abandonment rate cannot be calculated reliably.
- Cancellation and return records do not contain reason codes, so their underlying causes cannot be confirmed from this dataset alone.

## Tools and Methods

- **Power Query:** data cleaning, type correction, transaction classification, and calculated fields
- **PostgreSQL and SQL:** validation, KPI calculations, sales analysis, and customer analysis
- **Power BI and DAX:** star-schema modelling, interactive analysis, customer segmentation, and dashboard development
- **Git and GitHub:** version control and portfolio presentation
