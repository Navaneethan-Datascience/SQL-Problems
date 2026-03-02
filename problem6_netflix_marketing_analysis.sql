-- How efficient is marketing spend in emerging markets for Netflix? Using SQL, analyze the allocation of marketing budgets and the resulting subscriber acquisition across different countries. Based on this analysis, what insights can be drawn to optimize marketing strategies and improve budget distribution?


-- Retrieve the total marketing spend in each country for Q1 2024 to help inform budget distribution across regions.

-- budget distribution across region company planned budget more money on Brazil with $405001.25
SELECT c.country_name,
       SUM(ms.amount_spent) AS marketing_spend_amount
FROM fact_marketing_spend AS ms
JOIN dimension_country AS c
     ON ms.country_id = c.country_id
WHERE ms.campaign_date BETWEEN '2024-01-01' AND '2024-03-31'
GROUP BY c.country_name
ORDER BY SUM(ms.amount_spent) DESC;

-- List the number of new subscribers acquired in each country (with name) during January 2024, renaming the subscriber count column to 'new_subscribers' for clearer reporting purposes.

-- India has the highest new subscribers(5000) and Indonesia has the second highest new subscribers(1500) 
SELECT dc.country_id,
       dc.country_name,
       SUM(ds.num_new_subscribers) AS new_subscribers
FROM fact_daily_subscriptions AS ds
JOIN dimension_country AS dc
     ON ds.country_id = dc.country_id
WHERE ds.signup_date BETWEEN '2024-01-01' AND '2024-01-31'
GROUP BY dc.country_id, dc.country_name;

-- Determine the average marketing spend per new subscriber for each country in Q1 2024 by rounding up to the nearest whole number to evaluate campaign efficiency.