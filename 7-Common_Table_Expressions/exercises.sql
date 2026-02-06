-- Practice Exercises --
-- Utilizing the Olympic database:

-- 1. Winter Olympics Gold Medals
-- * Write a CTE called top_gold_winter to find the top 5 gold-medal-winning countries for Winter Olympics.
WITH top_gold_winter AS (SELECT country_id, SUM(gold) AS golds FROM winter_games GROUP BY country_id ORDER BY golds DESC NULLS LAST LIMIT 5)
-- * Query the CTE to select countries and their medal counts where gold medals won are ≥ 5.
SELECT country_id, golds FROM top_gold_winter WHERE golds >= 5;

-- 2. Tall Athletes
-- * Write a CTE called tall_athletes to find athletes taller than the average height for athletes in the database.
WITH
	tall_athletes AS (
		SELECT id, name, height, gender, age, weight
		FROM athletes
		WHERE height > (
			SELECT AVG(height)
			FROM athletes
		)
	),
-- * Query the CTE to return only female athletes over age 30 who meet the criteria.
	tall_over30_female_athletes AS (SELECT * FROM tall_athletes WHERE gender = 'F' AND age > 30)

-- 3. Average Weight of Female Athletes
-- * Write a CTE called tall_over30_female_athletes for the results of Exercise 2.
-- * Query the CTE to find the average weight of these athletes.
SELECT AVG(weight) AS avg_weight FROM tall_over30_female_athletes;