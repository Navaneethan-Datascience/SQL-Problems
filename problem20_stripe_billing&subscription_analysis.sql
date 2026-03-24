-- How do different pricing tiers affect customer retention and lifecycle in Stripe’s Billing & Subscriptions platform? Using SQL, analyze subscription data to determine baseline subscription counts, assess retention effectiveness, and rank pricing tiers by retention rate. Based on this analysis, what insights can be drawn to refine and optimize the overall pricing strategy?

-- Table schema: 
-- fct_subscriptions(subscription_id, customer_id, pricing_tier, start_date, end_date, renewal_status)

-- Problem 1 : For Quarter 3 of 2024, what is the total number of distinct customers who started a subscription for each pricing tier? This query establishes baseline subscription counts for evaluating customer retention.
-- Insight: premium pricing tier have highest(5) customer who strated their subscription 3rd quarter 2024. 
SELECT pricing_tier,
       COUNT(DISTINCT customer_id) AS distinct_customers
FROM fct_subscriptions
WHERE start_date BETWEEN '2024-07-01' AND '2024-09-30'
GROUP BY pricing_tier;


-- Ptoblem 2: Using subscriptions that started in Q3 2024, for each pricing tier, what percentage of subscriptions were renewed? Subscriptions that have been renewed will have a renewal status of 'Renewed'. This breakdown will help assess retention effectiveness across tiers.
-- Insight: 75% percentage subscribtions renewed in enterprise pricing tier on 3rd quarter 2024 this shows rentention of enterprise customers.

SELECT pricing_tier,
       SUM(CASE WHEN renewal_status = 'Renewed' THEN 1 ELSE 0 END)*100 / COUNT(*) AS renewed_subscriptions_percentage
FROM fct_subscriptions
WHERE start_date BETWEEN '2024-07-01' AND '2024-09-31'
GROUP BY pricing_tier;

-- Problem 3:Based on subscriptions that started in Quarter 3 of 2024, rank the pricing tiers by their retention rate. We’d like to see both the retention rate and the rank for each tier, so we can identify which pricing model keeps customers engaged the longest.
-- Insight: Enterprise(75%) tier have highest retention rate followed by premium(50%) and basic(40%). it shows the custmores satisfied the service they are ready renew the service.


WITH retention_rate_pricing_tier AS(
SELECT pricing_tier,
       SUM(CASE WHEN renewal_status = 'Renewed' THEN 1 ELSE 0 END)*100 /COUNT(*) AS retention_rate
FROM fct_subscriptions
WHERE start_date BETWEEN '2024-07-01' AND '2024-09-31'
GROUP BY pricing_tier
)

SELECT pricing_tier,
       retention_rate,
       DENSE_RANK() OVER(ORDER BY retention_rate DESC) AS rnk
FROM retention_rate_pricing_tier;


-- Businees Insights : premium tier has a most unique customers(5) on q3 2024 even enterprise tier is performing well in the customer retention and subscription renewal we have copy the startegy from Enterprise tier try to imply the startegy in basic and premium tiers also conduct customer survey what are the issues they are facing in the basic and premium services. 