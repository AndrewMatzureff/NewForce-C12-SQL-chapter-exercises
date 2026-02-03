-- Practice Exercises --

-- 1. Find Athletes from Summer or Winter Games:
-- 	* Write a query to list all athlete names who participated in the Summer or Winter Olympics. Ensure no duplicates appear in the final table using a set theory clause.
WITH participants AS (
	SELECT athlete_id AS id FROM summer_games
	UNION
	SELECT athlete_id AS id FROM winter_games
)
SELECT name FROM participants
LEFT JOIN athletes USING(id)
ORDER BY name;

-- 2. Find Countries Participating in Both Games:
-- 	* Write a query to retrieve country_id and country_name for countries in the Summer Olympics.
SELECT DISTINCT country_id, country FROM summer_games JOIN countries ON country_id = id;
-- 	* Add a JOIN to include the country’s 2016 population and exclude the country_id from the SELECT statement.
WITH
	summer AS (
		WITH participants AS (
			SELECT DISTINCT country_id, country FROM summer_games JOIN countries ON country_id = id
		)
		SELECT country, pop_in_millions
		FROM participants JOIN country_stats USING(country_id)
		WHERE year = '2016-01-01' AND pop_in_millions IS NOT NULL
	),
-- 	* Repeat the process for the Winter Olympics.
	winter AS (
		WITH participants AS (
			SELECT DISTINCT country_id, country FROM winter_games JOIN countries ON country_id = id
		)
		SELECT country, pop_in_millions
		FROM participants JOIN country_stats USING(country_id)
		WHERE year = '2016-01-01' AND pop_in_millions IS NOT NULL
	)
-- 	* Use a set theory clause to combine the results.
SELECT * FROM summer UNION SELECT * FROM winter;

-- 3. Identify Countries Exclusive to the Summer Olympics:
-- 	* Return the country_name and region for countries present in the countries table but not in the winter_games table.
-- 	  (Hint: Use a set theory clause where the top query doesn’t involve a JOIN, but the bottom query does.)
SELECT country, region FROM (
	SELECT id AS country_id FROM countries
	EXCEPT
	SELECT country_id FROM winter_games
)
JOIN countries ON country_id = id;