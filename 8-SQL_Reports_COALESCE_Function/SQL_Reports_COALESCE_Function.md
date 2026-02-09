
# COALESCE Keyword & Reports with SQL Data  

Before exporting data from an RDBMS(relational database management system):  
- Identify and select only the necessary columns to avoid missing critical data or exporting unnecessary information.  
- Apply **joins** and **filters** in the query itself to ensure the data is clean and focused before it reaches the visualization tool.  
- Use **aliases** for column names to make the exported file easy to understand.  
- Ensure that column **data types** align with their intended use in the visualization tool.

### **Exporting Data from pgAdmin**  
1. Finalize your query and review the output.  
2. Use the “Save results to file” button to export the query output as a CSV file.  
3. Save the file with a meaningful name and ensure it’s stored in the correct location within your file structure.
<img src="../images/exporting_pgAdmin.jpg" style="width: 400px">


### **Creating Visualizations**  
Once the data is exported, import it into your desired tool (Excel, Tableau, Power BI, etc.) to create reports, dashboards, or visualizations.

<img src="../images/create_visuals.jpg" style="width: 400px">

---

## **COALESCE() Function**  

The **COALESCE()** function is a powerful tool for handling **NULL** values in SQL.  
- **Functionality**:  
  - Accepts an unlimited number of arguments, separated by commas
  - Evaluates arguments from left to right and returns the **first non-NULL value** encountered.  
  - If all arguments are **NULL**, the function returns `NULL`.  
- **Use Case**: Replace `NULL` values with specified text or numeric values.  

---

### **COALESCE() Example**  
**Scenario**: Replace `NULL` distributor names with the value "missing".  

```sql
SELECT film_title,
       COALESCE(company_name, 'missing') AS distributor_name
FROM specs
INNER JOIN distributors
ON domestic_distributor_id = distributor_id;
```
> The first argument is `company_name`, meaning, that if the `company_name` is not null, the `company_name` is what is returned. But if the `company_name` is `null`, then it goes to the next argument, which we have specified to be `missing`, so `missing` will return instead of `null`


| **film_title**       | **distributor_name** |
|-----------------------|----------------------|
| The Deep             | Columbia Pictures   |
| The Spy Who Loved Me | missing             |
| Oh, God!             | Warner Bros.        |
| Annie Hall           | missing             |
| Semi-Tough           | missing             |
 
- If `company_name` is not NULL, the value from `company_name` is returned.  
- If `company_name` is NULL, the function returns "missing".

---

## **Additional Resources for COALESCE()**  
- [PopSQL: How to Use COALESCE in PostgreSQL](https://popsql.com/learn-sql/postgresql/how-to-use-coalesce-in-postgresql)  
- [PostgreSQL Documentation on Conditional Expressions](https://www.postgresql.org/docs/current/functions-conditional.html)  
- [GeeksforGeeks: PostgreSQL COALESCE](https://www.geeksforgeeks.org/postgresql-coalesce/)  
- [YouTube: COALESCE Tutorial](https://www.youtube.com/watch?v=3BnJUs5eAqc)

---

## **Practice Exercises**

1. Generate to query this output:
<img src="../images/excel_chart.png" style="width: 400px">

  - Display **Country name**, **4-digit year**, **count of Nobel prize winners** (where the count is ≥ 1), and **country size**:  
      - **Large**: Population > 100 million  
      - **Medium**: Population between 50 and 100 million (inclusive)  
      - **Small**: Population < 50 million  
  - Sort results so that the country and year with the largest number of Nobel prize winners appear at the top.  
  - Export the results as a CSV file.  
  - Use Excel to create a chart effectively communicating the findings.

2. Create the output below that shows a row for each country and each year. Use `COALESCE()` to display `unknown` when the gdp is `NULL`.
<img src="../images/output_below.png" style="width: 400px">

