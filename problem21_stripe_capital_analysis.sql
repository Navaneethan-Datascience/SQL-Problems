-- How does revenue variability among small businesses impact loan repayment success rates in Stripe Capital’s lending products? Using SQL, analyze repayment data to evaluate the effectiveness of these lending products and determine how different levels of financial stability influence repayment outcomes. Based on this analysis, what insights can be drawn to optimize lending strategies and better support small businesses?

-- Table Schema :
-- fct_loans(loan_id, business_id, loan_amount, loan_issued_date, loan_repaid)
-- dim_businesses(business_id, monthly_revenue, revenue_variability, business_size)

-- Problem 1: What is the average monthly revenue for small businesses that received a loan versus those that did not receive a loan during January 2024? Use the ''business_size'' field to filter for small businesses.

WITH monthly_revenue_business AS (
    SELECT 
        DISTINCT b.business_id,
        CASE
            WHEN l.business_id IS NOT NULL THEN 'loan received'
            ELSE 'loan not received'
        END AS loan_segment,
        monthly_revenue
    FROM dim_businesses AS b
    LEFT JOIN fct_loans AS l 
        ON b.business_id = l.business_id
        AND l.loan_issued_date >= '2024-01-01'
        AND l.loan_issued_date < '2024-02-01'
    WHERE b.business_size = 'small'
)
SELECT 
    loan_segment,
    AVG(monthly_revenue) AS avg_monthly_revenue
FROM monthly_revenue_business
GROUP BY loan_segment;



-- Problem 2 : For loans issued to small businesses in January 2024, what percentage were successfully repaid? Categorize these loans based on the borrowing business’s revenue variability (low, medium, or high) using these values
-- Low: <0.1
-- Medium: 0.1 - 0.3 inclusive
-- High: >0.3


SELECT loan_id,
       CASE 
          WHEN revenue_variability < 0.1 THEN 'Low'
          WHEN revenue_variability >= 0.1 AND revenue_variability <= 0.3 THEN 'Medium'
          WHEN revenue_variability > 0.3 THEN 'High'
       END AS revenue_variability_segment,
       SUM(CASE WHEN loan_repaid = 1 THEN 1 ELSE 0 END)*100/COUNT(*) AS loan_repaid_percentage
FROM fct_loans AS l
JOIN dim_businesses AS b
     ON l.business_id = b.business_id
WHERE loan_issued_date BETWEEN '2024-01-01' AND '2024-01-31' AND business_size = 'small'
GROUP BY revenue_variability_segment;


-- For small businesses during January 2024, what is the loan repayment success rate for each revenue variability category? Order the results from the highest to the lowest success rate to assess the correlation between revenue variability and repayment reliability.


SELECT CASE
          WHEN revenue_variability < 0.1 THEN 'Low'
          WHEN revenue_variability >= 0.1 AND revenue_variability <= 0.3 THEN 'Medium'
          WHEN revenue_variability > 0.3 THEN 'High'
       END AS revenue_variability_segment,
       COUNT(CASE WHEN loan_repaid = 1 THEN 1 END)*100/COUNT(*) AS repayment_success_rate
FROM fct_loans AS l
JOIN dim_businesses AS b
     ON l.business_id = b.business_id
WHERE l.loan_issued_date BETWEEN '2024-01-01' AND '2024-01-31'
      AND business_size = 'small'
GROUP BY revenue_variability_segment
ORDER BY repayment_success_rate DESC;



-- Business Insight : In jan 2024 for all small businessed Revenue variability with less than 0.1 the 'Low' category has the highest payment success rate this defines we can continously lend our product for those small business and high revenue variability segment had a very low repayment sucess rate.