# SQL Subqueries  

## **What Are SQL Subqueries?**  
Subqueries, also known as nested queries or inner queries, are powerful tools in SQL that leverage the order of operations.  
- Similar to parentheses in math, subqueries are executed **first** before the outer query processes the results.  
- Subqueries can be used in:  
  - **SELECT** clauses  
  - **FROM** clauses  
  - **WHERE** clauses  

---

## **Examples of Subqueries**

### **Subquery in a WHERE Clause**  
**Scenario**: Find movie details for all movies with a runtime shorter than the average runtime.  
A subquery calculates the average runtime dynamically to ensure it always reflects the current data.

```sql
SELECT *
FROM specs
WHERE length_in_min < (SELECT AVG(length_in_min)
                       FROM specs);
```
> Notice the parentheses around the subquery - **always** use them in subqueries

| **movie_id** | **film_title** | **release_year** | **length_in_min** | **mpaa_rating** | **domestic_distributor_id** |
|--------------|----------------|------------------|-------------------|-----------------|----------------------------|
| 5548         | The Lion King  | 2019            | 118               | PG             | 86124                     |
| 5549         | Frozen II      | 2019            | 103               | PG             | 86214                     |
| 5552         | Toy Story 4    | 2019            | 100               | G              | 86214                     |
| 5563         | Venom          | 2018            | 112               | PG-13          | 86215                     |


---

### **Subquery in a FROM Clause**  
**Scenario**: Determine how many distributors released their first movie each year.  
A subquery calculates the first year for each distributor, which is then used to aggregate the count of distributors by year.

```sql
SELECT first_year AS year, 
       COUNT(domestic_distributor_id) AS num_dist_1st_movie
FROM (SELECT domestic_distributor_id,
             MIN(release_year) AS first_year
      FROM specs
      GROUP BY domestic_distributor_id) AS firsts
GROUP BY first_year
ORDER BY year;
```

**Resulting Table:**  
| **year** | **num_dist_1st_movie** |
|----------|------------------------|
| 1977     | 5                      |
| 1979     | 2                      |
| 1982     | 1                      |
| 1985     | 1                      |
| 1987     | 2                      |

> Use an **alias** for subqueries in the `FROM` clause.

---

### **Subquery in a SELECT Clause**  
**Scenario**: Return movie titles and lengths along with a column indicating whether each movie is longer, shorter, or equal to the average runtime.

> Here, we need the aggregation as a comparison value, but we don’t want that comparison to serve as a filter. Instead, it’s creating conditional logic for how to categorize each movie. Hopefully, this makes you think of CASE statements, and, as we know, CASE statements go in the SELECT clause.


```sql
SELECT film_title, 
       length_in_min,
       CASE 
           WHEN (SELECT AVG(length_in_min) FROM specs) < length_in_min THEN 'longer_than_avg'
           WHEN (SELECT AVG(length_in_min) FROM specs) > length_in_min THEN 'shorter_than_avg'
           ELSE 'avg'
       END AS length_comparison
FROM specs;
```

**Resulting Table:**  
| **film_title**          | **length_in_min** | **length_comparison** |
|--------------------------|-------------------|------------------------|
| Avengers: Endgame        | 181               | longer_than_avg        |
| The Lion King            | 118               | shorter_than_avg       |
| Frozen II                | 103               | shorter_than_avg       |

---

## **SQL Subqueries - Rules**
- Subqueries **must be enclosed in parentheses**.  
- A subquery must include at least a **SELECT** clause and a **FROM** clause.  
- Subqueries in the **FROM** clause must be aliased.  
- Use **ORDER BY** in the outer query to control the final output order (if needed).  
- Subqueries require additional computing power, so avoid using them unnecessarily when simpler solutions are available.

---

## **Best Practices**

### **Query Formatting**  
- Align main keywords, `SELECT`, `FROM`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, and `LIMIT`,  for readability.  
- Indent subqueries and conditions for clarity.

```sql
SELECT first_year AS year, 
       COUNT(domestic_distributor_id) AS num_dist_1st_movie
FROM (SELECT domestic_distributor_id,
             MIN(release_year) AS first_year
      FROM specs
      GROUP BY domestic_distributor_id) AS firsts
WHERE first_year < 2000
  AND mpaa_rating <> 'R'
GROUP BY first_year
ORDER BY year;
```

### **Adding Comments**  
- Use comments to explain your query and its logic.  
- Comments make your code easier to understand for others and your future self.
> If potential employers look at your github, they'll love seeing comments

```sql
-- Select all columns from the specs table
SELECT *
FROM specs
-- Filter to movies with lengths below the database average
WHERE length_in_min < (SELECT AVG(length_in_min)
                       FROM specs);
```

---

## **Additional Resources**
- [SQL Subquery Tutorial](https://www.sqltutorial.org/sql-subquery/)  
- [PostgreSQL Subquery Documentation](https://www.postgresql.org/docs/current/functions-subquery.html)  
- [DataCamp: Joining Data in SQL - Chapter 4](https://app.datacamp.com/learn/courses/joining-data-in-sql)  
- [DataCamp: Data Manipulation in SQL - Chapters 2 & 3](https://app.datacamp.com/learn/courses/data-manipulation-in-sql)

---

## **Practice Exercises**

- Find which county had the most months with unemployment rates above the state average:  
  1. Write a query to calculate the state average unemployment rate.  
  2. Use this query in the **WHERE** clause of an outer query to filter for months above the average.  
  3. Use `Select` to count the number of months each county was above the average. Which country had the most?


- Find the average number of jobs created for each county based on projects involving the largest capital investment by each company:  
  1. Write a query to find each company’s largest capital investment, returning the company name along with the relevant capital investment amount for each.  
  2. Use this query in the **FROM** clause of an outer query, alias it, and join it with the original table.  
  > Use `Select *` in the outer query to make sure your join worked properly
  3. Adjust the **SELECT** clause to calculate the average number of jobs created by county.  
