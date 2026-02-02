

# Joining Data in SQL  

### Joins - Big Picture

- **Purpose**: In SQL, data is often spread across *multiple tables*, requiring joins to perform meaningful analysis by combining values across tables. There are a variety of methods to combine data, each of which is slightly different, giving us the flexibility to find the right option for the given scenario. 
- **JOINS**: common approach to bring data together. Variety of different types but they all use of *at least one key* 
- **Keys**: Columns that serve as connectors between tables, containing matching values to allow record matching.
- **Tip**: Map out what you want the output to look like before selecting a join type. Choose a join type based on whether you expect more, fewer, or the same number of rows as in the original tables.

---

### Refresher: ERDs and Keys

- Review ERDs to identify connecting columns:
  - What columns connect `specs` and `distributors` tables?
  - What columns connect `specs` and `ratings` tables?
  - What columns connect `specs` and `revenue` tables?

<img src="../images/erd.png" style="width:400px" >

---

### Join Keywords and Terminology

- **Primary Keywords**:
  - `INNER JOIN`, `FULL JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `CROSS JOIN`, **Self** joins.
  - `ON` and `USING`.
- **Terminology**:
  - The table named first in a join statement is the **left table**; the table named second is the **right table**.
  - **Semi-joins** and **anti-joins** will be covered in the subquery lecture.

---

### Join Syntax

- **Examples**:

  ```sql
  SELECT *
  FROM specs 
      <type> JOIN distributors
      ON specs.domestic_distributor_id = distributors.distributor_id;
  ```

  ```sql
  SELECT *
  FROM specs 
      <type> JOIN revenue
      USING(movie_id);
  ```

- **Key Points**:
  - Use `ON` when key columns have different names; use `USING` if they share the **exact** same name.
  - As a convention, list columns from the left table on the left side of the `=` sign.

---


### INNER JOIN

- **Function**: Returns *ONLY* rows with matching key values in both tables.
- **Use Case**: For cases where records need to exist in both tables.
<img src="../images/inner_join.png" style="width:400px" >

**Example**:
- We only want movies that have distributor details so we can analyze the movie releases associated with different headquarter locations. 

  ```sql
  SELECT movie_id, film_title, release_year, distributor_id, company_name, headquarters
  FROM specs 
      INNER JOIN distributors
      ON domestic_distributor_id = distributor_id;
  ```


| movie_id | film_title        | release_year | distributor_id | company_name | headquarters |
|----------|----------------|------------------|---------------------|------------------|------------------|
| 5547         | Avengers: Endgame     | 2019            | 86124              | Walt Disney      | Burbank, CA      |
| 5548         | The Lion King         | 2019            | 86124              | Walt Disney      | Burbank, CA      |
| 5549         | Frozen II             | 2019            | 86124              | Walt Disney      | Burbank, CA      |


### FULL JOIN (aka FULL OUTER JOIN)

- **Function**: Returns *all* rows from both tables, filling in null values for rows without matches.
- **Use Case**: To include all records from both tables, regardless of whether there is a match

<img src="../images/full_join.png" style="width:400px" >


- **Example**:
- We want to find which distributors have movies associated with them, which do not, and which movies have no distrubitors

  ```sql
  SELECT movie_id, film_title, release_year, distributor_id, company_name
  FROM specs 
      FULL JOIN distributors
      ON domestic_distributor_id = distributor_id;
  ```

| **movie_id** | **film_title**           | **release_year** | **distributor_id** | **company_name**       |
|--------------|--------------------------|------------------|---------------------|------------------------|
| 5972         | The Deep                 | 1977            | 86142              | Columbia Pictures       |
| 5973         | The Spy Who Loved Me     | 1977            | [null]             | [null]                 | 
| [null]       | [null]                   | [null]          | 86150              | [null]                 |


#### Inner vs Outer Join

**Inner Join:**
- Keeps only the rows that match on the designated key(s) from both tables
- Since there is a match for every row in the resulting output, no null values will be inserted
- Useful when you want to look specifically at rows that have values from both tables

**Outer Join:**
- Keeps all the rows from both tables, even those that don’t match on the key(s)
- Since some rows may not match up in the resulting output, null values will be inserted accordingly
- Useful when you want to match up the data you can, but you want to also look at rows that don’t have values from both tables

--- 

### LEFT JOIN

- **Function**: Returns all rows from the left table and matching rows from the right table.
- **Use Case**: To keep all rows from one table while adding matching rows from another.

<img src="../images/left_join.png" style="width:400px" >


- **Example**:
- We want to see all the movies that have distrubitor details and not any that do not. 

  ```sql
  SELECT movie_id, film_title, release_year, distributor_id, company_name
  FROM specs 
      LEFT JOIN distributors
      ON domestic_distributor_id = distributor_id;
  ```


| **movie_id** | **film_title**        | **release_year** | **distributor_id** | **company_name**       |
|--------------|-----------------------|------------------|---------------------|------------------------|
| 5972         | The Deep             | 1977            | 86142              | Columbia Pictures      |
| 5973         | The Spy Who Loved Me | 1977            | [null]             | [null]                 |
| 5874         | Oh, God!             | 1977            | 86126              | Warner Bros.           |

### RIGHT JOIN

- **Function**: Returns *all* rows from the right table and matching rows from the left table.
- **Use Case**: Used like a left join but with the tables reversed.

<img src="../images/right_join.png" style="width:400px" >


- **Example**:
- Same query as above but swapped which table is designated as the left table

  ```sql
  SELECT movie_id, film_title, release_year, distributor_id, company_name
  FROM distributors 
      RIGHT JOIN specs
      ON distributor_id = domestic_distributor_id;
  ```

| **movie_id** | **film_title**        | **release_year** | **distributor_id** | **company_name**       |
|--------------|-----------------------|------------------|---------------------|------------------------|
| 5972         | The Deep             | 1977            | 86142              | Columbia Pictures      |
| 5973         | The Spy Who Loved Me | 1977            | [null]             | [null]                 |
| 5874         | Oh, God!             | 1977            | 86126              | Warner Bros.           |


#### Right vs Left Join

**Right Join:**
- Keeps all the rows from the right table
- For any rows that don’t have matches in the left table, inserts null values in relevant columns
- Much less commonly used.

**Left Join:**
- Keeps all the rows from the left table
- For any rows that don’t have matches in the right table, inserts null values in relevant columns
- Much more commonly used. Since we are in control of which table is designated left vs. right, we tend to make the table with the rows we want to keep the left table.

---

### Self Join

- **Function**: Joins a table with itself to allow comparison within the same table.
- **Use Case**: Useful for comparing different time frames within the same table.
- **Example**:

  ```sql
  SELECT specs_left.domestic_distributor_id, specs_left.film_title, specs_left.release_year, specs_right.film_title, specs_right.release_year
  FROM specs AS specs_left
      INNER JOIN specs AS specs_right
      USING(domestic_distributor_id)
  WHERE specs_left.release_year + 1 = specs_right.release_year
      AND specs_left.mpaa_rating = 'G'
      AND specs_right.mpaa_rating = 'G';
  ```
Here’s the new table with the provided information structured properly:

| **distributor_id** | **film_title_1** | **release_year_1** | **film_title_2** | **release_year_2** |
|---------------------|------------------|--------------------|------------------|--------------------|
| 86124              | Toy Story 3      | 2010               | Cars 2           | 2011               |
| 86124              | Ratatouille      | 2007               | WALLE-E          | 2008               |
| 86124              | Cars             | 2006               | Ratatouille      | 2007               |
| 86124              | A Bug’s Life     | 1998               | Tarzan           | 1999               |
| 86124              | A Bug’s Life     | 1998               | Toy Story 2      | 1999               |
| 86124              | Mulan            | 1998               | Tarzan           | 1999               |
---

### CROSS JOIN

- **Function**: Produces every possible combination of rows from two tables.
- **Note**: Does not use `ON`/`USING` statements.

<img src="../images/cross_join.png" style="width:400px" >


---

## Additional Resources

- **Recommended Readings**:
  - [Kaggle Joins Animation](https://www.kaggle.com/discussions/general/353654)
  - [The Data School Joins Walkthrough](https://www.thedataschool.co.uk/le-luu/sql-joins/)
  - [SQLServer Tutorial Walkthrough](https://www.sqlshack.com/a-step-by-step-walkthrough-of-sql-inner-join/)

- **DataCamp Courses**:
  - [Joining Data in SQL](https://app.datacamp.com/learn/courses/joining-data-in-sql) - Focus on chapters 1 & 2.
  - [SQL for Joining Data](https://app.datacamp.com/learn/courses/sql-for-joining-data) - Optional for extra practice.

---

## Practice Exercises - Olympics Database

**Exploratory Data Analysis (EDA)**:
Get familiar with the [tables and structure](../data/olympics_data_dictonary+erd.pdf):
  - How many rows are in the `athletes` table? How many distinct athlete ids?
  - Which years are represented in the `summer_games`, `winter_games`, and `country_stats` tables?
  - How many distinct countries are represented in the `countries` and `country_stats` table? 
  - How many distinct events are in the `winter_games` and `summer_games` table?
  - Count the number of athletes who participated in the summer games for each country. Your output should have country name and number of athletes in their own columns. Did any country have no athletes?
  - Write a query to list countries by total bronze medals, with the highest totals at the top and nulls at the bottom.
    - Adjust the query to only return the country with the most bronze medals
  - Calculate the average population in the `country_stats` table for countries in the `winter_games`. This will require 2 joins. 
    - First query gives you country names and the average population
    - Second query returns only countries that participated in the `winter_games`
  - Identify countries where the population decreased from 2000 to 2006.

