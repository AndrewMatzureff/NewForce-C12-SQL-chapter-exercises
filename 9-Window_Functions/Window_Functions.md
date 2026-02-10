
# Window Functions  


## **Window Function Basics**

- **Definition**: Window functions operate over a "window" (or group) of rows in a table. Unlike `GROUP BY`, window functions do not collapse rows and allow for advanced aggregations while maintaining the full dataset.
- **Applications**:
  - Compare individual values to aggregations across the entire dataset or groups within it without `GROUP BY`.
  - Perform complex aggregations without collapsing rows without `GROUP BY`.
  - Assign ranks or row numbers.
  - Calculate rolling or running totals and averages.
- **Usage**: Window functions can only be used in the `SELECT` or `ORDER BY` clauses.

---

### **Window Function Syntax (FOPO)**  

1. **`Function()`**: The function to be applied often an aggregate function (e.g., `SUM`, `AVG`, `RANK`).  
2. **`OVER()`**: Creates the window; prevents row collapsing.  
    - When no arguments are included, that means there is a single window that includes the whole data set
3. **`PARTITION BY`**: Optional; divides the data into groups (like `GROUP BY`) - utilized within the `OVER()` component.
    - Creates smaller windows, you can partition by more than one column 
4. **`ORDER BY`**: Optional; orders rows within each partitio

---

### **Aggregation + GROUP BY Refresher**  

Using `GROUP BY` with functions like `SUM` or `AVG` collapses rows into one per category:  

```sql
SELECT mpaa_rating, AVG(length_in_min)
FROM specs
GROUP BY mpaa_rating;
```
 
| **mpaa_rating** | **avg**              |
|------------------|----------------------|
| PG              | 110.360902255 |
| null            | 123.00000000000     |
| PG-13           | 130.247191011|
| G               | 95.9565217391|
| R               | 122.810526315|

---

### **Window Functions - Comparing Aggregates to Originals**  

- Subqueries and CTEs join aggregations back to the original table - but window functions allows us to do it with the uncollapsed data 

**Examples:** 

1. Compare individual movie lengths to the overall average length:  

```sql
SELECT film_title,
       length_in_min,
       AVG(length_in_min) OVER() AS avg
FROM specs
ORDER BY film_title;
```

> FOPO: only needed `Function` and `Over`.\
> The function we are using is AVG() since we want to know the average movie length.\
> We must have the OVER() component to create the window and prevent the collapsing of rows.\
> Since we want to know the average movie length for all the movies in the table, we don’t add any arguments to OVER().


| **film_title**     | **length_in_min** | **avg**               |
|---------------------|-------------------|-----------------------|
| 10                 | 122               | 120.60232558139535   |
| 101 Dalmatians     | 103               | 120.60232558139535   |
| 1941               | 118               | 120.60232558139535   |
| 2012               | 158               | 120.60232558139535   |
| 300                | 117               | 120.60232558139535   |


Add a column that give us the average movie length by mpaa_rating



Compare movie lengths to both the overall and MPAA rating-specific averages:  

```sql
SELECT film_title,
       length_in_min,
       mpaa_rating,
       AVG(length_in_min) OVER() AS overall_avg_len,
       AVG(length_in_min) OVER(PARTITION BY mpaa_rating) AS rating_avg_len
FROM specs
ORDER BY film_title;
```

> FOPO: `Partition By`\
> Grouping by the average mpaa_rating

| **film_title**     | **length_in_min** | **mpaa_rating** | **overall_avg_len**   | **rating_avg_len**      |
|---------------------|-------------------|-----------------|-----------------------|-------------------------|
| 10                 | 122               | R               | 120.60232558139535   | 122.81052631578947     |
| 101 Dalmatians     | 103               | G               | 120.60232558139535   | 95.95652173913044      |
| 1941               | 118               | PG              | 120.60232558139535   | 110.3609022556391      |
| 2012               | 158               | PG-13           | 120.60232558139535   | 130.24719101123594     |
| 300                | 117               | R               | 120.60232558139535   | 122.81052631578947     |



---

2. Assign rankings for movies, shortest to longest, within each MPAA rating:  

**Without window function:**

```sql
SELECT *
FROM specs
ORDER BY mpaa_rating, length_in_min;
```

 **movie_id** | **film_title**        | **release_year** | **length_in_min** | **mpaa_rating** | **domestic_distributor_id** |
|--------------|-----------------------|------------------|-------------------|-----------------|----------------------------|
| 5585         | An American Tail     | 1986             | 80                | G               | 86127                     |
| 5788         | Toy Story            | 1995             | 81                | G               | 86124                     |
| 5791         | Pocahontas           | 1995             | 81                | G               | 86214                     |
> But we can't assign rankings - just arrange the outputs


**With window function:**

