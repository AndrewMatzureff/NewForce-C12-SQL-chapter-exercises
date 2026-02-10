-- Practice Exercises --

-- 1. Use a window function to add columns showing:
-- 	* The maximum population (max_pop) for each county.
-- 	* The minimum population (min_pop) for each county.
SELECT *,
	MAX(population) OVER() AS max_pop,
	MIN(population) OVER() AS min_pop
FROM population; -- Answer: {max_pop: 939425, min_pop: 5004}

-- 2. Rank counties from largest to smallest population for each year.
SELECT *, RANK() OVER(PARTITION BY year ORDER BY population DESC) AS pop_rank FROM population;

-- 3. Use the unemployment table:
-- 	* Calculate the rolling 12-month average unemployment rate using the unemployment table.
-- 	* Include the current month and the preceding 11 months.
-- 	* Hint: Reference two columns in the ORDER BY argument (county and period).
SELECT *,
	AVG(value) OVER(
		PARTITION BY year
		ORDER BY county, period
		ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
	) AS twelve_month_avg
FROM unemployment;