-- i.	How many counties are represented? How many companies?
SELECT COUNT(DISTINCT(county)) FROM ecd;
-- Answer: 88

-- ii.	How many companies did not get ANY Economic Development grants (ed) for any of their projects? (Hint, you will probably need a couple of steps to figure this one out)
SELECT COUNT(*) FROM ecd WHERE ed IS NULL OR ed::numeric = 0.0;
-- Answer: 703

-- iii.	What is the total capital_investment, in millions, when there was a grant received from the fjtap? Call the column fjtap_cap_invest_mil.
SELECT capital_investment AS fjtap_cap_invest_mil FROM ecd WHERE fjtap IS NOT NULL AND fjtap::numeric > 0
-- Answer: $12,634,623,829.00

-- iv.	What is the average number of new jobs for each county_tier?
SELECT county_tier, AVG(new_jobs) FROM ecd GROUP BY county_tier
-- Answer: 1	200.6921052631578947, 3	112.4397163120567376, 4	88.9891304347826087, 2	128.4463667820069204

-- v.	How many companies are LLCs? Call this value llc_companies. (Hint, combine COUNT() and DISTINCT(). Also, consider that LLC may not always be capitalized the same in company names. Find a SQL keyword that can help you with this.)
SELECT COUNT(*) FROM ecd WHERE company ILIKE '%LLC%'
-- Answer: 137