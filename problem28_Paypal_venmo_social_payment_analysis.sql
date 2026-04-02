-- How do social sharing behaviors on Venmo influence user engagement and retention? Using SQL, analyze the relationship between users’ social interactions and their transaction patterns. Based on this analysis, what insights can be drawn to understand how social features drive long-term platform usage?

-- Table Schema:
-- fct_transactions(transaction_id, user_id, transaction_date, amount)
-- fct_social_shares(share_id, user_id, share_date)
 
 
 -- Problem1 : What is the floor value of the average number of transactions per user made between October 1st, 2024 and December 31st, 2024? This helps establish a baseline for user engagement on Venmo.
 -- Business insight : averagely users made 2-3 transactions per user in q4. it indicating moderate engagment. increasing repeat usage could significantly improve. 
 WITH user_total_transaction_q4 AS(
SELECT user_id,
       COUNT(*) AS total_transactions
FROM fct_transactions
WHERE transaction_date >= '2024-10-01'
      AND transaction_date <= '2024-12-31'
GROUP BY user_id
)

SELECT FLOOR(AVG(total_transactions)) AS avg_total_transaction
FROM user_total_transaction_q4;


-- Problem2 : How many distinct users executed at least one social share between October 1st, 2024 and December 31st, 2024? This helps assess the prevalence of social sharing among active users.
-- Business insight : only 6 distinct users executed atleast one share in q4. which is very low. we have to do the customer survey to improve user engagement.
WITH total_shares_q4_user AS(
SELECT user_id,
       COUNT(*) AS total_shares_q4
FROM fct_social_shares
WHERE share_date >= '2024-10-01'
      AND share_date <= '2024-12-31'
GROUP BY user_id
HAVING total_shares_q4 >= 1
)

SELECT COUNT(*) AS unique_users_q4
FROM total_shares_q4_user;

-- Problem3 : What is the average difference in days between a user's first and last transactions from October 1st, 2024 to December 31st, 2024, for users who made 2 transactions vs. 3+ transactions?
-- Business insight : users with 3+ transactions have less day difference so this segment customers frequently active so, we have to keep this retention and based on the user survey we solve the problems from our side.
WITH transaction_dates_user AS(
SELECT user_id,
       MAX(transaction_date) AS last_transaction_date,
       MIN(transaction_date) AS first_transaction_date,
       COUNT(*) AS total_transactions
FROM fct_transactions
WHERE transaction_date >= '2024-10-01'
      AND transaction_date < '2025-01-01'
GROUP BY user_id
HAVING COUNT(*) >= 2
),
dates_difference_q4 AS(
SELECT user_id,
       CASE
          WHEN total_transactions = 2 THEN 'two transactions'
          WHEN total_transactions >= 3 THEN '3+ transactions'
       END AS transaction_segment,
       JULIANDAY(last_transaction_date) - JULIANDAY(first_transaction_date) AS day_gap
FROM transaction_dates_user
)

SELECT transaction_segment,
        ROUND(AVG(day_gap),4) AS avg_day_difference
FROM dates_difference_q4
GROUP BY transaction_segment;

