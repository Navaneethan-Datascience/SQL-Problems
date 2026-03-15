-- What are the transaction success and failure rates across different merchant categories on Google Pay? Using SQL, analyze payment data to identify potential friction points in the digital payment experience. Based on this analysis, what insights can be drawn to improve reliability, optimize product features, and ensure a smoother payment process for users?

-- Problem1 :For January 2024, what are the total counts of successful and failed transactions in each merchant category? This analysis will help the Google Pay security team identify potential friction points in payment processing.
--  in july 2024 the grocerie  merchant category had a highest(2) failed transations retail and dining have only one failed transactions out team focus the groceries category payment security.
SELECT merchant_category,
       transaction_status,
       COUNT(*) AS tota_transactions_july
FROM fct_transactions
WHERE transaction_date BETWEEN '2024-01-01' AND '2024-01-31'
GROUP BY merchant_category, transaction_status;

-- Problem2: For the first quarter of 2024, which merchant categories recorded a transaction success rate below 90%? This insight will guide our prioritization of security enhancements to improve payment reliability.
-- our team have to focus dinig, Entertainment, Groceries, Retail and Utilities these merchant categories because these are having below 90% sucess rate.
SELECT merchant_category,
       SUM(CASE WHEN transaction_status = 'SUCCESS' THEN 1 ELSE 0 END)*100/ COUNT(*) AS success_rate_percentage
FROM fct_transactions
WHERE transaction_date BETWEEN '2024-01-01' AND '2024-03-31'
GROUP BY merchant_category
HAVING success_rate_percentage < 90;


-- From January 1st to March 31st, 2024, can you generate a list of merchant categories with their concatenated counts for successful and failed transactions? Then, rank the categories by total transaction volume. This ranking will support our assessment of areas where mixed transaction outcomes may affect user experience.
-- retail and travel category have a highest total transaction at first quarter of 2024 also had good sucess rate.
WITH transaction_merchants_q1 AS(
SELECT merchant_category,
       CONCAT( 'Sucess:', SUM(CASE WHEN transaction_status = 'SUCCESS' THEN 1 ELSE 0 END)," ",
               'Failed:',  SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END)
            ) AS transaction_summary,
       COUNT(*) AS total_transactions
FROM fct_transactions
WHERE transaction_date BETWEEN '2024-01-01' AND '2024-03-31'
GROUP BY merchant_category
  )

SELECT merchant_category,
       transaction_summary,
       total_transactions,
       DENSE_RANK() OVER(ORDER BY total_transactions DESC) AS rnk
FROM transaction_merchants_q1;