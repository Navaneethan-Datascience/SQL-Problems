-- How do Amazon Prime members engage with exclusive promotions such as special deals and early product access? Using SQL, analyze interaction data to identify engagement patterns and evaluate how these behaviors influence overall member value. Based on this analysis, what insights can be drawn to target highly engaged members and drive stronger participation in promotional offerings?

-- Table Schema
-- fct_prime_deals(deal_id, member_id, purchase_amount, purchase_date)

-- Problem1: To assess the popularity of promotions among Prime members, how many Prime members purchased deals in January 2024? What is the average number of deals purchased per member?

SELECT COUNT(DISTINCT member_id) AS members_purchased_jan,
       ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT member_id),2) AS avg_deal_per_member_jan
FROM fct_prime_deals
WHERE purchase_date >= '2024-01-01'
      AND purchase_date < '2024-02-01';

-- Problem2: To gain insights into purchase patterns, what is the distribution of members based on the number of deals purchased in February 2024? Group the members into the following categories: 1-2 deals, 3-5 deals, and more than 5 deals.

WITH member_deals_feb AS(
SELECT member_id,
       COUNT(*) AS total_deals
FROM fct_prime_deals
WHERE purchase_date >= '2024-02-01'
      AND purchase_date < '2024-03-01'
GROUP BY member_id
)

SELECT CASE
          WHEN total_deals >= 1 AND total_deals <= 2 THEN '1-2 deals'
          WHEN total_deals >= 3 AND total_deals <= 5 THEN '3-5 deals'
          ELSE 'more than 5 deals'
       END AS deal_segment,
       COUNT(*) AS member_distributions
FROM member_deals_feb
GROUP BY deal_segment;


-- Problem3 : To target highly engaged members for tailored promotions, can we identify Prime members who purchased more than 5 exclusive deals between January 1st and March 31st, 2024? How many such members are there and what is their average total spend on these deals?

WITH member_engagement_q1 AS(
SELECT member_id,
       COUNT(*) AS total_deals,
       SUM(purchase_amount) AS total_purchase_amount
FROM fct_prime_deals
WHERE purchase_date >= '2024-01-01'
      AND purchase_date < '2024-04-01'
GROUP BY member_id
)

SELECT COUNT(*) AS members_more_than_5_deals,
       AVG(total_purchase_amount) AS avg_purchase_amount
FROM member_engagement_q1
WHERE total_deals > 5;