
# Introduction to SQL  


### 1. What is SQL?

- **SQL (Structured Query Language)**: The language used to interact with a database.
  - **How it Works**:
    - Write a query to define the data you want to retrieve.
    - The query is sent to a specified database.
    - Results are returned based on the query.
  - **Role of Data Analysts**:
    - Analysts often use SQL to examine data, perform calculations, and generate insights without making permanent changes.

### 2. What Can We Do with Queries?

- **Capabilities**:
  - Select all or specific columns from a table.
  - Aggregate data and find unique values.
  - Filter data based on criteria.
  - Select or avoid null values.
  - Perform calculations and alias (temporarily rename) columns.
  - Organize results and combine data from multiple tables.

### 3. Keywords

- **Definition**: SQL uses defined keywords in a structured format to create queries.
- **Basic Query Structure**:
  - Use `SELECT` to choose columns.
  - Use `FROM` to specify the table.
    > An asterisk(*) in the SELECT statement indicates that you want all available columns returned


  - Example:

    ```sql
    SELECT *
    FROM specs;
    ```
  - **Example Table (`specs`)**:

    | movie_id (integer) | film_title (text) | release_year (integer) | length_in_min (integer) | mpaa_rating (text) | domestic_distributor_id (integer)|
    |----------|----------------------|--------------|---------------|-------------|-------------------------|
    | 5547     | Avengers: Endgame    | 2019         | 181           | PG-13       | 86124                   |
    | 5548     | The Lion King        | 2019         | 118           | PG          | 86124                   |



    

### 4. Frequently Used SQL Keywords

- `SELECT`, `FROM`, `AS`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT`
- `AND`, `OR`, `BETWEEN`, `IN`, `IS NULL`, `LIKE`
- `DISTINCT`, `COUNT()`, `AVG()`, `SUM()`, `MAX()`, `MIN()`

### 5. Format of a Basic Query

> In most cases, each keyword goes on a new line

```sql
SELECT *
FROM table_name
WHERE column = value
LIMIT 5;
```

- Best practices:
  - Place each keyword on a new line.
  - End with a semicolon.
  - Write keywords in ALL CAPS.
  - Follow `SELECT` and `FROM` with selection and return criteria.

- **Resource for SQL style**: [SQL Style Guide](https://www.sqlstyle.guide/)

---

## Query Examples - Movies Database

`specs`:
| movie_id (integer) | film_title (text) | release_year (integer) | length_in_min (integer) | mpaa_rating (text) | domestic_distributor_id (integer)|
|----------|----------------------|--------------|---------------|-------------|-------------------------|
| 5547     | Avengers: Endgame    | 2019         | 181           | PG-13       | 86124                   |
| 5548     | The Lion King        | 2019         | 118           | PG          | 86124                   |
| 5549     | Frozen II            | 2019         | 103           | PG          | 86124                   |
| 5550     | Spider-Man: Far From Home | 2019    | 129           | PG-13       | 86125                   |
| 5549     | Captain Marvel       | 2019         | 123           | PG-13       | 86124                   |


### 1. Selecting All Columns

```sql
SELECT *
FROM specs;
```
| movie_id (integer) | film_title (text) | release_year (integer) | length_in_min (integer) | mpaa_rating (text) | domestic_distributor_id (integer)|
|----------|----------------------|--------------|---------------|-------------|-------------------------|
| 5547     | Avengers: Endgame    | 2019         | 181           | PG-13       | 86124                   |
| 5548     | The Lion King        | 2019         | 118           | PG          | 86124                   |
| 5549     | Frozen II            | 2019         | 103           | PG          | 86124                   |
| 5550     | Spider-Man: Far From Home | 2019    | 129           | PG-13       | 86125                   |
| 5549     | Captain Marvel       | 2019         | 123           | PG-13       | 86124                   |
### 2. Selecting Specific Columns

```sql
SELECT movie_id, film_title
FROM specs;
```


| movie_id (integer) | film_title (text) |
|----------|----------------------|
| 5547     | Avengers: Endgame    |
| 5548     | The Lion King        |
| 5549     | Frozen II            |
| 5550     | Spider-Man: Far From Home |
| 5549     | Captain Marvel       |
### 3. Aggregating Data

- **Count Example**:

  ```sql
  SELECT COUNT(movie_id)
  FROM specs;
  ```

|count (bigint) |
|---|
| 430 |

- **Average Example**:

  ```sql
  SELECT AVG(length_in_min)
  FROM specs;
  ```

|avg (numeric) |
|---|
|120.6023255 |


### 4. Grouping Data

- Grouping data by a specific column:

  ```sql
  SELECT mpaa_rating, AVG(length_in_min)
  FROM specs
  GROUP BY mpaa_rating;
  ```

|mpaa_rating (text) | avg (numeric) |
|---|---|
|PG | 110.360902255 |
|[null] | 123.000000000 |
|PG-13 | 130.247191011 |
|R | 122.810526315 |
|G | 95.9565217391 |


### 5. Aliasing

- **Purpose**: Aliasing makes complex calculations more readable.

  ```sql
  SELECT MIN(length_in_min) AS shortest_movie_min
  FROM specs;
  ```

|shortest_movie_min (integer) |
|---|
| 60 |

### 6. Selecting Unique Values

```sql
SELECT DISTINCT(domestic_distributor_id)
FROM specs;
```
|domestic_distributor_id (integer)|
|---|
|86144|
|86142|
|86137|
|86125|
|[null]|



### 7. Using Multiple Criteria

```sql
SELECT *
FROM specs
WHERE domestic_distributor_id = 86124
  AND mpaa_rating IN ('G', 'PG')
  AND length_in_min BETWEEN 100 AND 120
  AND film_title LIKE 'Frozen%';
