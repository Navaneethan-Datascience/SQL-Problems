-- How do file naming conventions and co-editing practices vary across organizational segments in Microsoft Teams? Using SQL, analyze file sharing and collaboration data to identify potential security risks. Based on this analysis, what insights can be drawn to recommend targeted improvements that enhance data security and strengthen the platform’s reliability?

-- Problem1: What is the average length of the file names shared for each organizational segment in January 2024?
-- Healthcare segment shred a long length file name because their avg file shared name avg length is 21. 

SELECT o.segment,
       AVG(LENGTH(fs.file_name)) AS file_length
FROM fct_file_sharing AS fs
JOIN dim_organization AS o
      ON fs.organization_id = o.organization_id
WHERE fs.shared_date  BETWEEN '2024-01-01' AND '2024-01-31'
GROUP BY o.segment;


-- Problem2:How many files were shared with names that start with the same prefix as the organization name, concatenated with a hyphen, in February 2024?
-- 5 files names with prefix of thier organization name.


SELECT COUNT(fs.file_id) AS total_files_shared_file_and_org_name
FROM fct_file_sharing AS fs
JOIN dim_organization AS o
      ON fs.organization_id = o.organization_id
WHERE fs.shared_date BETWEEN '2024-02-01' AND '2024-02-29' AND fs.file_name LIKE CONCAT(organization_name,'-%');

-- Problem3: Identify the top 3 organizational segments with the highest number of files shared where the co-editing user is NULL, indicating a potential security risk, during the first quarter of 2024.

-- technology(5), retail(2), and finance(2) these segments are highest files shared in first quarter 2024 these segments are considered as potential security risk.

SELECT o.segment,
       COUNT(fs.file_id) AS total_files_shared
FROM fct_file_sharing AS fs
JOIN dim_organization AS o
      ON fs.organization_id = o.organization_id
WHERE fs.shared_date BETWEEN '2024-01-01' AND '2024-03-31' AND co_editing_user_id IS NULL
GROUP BY o.segment
ORDER BY total_files_shared DESC
LIMIT 3;