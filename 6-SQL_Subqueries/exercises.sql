-- Practice Exercises --

-- 1. Find which county had the most months with unemployment rates above the state average:
-- 	i. Write a query to calculate the state average unemployment rate.
SELECT AVG(value) FROM unemployment;
-- 	ii. Use this query in the WHERE clause of an outer query to filter for months above the average.
SELECT * FROM unemployment WHERE value > (SELECT AVG(value) FROM unemployment);
-- 	iii. Use Select to count the number of months each county was above the average. Which country had the most?
SELECT county, COUNT(*) AS months_exceeding_avg FROM unemployment WHERE value > (SELECT AVG(value) FROM unemployment) GROUP BY county ORDER BY months_exceeding_avg DESC;
-- Answer: Giles, Sevier, Benton, Loudon = 65

-- 2. Find the average number of jobs created for each county based on projects involving the largest capital investment by each company:
-- 	i. Write a query to find each company’s largest capital investment, returning the company name along with the relevant capital investment amount for each.
SELECT company, MAX(capital_investment) AS max_cap_inv FROM ecd GROUP BY company ORDER BY company;
-- 	ii. Use this query in the FROM clause of an outer query, alias it, and join it with the original table.
-- 		Use Select * in the outer query to make sure your join worked properly.
SELECT * FROM
	(SELECT company, MAX(capital_investment) AS max_cap_inv FROM ecd GROUP BY company ORDER BY company)
JOIN ecd USING(company);
-- 	iii. Adjust the SELECT clause to calculate the average number of jobs created by county.
SELECT company, max_cap_inv, AVG(new_jobs) AS avg_new_jobs FROM
	(SELECT company, MAX(capital_investment) AS max_cap_inv FROM ecd GROUP BY company ORDER BY company)
JOIN ecd USING(company)
GROUP BY company, max_cap_inv;