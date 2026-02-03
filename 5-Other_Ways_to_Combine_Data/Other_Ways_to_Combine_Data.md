

# Other Ways to Combine Data in SQL  

### Set Theory Clauses

Set theory can be applied to SQL queries using four key clauses:

- **UNION**
- **UNION ALL**
- **INTERSECT**
- **EXCEPT**

These clauses are distinct from joins as they do not rely on keys to combine data. Instead, they work directly with rows and columns across tables. To use these clauses effectively:

- The tables involved **must have the same number of columns**, with corresponding columns sharing the same data types.
- Instead of merging rows by matching keys, these clauses manipulate tables as follows:
  - `UNION` and `UNION ALL`: Stack one table on top of another.
    - `UNION` removes duplicate rows.
    - `UNION ALL` retains all rows, including duplicates.
  - `INTERSECT`: Returns only the rows that exist in both tables.
  - `EXCEPT`: Returns rows that exist in one table but not in the other.

These operations produce results resembling the original tables, but filtered or combined according to the chosen clause, enabling advanced data analysis and manipulation in SQL.

<img src="../images/unions.png" style="width:400px">

---

### UNION

`UNION` combines rows from two tables and automatically removes duplicate rows. This ensures that if the same row appears in both tables, it is represented only once in the result.

**When to Use**
- Use `UNION` when combining tables with similar types of data, where duplicates should be eliminated.
- This is particularly useful when the tables contain related data but do not have overlapping information about the same items.

**Key Considerations**
- All columns in the tables being combined must match in **data type**, **content**, and **order**.
- `UNION` stacks one table on top of another without pairing or merging rows.

 **Example**: Retrieve a list of all events from both the `summer_games` and `winter_games` tables.

  ```sql
  (SELECT event
   FROM summer_games)
  UNION
  (SELECT event
   FROM winter_games);
  ```

| **Event**                                | **Type**                 |
|------------------------------------------|--------------------------|
| Men’s 5,000 meters                       | character varying (255)  |
| Women’s Triple Jump                      | character varying (255)  |
| Men’s Marathon                           | character varying (255)  |
| Gymnastics Men’s Horizontal Bar          | character varying (255)  |
| Women’s 400 metres                       | character varying (255)  |
| Cross Country Skiing Men’s 50 kilometers | character varying (255)  |


**Adding Context**: To differentiate events by season, add a column for season.

  ```sql
  (SELECT event, 'Summer' AS season
   FROM summer_games)
  UNION
  (SELECT event, 'Winter' AS season
   FROM winter_games);
  ```

| **Event**                                      | **Season**   |
|------------------------------------------------|--------------|
| Men’s Pole Vault                               | Summer       |
| Men’s 4 X 100 metres Relay                     | Summer       |
| Women’s 4 X 100 metres Relay                   | Summer       |
| Gymnastics Men’s Rings                         | Summer       |
| Cross Country Skiing Men’s 50 kilometres Freestyle | Winter       |
| Swimming Women’s 200 metres Freestyle          | Summer       |


> Each game is listed *exactly once* even if it shows up multiple times in the original tables

---

### UNION ALL

`UNION ALL` works similarly to `UNION`, but it **includes all duplicate rows** in the result. Unlike `UNION`, it does not remove duplicates.

#### **Key Points**
- Duplicate rows can occur if:
  - They exist within a single table.
  - They are the result of combining rows from two tables.
- To limit duplicates to only those caused by combining tables, you can use `DISTINCT` within each `SELECT` statement before applying `UNION ALL`.

#### **When to Use**
- Use `UNION ALL` when all occurrences of duplicate rows are needed, or when performance is a priority, as it skips the duplicate elimination process of `UNION`.


**Example**: Show all events from both `summer_games` and `winter_games`, allowing duplicates.

  ```sql
  (SELECT event, 'Summer' AS season
   FROM summer_games)
  UNION ALL
  (SELECT event, 'Winter' AS season
   FROM winter_games);
  ```


| **Event**                                 | **Season**   |
|-------------------------------------------|--------------|
| Gymnastics Men’s Individual All-Around    | Summer       |
| Gymnastics Men’s Floor Exercise           | Summer       |
| Gymnastics Men’s Parallel Bars            | Summer       |
| Gymnastics Men’s Horizontal Bar           | Summer       |
| Gymnastics Men’s Rings                    | Summer       |
| Gymnastics Men’s Pommelled Horse          | Summer       |
| Men’s 5,000 metres                        | Summer       |
| Men’s 400 metres                          | Summer       |
| Men’s 5,000 metres                        | Summer       |

> Duplication occurs, although the duplicates in this table snippet are from the same table and not caused by combining the table.
---

### INTERSECT


The `INTERSECT` clause returns rows that are present in **both tables**. This is useful for finding common records across datasets.



**Examples:**

To find athletes who participated in both the Summer and Winter Olympics:

```sql
(SELECT athlete_id
 FROM summer_games)
INTERSECT
(SELECT athlete_id
 FROM winter_games);
```

| **Athlete ID** |
|-----------------|
| 127594          |

This query shows that only one athlete in the dataset participated in both sets of games. However, the result only provides the `athlete_id` without additional details.

To retrieve the name of the athlete, use a `JOIN` with the `athletes` table:

```sql
(SELECT athlete_id, 
        name
 FROM summer_games
 LEFT JOIN athletes
 ON summer_games.athlete_id = athletes.id)
INTERSECT
(SELECT athlete_id, 
        name
 FROM winter_games
 LEFT JOIN athletes
 ON winter_games.athlete_id = athletes.id);
```

