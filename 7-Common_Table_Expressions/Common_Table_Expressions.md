
# Common Table Expressions (CTEs)  


## **CTE Fundamentals**  

- CTEs are **temporary datasets** that can be referenced in the `FROM` clause of a main query.  
- Like subqueries, the query inside the CTE could run independently, but it is structured to integrate with the outer query.  
- CTEs use the **`WITH`** keyword and appear **above** the main query.  
- CTEs improve readability and maintainability, especially when queries become complex.  
- Use CTEs wisely:
  - Avoid CTEs for simple tasks that a subquery can handle.  
  - Apply filters and select only relevant columns to optimize performance.

---

## **CTE Example - Exploring Movie Budgets and Revenues**

**Scenario**: Investigate whether there is a pattern between movie budgets, revenues, and the number of years the distributor has been in business.

> To calculate the number of years a distributor was in the business at the time of each of their movies’ release, we must calculate the difference between their earliest year and the release year of each of their movies. This could be accomplished with a subquery in `FROM`but that isn't the best option


### **Step 1: Distributor’s Earliest Year**  
Query the earliest release year for each distributor:

```sql
SELECT domestic_distributor_id,
       MIN(release_year) AS first_year
FROM specs
WHERE domestic_distributor_id IS NOT NULL
GROUP BY domestic_distributor_id;
```

| **domestic_distributor_id** | **first_year** |
|-----------------------------|----------------|
| 86126                       | 1977           |
| 86138                       | 1998           |
| 86143                       | 1982           |
| 86134                       | 2004           |
| 86124                       | 1987           |

---

### **Step 2: Distributor’s Years in Business**  
Turn the query into a CTE and calculate how long distributors have been in business for each movie:

```sql
WITH first_movies AS (
  SELECT domestic_distributor_id,
         MIN(release_year) AS first_year
  FROM specs
  WHERE domestic_distributor_id IS NOT NULL
  GROUP BY domestic_distributor_id
)
SELECT movie_id,
       domestic_distributor_id,
       release_year - first_year AS years_in_biz
FROM specs
INNER JOIN first_movies 
USING(domestic_distributor_id);
```
> The CTE: `WITH first_movies AS (SELECT domestic_distributor_id, MIN(release_year) AS first_year FROM specs WHERE domestic_distributor_id IS NOT NULL GROUP BY domestic_distributor_id)`\
>Notice `WITH` comes first, then the name of the CTE (make this a meaningful name) then `AS`. The query portion must go in parentheses\
>We can reference the CTE name just like we would a table name in our main `FROM` clause - `INNER JOIN first_movies` 


| **movie_id** | **domestic_distributor_id** | **years_in_biz** |
|--------------|-----------------------------|------------------|
| 5547         | 86124                       | 32               |
| 5548         | 86124                       | 32               |

---

### **Step 3: Include Budget and Revenue Data**  
Add movie budget and revenue by joining the revenue table:

```sql
WITH first_movies AS (
  SELECT domestic_distributor_id,
         MIN(release_year) AS first_year
  FROM specs
  WHERE domestic_distributor_id IS NOT NULL
  GROUP BY domestic_distributor_id
)
SELECT movie_id,
       domestic_distributor_id,
       release_year - first_year AS years_in_biz,
       film_budget::money,
       worldwide_gross::money
FROM specs
INNER JOIN first_movies 
USING(domestic_distributor_id)
INNER JOIN revenue 
USING(movie_id);
```
> We select the budget and gross columns from the revenue table, and then change the data type to money so the output will be easier to read and understand\
> We do a second `INNER JOIN` to connect the revenue table. We only want to include movies that have financial data available


| **movie_id** | **domestic_distributor_id** | **years_in_biz** | **film_budget**     | **worldwide_gross**    |
|--------------|-----------------------------|------------------|---------------------|------------------------|
| 5547         | 86124                       | 32               | $356,000,000.00     | $2,797,800,564.00      |
| 5548         | 86124                       | 32               | $260,000,000.00     | $1,656,943,394.00      |
| 5549         | 86124                       | 32               | $150,000,000.00     | $1,420,560,456.00      |
| 5550         | 86125                       | 29               | $160,000,000.00     | $1,131,927,996.00      |



### **Step 4: Average Budget and Revenue by Years in Business**  
Calculate the average budget and revenue for each number of years in business:

```sql
WITH first_movies AS (
  SELECT domestic_distributor_id,
         MIN(release_year) AS first_year
  FROM specs
  WHERE domestic_distributor_id IS NOT NULL
  GROUP BY domestic_distributor_id
)
SELECT release_year - first_year AS years_in_biz,
       AVG(film_budget)::money AS avg_budget,
       AVG(worldwide_gross)::money AS avg_gross
FROM specs
INNER JOIN first_movies 
USING(domestic_distributor_id)
INNER JOIN revenue 
USING(movie_id)
GROUP BY release_year - first_year
ORDER BY years_in_biz;
```

| **years_in_biz** | **avg_budget**         | **avg_gross**         |
|------------------|------------------------|-----------------------|
| 0                | $27,948,000.00         | $325,086,840.72       |
| 1                | $31,742,857.14         | $280,081,458.64       |
| 2                | $45,028,571.43         | $235,062,862.21       |
| 3                | $29,180,000.00         | $203,656,127.53       |
| …                | …                      | …                     |
| 39               | $122,000,000.00        | $804,738,640.25       |
| 40               | $159,666,666.67        | $1,030,883,846.33     |
| 41               | $145,000,000.00        | $923,283,771.00       |
| 42               | $127,500,000.00        | $914,970,285.00       |

> A general trend shows that more years in business = larger budgets, greater revenue - there are many more variables to consider but this trend could be enough to inspire further investigation

---

## **Compare and Contrast: Subqueries vs. CTEs**

| **Feature**                     | **Subqueries**                          | **CTEs**                               |
|----------------------------------|-----------------------------------------|----------------------------------------|
| Standalone Query                | Yes                                     | Yes                                    |
| Resource Consideration          | Use thoughtfully                        | Use thoughtfully                       |
| Placement                       | Can be used in multiple query clauses   | Always declared in the `WITH` clause   |
| Alias Requirement               | Not always required                     | Always required                        |
| Best Use Case                   | Simpler queries                        | Complex queries or for improved readability |

---

## **Additional Resources**
- [GeeksforGeeks: PostgreSQL CTE](https://www.geeksforgeeks.org/postgresql-cte/)  
- [PostgreSQL Official Documentation](https://www.postgresql.org/docs/current/queries-with.html)  
- [PostgreSQL Tutorial on CTEs](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-cte/)  
> This next one gets super technical - not necessary reading - but interesting for those who want to learn more about code optimization 
- [CTE Optimization](https://medium.com/alan/ctes-optimization-8c082efc47ef)
---

## **Practice Exercises**

Utilizing the Olympic database: 
1. **Winter Olympics Gold Medals**  
   - Write a CTE called `top_gold_winter` to find the **top 5 gold-medal-winning countries** for Winter Olympics.  
   - Query the CTE to select countries and their medal counts where gold medals won are **≥ 5**.

2. **Tall Athletes**  
   - Write a CTE called `tall_athletes` to find athletes taller than the **average height** for athletes in the database.  
   - Query the CTE to return only female athletes over age **30** who meet the criteria.

3. **Average Weight of Female Athletes**  
   - Write a CTE called `tall_over30_female_athletes` for the results of Exercise 2.  
   - Query the CTE to find the **average weight** of these athletes.  