```sql
SELECT film_title,
       mpaa_rating,
       length_in_min,
       RANK() OVER(PARTITION BY mpaa_rating ORDER BY length_in_min) AS length_rank
FROM specs;
```
> FOPO: `Over` and `Partition By`\
> Notice how the RANK() function handles ties. Check out what happens if you use the DENSE_RANK() function instead

| **film_title**        | **mpaa_rating** | **length_in_min** | **length_rank** |
|------------------------|-----------------|-------------------|-----------------|
| An American Tail      | G               | 80                | 1               |
| Toy Story             | G               | 81                | 2               |
| Pocahontas            | G               | 81                | 2               |
| The Little Mermaid    | G               | 83                | 4               |
| Beauty and the Beast  | G               | 84                | 5               |



---


### **Rolling Aggregations with Window Functions**

While straightforward aggregations (like `AVG` or `SUM`) are often sufficient, there are cases where you need more advanced calculations, such as:

- A **running total**, like cumulative daily sales for a month.  
- A **rolling average**, such as a 12-month average unemployment rate.

---

**Example:**

To demonstrate a rolling average, we’ll switch from the movies database to the **population table** of the ECD database.  
The goal is to calculate a **3-year rolling average** for each county’s population.

**How It Works**:
1. For 2013, take each county’s values from **2011, 2012, and 2013** and calculate the average.  
2. For 2014, average the values from **2012, 2013, and 2014**, and so on.  


The `OVER()` function allows us to define a **moving window** for our calculations, enabling us to perform rolling or cumulative aggregations.

```sql
SELECT county,
       year,
       population,
       AVG(population) OVER(
           PARTITION BY county 
           ORDER BY year 
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS three_yr_avg
FROM population;
```
> FOPO: `OVER`, `PARTITION BY`, and `ORDER BY`\
>**PARTITION BY county**: Groups the data by county.\
>**ORDER BY year**: Orders the rows within each county by year.\
>**ROWS BETWEEN 2 PRECEDING AND CURRENT ROW**: Defines a moving window that includes the current year and the two preceding years for the calculation.


| **county**  | **year** | **population** | **three_yr_avg** |
|-------------|----------|----------------|------------------|
| Anderson    | 2010     | 75,112         | 75,112.00        |
| Anderson    | 2011     | 75,173         | 75,142.50        |
| Anderson    | 2012     | 75,196         | 75,160.33        |
| Anderson    | 2013     | 75,258         | 75,209.00        |
| Anderson    | 2014     | 75,131         | 75,195.00        |

---

When defining a moving window, use the following general format:

```sql
ROWS BETWEEN <start_frame> AND <end_frame>
```

Examples:
- **ROWS BETWEEN 2 PRECEDING AND CURRENT ROW**: Includes the current row and the two preceding rows.  
- **ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW**: Includes all rows from the start of the partition to the current row.

For additional insights and advanced usage, refer to:
- [PostgreSQL Window Functions Documentation](https://www.postgresql.org/docs/current/functions-window.html)



---

## **Practice Exercises**


1. Use a window function to add columns showing:  
   - The maximum population (`max_pop`) for each county.  
   - The minimum population (`min_pop`) for each county.  

---
 
2. Rank counties from largest to smallest population for each year.  

---


3. Use the unemployment table: 
- Calculate the rolling 12-month average unemployment rate using the `unemployment` table.
- Include the current month and the preceding 11 months.  
- **Hint**: Reference two columns in the `ORDER BY` argument (`county` and `period`).  

---

### **Additional Resources for Window Functions**

- [Towards Data Science: SQL Window Functions - The Intuitive Guide](https://towardsdatascience.com/sql-window-functions-the-intuitive-guide-5b56d7f437cb)  
- [GeeksforGeeks: Window Functions in SQL](https://www.geeksforgeeks.org/window-functions-in-sql/?ref=gcse)  
- [PostgreSQL Tutorial on Window Functions](https://www.postgresql.org/docs/current/tutorial-window.html)  
- [PostgreSQL Documentation: Window Functions](https://www.postgresql.org/docs/current/functions-window.html)  
  *(Includes a list of functions usable with window functions in PostgreSQL)*  
- [PostgreSQL Tutorial: Window Functions](https://www.postgresqltutorial.com/postgresql-window-function/)  
- [Data School: How Window Functions Work](https://dataschool.com/how-to-teach-people-sql/how-window-functions-work/)  
  *(Includes examples of rolling averages)*  
- [StrataScratch: The Ultimate Guide to SQL Window Functions](https://www.stratascratch.com/blog/the-ultimate-guide-to-sql-window-functions/)  
- [Start Data Engineering: 6 Concepts to Clearly Understand Window Functions](https://www.startdataengineering.com/post/6-concepts-to-clearly-understand-window-functions/)  
- [DataCamp: PostgreSQL Summary Stats and Window Functions](https://app.datacamp.com/learn/courses/postgresql-summary-stats-and-window-functions)  
- [EDUCBA: PostgreSQL Window Functions](https://www.educba.com/postgresql-window-functions/)  