```
| movie_id (integer) | film_title (text) | release_year (integer) | length_in_min (integer) | mpaa_rating (text) | domestic_distributor_id (integer)|
|----------|----------------------|--------------|---------------|-------------|-------------------------|
| 5549     | Frozen II    | 2019         | 103           | PG       | 86124                   |
| 5549     | Frozen    | 2013         | 102           | PG       | 86124                   |

### 8. Handling Null Values

```sql
SELECT movie_id, film_title, release_year
FROM specs
WHERE mpaa_rating IS NULL;
```
| movie_id (integer) | film_title (text) | release_year (integer) |
|---|---|---|
|5573| Wolf Warrior 2| 2017|

### 9. Performing Calculations

```sql
SELECT film_title,
       length_in_min,
       length_in_min / 60 AS length_in_hrs
FROM specs;
```
| film_title (text) | length_in_min (integer) | length_in_hrs (integer) |
|---|---|---|
| Avengers: End Game | 181 | 3 |
| The Lion King | 118 | 1 |
| Frozen II | 103 | 1 |
| Spider-Man: Far From Home | 129 | 2 |


### 10. Return Criteria

```sql
SELECT film_title, length_in_min
FROM specs
WHERE release_year = 2000
ORDER BY length_in_min
LIMIT 3;
```

| film_title (text) | length_in_min (integer) |
|---|---|
| Dinosaur | 80 |
| How the Grinch Stole Christmas | 104 |
| X-Men | 104 |

---

## Troubleshooting Error Messages

- View errors as clues to help debug queries.
- **Tip**: Copy error messages into search engines to find helpful resources.\
<img src="../images/sql_error.png" style="width:400px" />


## Documentation and Resources

- PostgreSQL Documentation: [PostgreSQL Docs](https://www.postgresql.org/docs/current/index.html)
- Stack Overflow: [Stack Overflow](https://stackoverflow.com/)
- SQL Basics Cheat Sheet: [LearnSQL Cheat Sheet](https://learnsql.com/blog/sql-basics-cheat-sheet/sql-basics-cheat-sheet-letter.pdf)
- Geeks for Geeks: [Geeks for Geeks](https://www.geeksforgeeks.org/)

## Staying Organized

- Save scripts in a `scripts` folder within the `SQL` folder.
- Name scripts according to related lectures (e.g., `S1_script.sql`).
- Scripts related to projects should have their own folder titled `projects`\

<img src="../images/organized.png" style="width:400px" />
---

## Practice Exercises - Economic & Community Development Grants Database

- **Instructions**: Review the [ecd database data dictionary and ERD](../data/ecd_data_dictionary+erd.pdf). You will only work with ecd table for these exercises

  1. How many counties are represented? How many companies?
  2. How many companies did not get ANY Economic Development grants (ed) for any of their projects? 
  (Hint, you will probably need a couple of steps to figure this one out)
  2. What is the total `capital_investment`, in millions, when there was a grant received from the `fjtap`? Call the column `fjtap_cap_invest_mil`.
  3. What is the average number of new jobs for each `county_tier`?
  3. How many companies are LLCs? Call this value `llc_companies`. 
  (Hint, combine `COUNT()` and `DISTINCT()`. Also, consider that LLC may not always be capitalized the same in company names. Find a SQL keyword that can help you with this.)

