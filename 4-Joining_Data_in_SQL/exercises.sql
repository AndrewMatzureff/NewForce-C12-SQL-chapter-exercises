-- Practice Exercises - Olympics Database
-- Exploratory Data Analysis (EDA): Get familiar with the [tables and structure](https://github.com/NewForce-Data-Cohort-12/Data-Curriculum/blob/main/SQL/data/olympics_data_dictonary+erd.pdf):

-- 1. How many rows are in the athletes table? How many distinct athlete ids?
SELECT COUNT(id) AS rows, COUNT(DISTINCT id) AS distinct_athlete_ids FROM athletes;
/* Answer:
	"rows"	"distinct_athlete_ids"
	4216	4215
*/

-- 2. Which years are represented in the summer_games, winter_games, and country_stats tables?
SELECT year::date FROM country_stats
UNION
SELECT year FROM summer_games
UNION
SELECT year FROM winter_games
ORDER BY year;
-- Answer: 2000-2016

-- 3. How many distinct countries are represented in the countries and country_stats table?
SELECT id FROM countries FULL JOIN (SELECT DISTINCT country_id FROM country_stats) ON id = country_id;
-- Answer: 203

-- 4. How many distinct events are in the winter_games and summer_games table?
SELECT DISTINCT event FROM winter_games FULL JOIN (SELECT DISTINCT event FROM summer_games) USING(event);
-- Answer: 127

-- 5. Count the number of athletes who participated in the summer games for each country. Your output should have country name and number of athletes in their own columns. Did any country have no athletes?
SELECT country_id, country, COUNT(DISTINCT athlete_id) AS participants
FROM summer_games LEFT JOIN countries ON country_id = countries.id
GROUP BY country_id, country ORDER BY participants;
--Answer: no

-- 6. Write a query to list countries by total bronze medals, with the highest totals at the top and nulls at the bottom.
CREATE OR REPLACE VIEW bronze_medals_by_country AS
WITH
	summer AS (
		SELECT country_id, SUM(COALESCE(sg.bronze, 0)) AS sg_bronze
		FROM summer_games sg
		GROUP BY country_id
	),
	winter AS (
		SELECT country_id, SUM(COALESCE(wg.bronze, 0)) AS wg_bronze
		FROM winter_games wg
		GROUP BY country_id
	)
SELECT
    country_id,
    COALESCE(s.sg_bronze, 0) + COALESCE(w.wg_bronze, 0) AS bronze_medals
FROM summer s
FULL OUTER JOIN winter w
    USING(country_id)
ORDER BY bronze_medals DESC;
-- 	* Adjust the query to only return the country with the most bronze medals
WITH
	most_bronze_medals AS (
		SELECT country_id, bronze_medals
		FROM bronze_medals_by_country
		WHERE bronze_medals = (
		    SELECT MAX(bronze_medals)
		    FROM bronze_medals_by_country
		)
	)
	SELECT country, bronze_medals
	FROM most_bronze_medals
	LEFT JOIN countries
	ON country_id = id;
/* Answers:
	"country"					"bronze_medals"
	"   CAN - Canada"			22
	"U.S.A. - United States"	22
*/

-- 7. Calculate the average population in the country_stats table for countries in the winter_games. This will require 2 joins.countries that participated in the winter_games
SELECT country, AVG(pop_in_millions::numeric) AS avg_pop
FROM winter_games
INNER JOIN countries
ON winter_games.country_id = countries.id
INNER JOIN country_stats
ON countries.id = country_stats.country_id
GROUP BY country
ORDER BY avg_pop DESC;

-- 8. Identify countries where the population decreased from 2000 to 2006.
SELECT country, a.year, a.pop_in_millions, b.year, b.pop_in_millions
FROM country_stats AS a
INNER JOIN country_stats AS b
USING(country_id)
INNER JOIN countries
ON a.country_id = countries.id
WHERE a.year = '2000-01-01' AND b.year = '2006-01-01'
AND a.pop_in_millions::numeric > b.pop_in_millions::numeric;