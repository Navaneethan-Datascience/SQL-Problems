-- How do transaction amounts and fee percentages impact seller performance in the Amazon Marketplace? Using SQL, analyze sales and fee data to identify top-performing sellers, weekly transaction trends, and cumulative transaction counts. Based on this analysis, what insights can be drawn to guide strategic fee adjustments that incentivize high-performing sellers and improve overall marketplace efficiency?


-- Talble Schema:
-- fct_seller_sales(sale_id, seller_id, sale_amount, fee_amount_percentage, sale_date)
-- dim_seller(seller_id, seller_name)

-- Problem1: For each seller, please identify their top sale transaction in April 2024 based on sale amount. If there are multiple transactions with the same sale amount, select the one with the most recent sale_date.
-- Business insight : here we calculated the highest total sale amount per user. which allow  us to focus on fee optimization efforts on sellers contributing the most revenue 

WITH ranked_sellers AS(
SELECT s.seller_id,
       sale_amount,
       sale_date,
       DENSE_RANK() OVER(PARTITION BY s.seller_id ORDER BY sale_amount DESC, sale_date DESC) AS rnk
FROM fct_seller_sales AS ss
JOIN dim_seller AS s
      ON ss.seller_id = s.seller_id
WHERE sale_date >= '2024-04-01'
      AND sale_date < '2024-05-01'
)

SELECT seller_id,
       sale_amount,
       sale_date
FROM ranked_sellers
WHERE rnk = 1;


-- Problem2 : Within May 2024, for each seller ID, please generate a weekly summary that reports the total number of sales transactions and shows the fee amount from the most recent sale in that week. This analysis will let us correlate fee changes with weekly seller performance trends.
-- -- Business Insight : Our weekly analysis shows how recent fee changes align with transaction volumes, helping us understand seller responsiveness to fee adjustments.


WITH weekly_sales AS(
SELECT seller_id,
       STRFTIME('%Y-%W',sale_date) AS year_week,
       sale_date,
       fee_amount_percentage,
       ROW_NUMBER() OVER( 
                PARTITION BY seller_id, STRFTIME('%Y-%W',sale_date)
                ORDER BY sale_date DESC
      ) AS rnk
FROM fct_seller_sales
WHERE sale_date >= '2024-05-01'
      AND sale_date < '2024-06-01'
),
weekly_summary AS(
SELECT seller_id,
       STRFTIME('%Y-%W',sale_date) AS year_week,
       COUNT(*) AS total_sales_transactions
FROM fct_seller_sales
WHERE sale_date >= '2024-05-01'
      AND sale_date < '2024-06-01'
GROUP BY seller_id, STRFTIME('%Y-%W',sale_date)
)

SELECT ws.seller_id,
       ws.year_week,
       ws.total_sales_transactions,
       w.fee_amount_percentage AS latest_fee
FROM weekly_summary AS ws
JOIN weekly_sales AS w
     ON ws.seller_id = w.seller_id
     AND ws.year_week = w.year_week
     AND w.rnk = 1
ORDER BY ws.seller_id, ws.year_week;



-- Problem3: Using June 2024, for each seller, create a daily report that computes a cumulative count of transactions up to that day.
-- Business insight : The cumulative daily transaction counts highlight sellers’ sales trajectories, allowing us to identify those gaining momentum or needing support.
WITH sales_june AS(
SELECT seller_id,
       sale_date,
       COUNT(*) AS total_sales_transaction
FROM fct_seller_sales AS ss
WHERE sale_date >= '2024-06-01'
      AND sale_date < '2024-07-01'
GROUP BY seller_id, sale_date
)

SELECT seller_id,
      sale_date,
      total_sales_transaction, 
      SUM(total_sales_transaction) OVER(PARTITION BY seller_id ORDER BY sale_date) AS cumulative_transactions
FROM sales_june;


