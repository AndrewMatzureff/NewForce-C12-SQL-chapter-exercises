# SQL CASE Statements  
 
---


### SQL Order of Operations
- Remember the order of operations you learned in math class? Some operations occur before others, so calculations don’t just run from left to right.
- SQL is similar in that what happens behind the scenes to create an output doesn’t just follow the query from top to bottom. 
- Similar to mathematical order, SQL processes different parts of a query in a specific sequence.
- **Resource for Further Reading**: [Understanding SQL Order of Operations](https://jvns.ca/blog/2019/10/03/sql-queries-don-t-start-with-select/)

<img src="../images/order_of_operations.png" style="width:400px" >

### `CASE` Statement Basic Syntax

```sql
SELECT film_title,
       CASE 
           WHEN <condition1> THEN <result1>
           WHEN <condition2> THEN <result2>
           ELSE <default result> 
       END AS <alias_name>
FROM specs;
```

---

### Categorizing with `CASE` Statements

- We want to categorize movies as short, medium, or long based on the following criteria:
  - 90 minutes or less is short
  - Between 90 minutes and 120 minutes is medium
  - 120 minutes or more is long
- A CASE Statement  allows us to designate an output based on criteria that we specify


- **Example**: Categorize movies as `short`, `medium`, or `long` based on duration.

  ```sql
  SELECT film_title, 
         length_in_min,
         CASE 
             WHEN length_in_min <= 90 THEN 'short'
             WHEN length_in_min > 90 AND length_in_min < 120 THEN 'medium'
             WHEN length_in_min >= 120 THEN 'long' 
             ELSE 'missing' 
         END AS length_category
  FROM specs;
  ```

| film_title               | length_in_min | length_category |
|--------------------------|---------------|-----------------|
| Avengers: Endgame        | 181           | long           |
| The Lion King            | 118           | medium         |
| Frozen II                | 103           | medium         |
| Spider-Man: Far from Home| 129           | long           |

---

### Aggregation with `CASE` Statements

- Now we don’t really need to see whether any specific movie was short, medium, or long, but instead we wanted to know how many movies from our dataset fall into each category each year. This is a combination of categorizing (short, medium, or long length) plus aggregation (counts for each year).
- Stick with the same criteria for short, medium, and long movies, but now incorporate an aggregation keyword, in this case COUNT, to give us the final result

#### Example 1: Counting Movies by Category and Year

- **Objective**: Count movies in each category (`short`, `medium`, `long`) by release year.

  ```sql
  SELECT release_year,
         COUNT(CASE WHEN length_in_min <= 90 THEN 'short' END) AS short_movies,
         COUNT(CASE WHEN length_in_min > 90 AND length_in_min < 120 THEN 'medium' END) AS medium_movies,
         COUNT(CASE WHEN length_in_min >= 120 THEN 'long' END) AS long_movies
  FROM specs
  WHERE length_in_min IS NOT NULL
  GROUP BY release_year
  ORDER BY release_year DESC;
  ```

| release_year (integer) | short_movies (bigint) | medium_movies (bigint) | long_movies (bigint) |
|---|---|---|---|
| 2019 | 0 | 3 | 7 |
| 2018 | 0 | 3 | 7 |
| 2017 | 1 | 1 | 8 |
| 2016 | 1 | 5 | 4 | 

#### Example 2: Total Movie Minutes per Category and Year
- Now we want to know how many movies fall into each category each year

- **Objective**: Find the total minutes for each movie category by year.

  ```sql
  SELECT release_year,
         SUM(CASE WHEN length_in_min <= 90 THEN length_in_min END) AS short_movies_min,
         SUM(CASE WHEN length_in_min > 90 AND length_in_min < 120 THEN length_in_min END) AS med_movies_min,
         SUM(CASE WHEN length_in_min >= 120 THEN length_in_min END) AS long_movies_min
  FROM specs
  WHERE length_in_min IS NOT NULL
  GROUP BY release_year
  ORDER BY release_year DESC;
  ```
| release_year (integer) | short_movies (bigint) | medium_movies (bigint) | long_movies (bigint) |
|---|---|---|---|
| 2019 | [null] | 321 | 962 |
| 2018 | [null] | 349 | 969 |
| 2017 | 89 | 119 | 1080 |
| 2016 | 87 | 534 | 537 | 
---

### Filtering with `CASE` Statements

- Generally not utilized, you can use CASE statements in the WHERE clause of SQL queries. There are times when using this method might be preferable in terms of readability of code.
- If we wanted to return movies that are rated G and shorter than 90 minutes as well as movies that are rated PG and shorter than 105 minutes but nothing else We have done this without a CASE statement, but let’s take a look at how a CASE statement would work in this kind of situation.
- **Remember**, the WHERE clause must always be a True or False logical statement. So, in addition to categorizing, we will also need to add an element to the CASE statement clause that turns it into a logical statement.



- **Example**: Filter for movies rated `G` and under 90 minutes or rated `PG` and under 105 minutes.

  ```sql
  SELECT *
  FROM specs
  WHERE CASE 
            WHEN mpaa_rating = 'G' AND length_in_min < 90 THEN 'Keep'
            WHEN mpaa_rating = 'PG' AND length_in_min < 105 THEN 'Keep'
            ELSE 'Discard' 
        END = 'Keep';
  ```
| movie_id (integer) | film_title (text) | release_year (integer) | length_in_min (integer) | mpaa_rating (text) | domestic_distributor_id (integer)|
|----------|----------------------|--------------|---------------|-------------|-------------------------|
| 5549     | Frozen II            | 2019         | 103           | PG          | 86124                   |
| 5570     | Despicable Me 3 | 2017    | 89           | PG      | 86127                  |
| 5579     | Finding Dory       | 2016         | 97           | PG       | 86124                   |
| 5582     | The Secret Life of Pets      | 2016         | 97           | PG       | 86127                  |


---

## Additional Resources

- [PostgreSQL CASE Statements](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/)
- [PostgreSQL Conditional Functions](https://www.postgresql.org/docs/current/functions-conditional.html)
- [CASE Statements in SQL](https://www.datacamp.com/tutorial/case-statements-in-postgresql)
- [Panoply: Postgres CASE Statements](https://blog.panoply.io/postgres-case-statement-basics-by-example)

---

## Practice Exercises - Economic & Community Development Grants Database

### Utilize the `ecd` database

1. **Population Categorization**:
   - Using the population table, write a query that selects the county, 2017 population, and uses a case statement to characterize the 2017 population (call this pop_category) according to the following business rule:
     - `high population` greater than or equal to 500,000.
     - `medium population` between 100,000 to 500,000.
     - `low population` less than or equal to 100,000.

2. **Startup Classification**:
   - Write a query that selects the company, landed date, number of new jobs, and a case statement to classify observations (rows) in the table where the project type is `New Startup` according to the following business rule:
     - `small startup` for fewer than 50 jobs.
     - `midsize startup` for 50 to 100 jobs.
     - `large startup` for more than 100 jobs.

3. **Total Population Comparison**:
   - Write a query using the `population` table to find the total population for 2010 and 2017, labeled as `Total_Pop_2010` and `Total_Pop_2017`.

---