| **Athlete ID** | **Name**               |
|-----------------|------------------------|
| 127594          | Eva Vrabcov-Nvltov    |



- `INTERSECT` is helpful for identifying overlapping records between two datasets.
- You can enhance the result by incorporating `JOIN` clauses to include additional information, such as names or other descriptive details.
- Ensure the columns in the `SELECT` statements match in content and order for accurate results.


### EXCEPT


The `EXCEPT` clause is the opposite of `INTERSECT`. It returns all rows from the first table that are **not present** in the second table.

**Key Points**
- Unlike `INTERSECT`, the **order of the tables matters** when using `EXCEPT`. Rows are included only from the first table that do not appear in the second table.

---

**Example:**

To find countries represented in the Summer Olympics but not in the Winter Olympics:

```sql
(SELECT country_id
 FROM summer_games)
EXCEPT
(SELECT country_id
 FROM winter_games);
```

| **Country ID** |
|-----------------|
| 38              |
| 150             |
| 139             |
| 140             |



Use a `JOIN` to include country names for the countries represented in the Summer Olympics but not in the Winter Olympics:

```sql
(SELECT country
 FROM summer_games
 LEFT JOIN countries
 ON summer_games.country_id = countries.id)
EXCEPT
(SELECT country
 FROM winter_games
 LEFT JOIN countries
 ON winter_games.country_id = countries.id);
```

| **Country**               |
|----------------------------|
| MDV - Maldives            |
| Lao - Laos                |
| T.To - Trinidad and Tobago|
| SEN - Senegal             |



To return only countries in **Oceania**, add a `WHERE` clause to the first query:

```sql
(SELECT country
 FROM summer_games
 LEFT JOIN countries
 ON summer_games.country_id = countries.id
 WHERE region = 'OCEANIA')
EXCEPT
(SELECT country
 FROM winter_games
 LEFT JOIN countries
 ON winter_games.country_id = countries.id);
```

| **Country**              |
|---------------------------|
| SAM - Samoa              |
| FIJ - Fiji               |
| PNG - Papua New Guinea   |
| GUM - Guam               |


To order the results alphabetically, include an `ORDER BY` clause:

```sql
(SELECT country
 FROM summer_games
 LEFT JOIN countries
 ON summer_games.country_id = countries.id
 WHERE region = 'OCEANIA')
EXCEPT
(SELECT country
 FROM winter_games
 LEFT JOIN countries
 ON winter_games.country_id = countries.id)
ORDER BY country;
```

| **Country**                           |
|---------------------------------------|
| COK - Cook Islands                    |
| PNG - Papua New Guinea                |
| A.Sa - American Samoa                 |
| F.SM. - Federated States of Micronesia|
| FIJ - Fiji                            |
| GUM - Guam                            |



> In the ordered result, anomalies like leading spaces in country names might cause unexpected sorting. While addressing these is outside the scope of this example, it’s important to be aware of potential formatting issues.



### **A Note on Clause Placement**

When using set theory clauses in SQL (`UNION`, `UNION ALL`, `INTERSECT`, `EXCEPT`), consider the following rules for additional clauses:

- **WHERE and HAVING**:  
  These are **table-specific** clauses.  
  - If filtering is required in both `SELECT` statements, you need to include `WHERE` in each statement.  
  - You can also filter only one table or apply different filters to each.

- **ORDER BY**:  
  Always add `ORDER BY` at the very end of your query to sort the final output.

- **Aggregations**:  
  Use `GROUP BY` and aggregate functions in each `SELECT` statement separately before applying the set theory clause.

---

### **Compare & Contrast: Joins vs. Set Theory Clauses**

| **Aspect**                | **Joins**                                  | **Set Theory Clauses**                          |
|---------------------------|--------------------------------------------|------------------------------------------------|
| **Row Matching**          | Uses keys to match rows                   | Does not use keys; aligns rows by column order |
| **Column Selection**      | Any columns in any order                  | Columns must align across tables              |
| **Combination Style**     | Horizontal (wider table)                  | Vertical (same columns in result table)        |

---

### **Additional Resources**
- [PostgreSQL Documentation on Queries and Set Theory](https://www.postgresql.org/docs/current/queries-union.html)  
- [SQL Shack: Learn SQL Set Theory](https://www.sqlshack.com/learn-sql-set-theory/)  
- [Arctype Blog: Postgres Set Operators](https://arctype.com/blog/postgres-set-operators/)  
- [DataCamp: Joining Data in SQL, Chapter 3](https://app.datacamp.com/learn/courses/joining-data-in-sql)  
- [DataCamp: SQL for Joining Data, Chapter 3](https://app.datacamp.com/learn/courses/sql-for-joining-data)  

---

### **Practice Exercises**

1. **Find Athletes from Summer or Winter Games**  
   Write a query to list all athlete names who participated in the Summer or Winter Olympics. Ensure no duplicates appear in the final table using a set theory clause.

2. **Find Countries Participating in Both Games**  
   - Write a query to retrieve `country_id` and `country_name` for countries in the Summer Olympics.  
   - Add a `JOIN` to include the country’s 2016 population and exclude the `country_id` from the `SELECT` statement.  
   - Repeat the process for the Winter Olympics.  
   - Use a set theory clause to combine the results.

3. **Identify Countries Exclusive to the Summer Olympics**  
   Return the `country_name` and `region` for countries present in the `countries` table but not in the `winter_games` table.  
   *(Hint: Use a set theory clause where the top query doesn’t involve a `JOIN`, but the bottom query does.)*
