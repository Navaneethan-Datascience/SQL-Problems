-- How can AI-driven code suggestions on the OpenAI Codex platform be optimized to enhance developer productivity? Using SQL, analyze performance metrics across different programming languages to evaluate coding speed and error reduction. Based on this analysis, what insights can be drawn to identify areas for improvement and validate the effectiveness of existing code suggestions

-- Table Schema:
-- fct_code_suggestions(suggestion_id, developer_id, programming_language, complexity_level, coding_speed_improvement, error_reduction_percentage, suggestion_date)

-- What is the average coding speed improvement percentage for each programming language in April 2024? This analysis will help us determine if current suggestions are effectively boosting coding speed.

SELECT programming_language,
       ROUND(AVG(coding_speed_improvement),2) AS avg_coding_speed_improvement
FROM fct_code_suggestions
WHERE suggestion_date >= '2024-04-01'
      AND suggestion_date < '2024-05-01'
GROUP BY programming_language;


-- For each programming language in April 2024, what is the minimum error reduction percentage observed across all AI-driven code suggestions? This will help pinpoint languages where error reduction is lagging and may need targeted improvements.

SELECT programming_language,
       MIN(error_reduction_percentage) AS min_error_reduction_percentage
FROM fct_code_suggestions
WHERE suggestion_date >= '2024-04-01'
     AND suggestion_date < '2024-05-01'
GROUP BY programming_language;


-- For April 2024, first concatenate the programming language and complexity level to form a unique identifier. Then, using the average of coding speed improvement and error reduction percentage as a combined metric, which concatenated combination shows the highest aggregated improvement? This final analysis directly informs efforts to achieve a targeted increase in developer productivity and error reduction.

SELECT programming_language ||' '|| complexity_level,
       (
        AVG(coding_speed_improvement) + 
        AVG(error_reduction_percentage)
        )/2 AS combined_metrics
FROM fct_code_suggestions
WHERE suggestion_date >= '2024-04-01'
      AND suggestion_date < '2024-05-01'
GROUP BY programming_language ||' '|| complexity_level
ORDER BY combined_metrics DESC
LIMIT 1;