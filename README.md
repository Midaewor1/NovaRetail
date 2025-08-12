# Nova Retail SQL Analysis

## Overview
This project analyzes retail sales data from the `nova_retail` dataset using SQL. It covers key business metrics such as average order value, lifetime customer value, product performance, regional trends, and customer segmentation.

The SQL scripts here were used to generate insights that were later visualized in Tableau dashboards.

---

## Queries

### 1. Average Order Value by Country
```sql
SELECT country, 
       ROUND(SUM(sales)::numeric / COUNT(DISTINCT ordernumber), 2) AS avg_order_value
FROM nova_retail
GROUP BY country
ORDER BY avg_order_value DESC;
```
Calculates **average order value (AOV)** for each country.

### 2. Top 10 Customers by Lifetime Value
```sql
SELECT customername, SUM(sales) AS lifetime_value
FROM nova_retail
GROUP BY customername
ORDER BY lifetime_value DESC
LIMIT 10;
```
Finds top 10 customers by total spending.

### 3. Sales Trends by Year and Quarter
```sql
SELECT salesquarter AS quarter,
       year_id AS year,
       SUM(sales) AS total_sales
FROM nova_retail
GROUP BY year, quarter
ORDER BY year, quarter;
```
Shows sales by year/quarter.

### 4. Underperforming Product Lines by Country
```sql
WITH ranked_sales AS (
  SELECT country, 
         productline, 
         SUM(sales) AS total_sales,
         RANK() OVER (PARTITION BY country ORDER BY SUM(sales)) AS sales_rank
  FROM nova_retail
  GROUP BY country, productline
)
SELECT *
FROM ranked_sales
WHERE total_sales < 50000
ORDER BY country, sales_rank;
```
Highlights product lines with sales under $50k per country.

### 5. Deal Size Trends by Product Line
```sql
SELECT productline, dealsize, COUNT(*) AS order_count, SUM(sales) AS total_revenue
FROM nova_retail
GROUP BY productline, dealsize
ORDER BY productline;
```
Shows order volume and revenue by deal size.

### 6. Revenue per Unit by Product Line
```sql
SELECT productline, 
       ROUND(SUM(sales) / SUM(quantityordered), 2) AS revenue_per_unit
FROM nova_retail
GROUP BY productline
ORDER BY revenue_per_unit DESC;
```
Calculates average revenue per unit.

### 7. Repeat Customers
```sql
SELECT customername, 
       COUNT(DISTINCT ordernumber) AS num_orders
FROM nova_retail
GROUP BY customername
HAVING COUNT(DISTINCT ordernumber) > 1
ORDER BY num_orders DESC;
```
Finds customers with multiple orders.

### 8. Cross-Sell Opportunities
```sql
SELECT customername, 
       COUNT(DISTINCT productline) AS num_lines
FROM nova_retail
GROUP BY customername
HAVING COUNT(DISTINCT productline) > 2
ORDER BY num_lines DESC;
```
Identifies customers buying from multiple product lines.

### 9. Average Sales by Deal Size and Country
```sql
SELECT country, dealsize, 
       ROUND(AVG(sales), 2) AS avg_sales
FROM nova_retail
GROUP BY country, dealsize
ORDER BY country, dealsize;
```
Shows average sales per deal size per country.

### 10. Customer Segmentation (Revenue Tiers)
```sql
SELECT customername,
       SUM(sales) AS total_sales,
       CASE
         WHEN SUM(sales) >= 100000 THEN 'Platinum'
         WHEN SUM(sales) >= 50000 THEN 'Gold'
         WHEN SUM(sales) >= 20000 THEN 'Silver'
         ELSE 'Bronze'
       END AS customer_tier
FROM nova_retail
GROUP BY customername
ORDER BY total_sales DESC;
```
Segments customers into Platinum, Gold, Silver, Bronze.

---

## How to Use
1. Load your `nova_retail` dataset into PostgreSQL (or similar).
2. Copy any query into your SQL editor and run.
3. Export results to CSV for Tableau or another BI tool.

---

## Recommended File Structure
```
nova-retail-analysis/
│
├── README.md
├── sql/
│   ├── 1_avg_order_value.sql
│   ├── 2_top_customers.sql
│   └── ...
├── data/
│   └── nova_retail_clean.csv
├── tableau/
│   └── dashboard_screenshots.png
```
