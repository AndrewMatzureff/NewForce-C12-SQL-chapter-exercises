-- Practice Exercises --
-- 1. Generate to query this output:
-- ![excel_chart.png](https://github.com/NewForce-Data-Cohort-12/Data-Curriculum/blob/main/SQL/images/excel_chart.png)
-- 	* Display Country name, 4-digit year, count of Nobel prize winners (where the count is ≥ 1), and country size:
-- 		. Large: Population > 100 million
-- 		. Medium: Population between 50 and 100 million (inclusive)
-- 		. Small: Population < 50 million
-- 	* Sort results so that the country and year with the largest number of Nobel prize winners appear at the top.
-- 	* Export the results as a CSV file.
-- 	* Use Excel to create a chart effectively communicating the findings.
SELECT
	country,
	EXTRACT(YEAR FROM year::date) AS calendar_year,
	nobel_prize_winners,
	CASE
		WHEN pop_in_millions::numeric > 100 THEN 'Large'
		WHEN pop_in_millions::numeric >= 50 THEN 'Medium'
		ELSE 'Small'
	END AS country_size
FROM country_stats
JOIN countries
ON country_stats.country_id = countries.id AND nobel_prize_winners >= 1
ORDER BY nobel_prize_winners DESC, calendar_year, country;

-- 2. Create the output below that shows a row for each country and each year. Use COALESCE() to display unknown when the gdp is NULL.
-- ![output_below.png](https://github.com/NewForce-Data-Cohort-12/Data-Curriculum/blob/main/SQL/images/output_below.png)
SELECT
	TRIM(country) AS country,
	EXTRACT(YEAR FROM year::date) AS calendar_year,
	COALESCE(gdp::numeric::money::varchar, 'unknown') AS gdp_amount
FROM country_stats
JOIN countries
ON country_stats.country_id = countries.id
ORDER BY country, calendar_year;