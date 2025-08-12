--1 calculates the average order value of every country

SELECT country, 
       ROUND(SUM(sales)::numeric / COUNT(DISTINCT ordernumber), 2) AS avg_order_value
FROM nova_retail
GROUP BY country
ORDER BY avg_order_value DESC;

--2 -- Calculates the top 10 customers by lifetime spending

SELECT customername, SUM(sales) AS lifetime_value
FROM nova_retail
GROUP BY customername
ORDER BY lifetime_value DESC
LIMIT 10;


--3 shows sales trends by years and quarters, notice that q3 and q4 are best performing
SELECT salesquarter AS quarter,
       year_id AS year,
       SUM(sales) AS total_sales
FROM nova_retail
GROUP BY year, quarter
ORDER BY year, quarter;


--4 shows underperforming product lines in each country
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


--5 shows dealsize trends by productline
SELECT productline, dealsize, COUNT(*) AS order_count, SUM(sales) AS total_revenue
FROM nova_retail
GROUP BY productline, dealsize
ORDER BY productline;

--6 Calculates revenue per unit (per product line)
SELECT productline, 
       ROUND(SUM(sales) / SUM(quantityordered), 2) AS revenue_per_unit
FROM nova_retail
GROUP BY productline
ORDER BY revenue_per_unit DESC;

--7 Helps identify repeat customers to focus on customer loyalty
SELECT customername, 
       COUNT(DISTINCT ordernumber) AS num_orders
FROM nova_retail
GROUP BY customername
HAVING COUNT(DISTINCT ordernumber) > 1
ORDER BY num_orders DESC;

--8 -- Identifies what customers buy different product in their orders, good for lycross ssell opportunities
SELECT customername, 
       COUNT(DISTINCT productline) AS num_lines
FROM nova_retail
GROUP BY customername
HAVING COUNT(DISTINCT productline) > 2
ORDER BY num_lines DESC;

--9 -- Average sales by dealsize and country

SELECT country, dealsize, 
       ROUND(AVG(sales), 2) AS avg_sales
FROM nova_retail
GROUP BY country, dealsize
ORDER BY country, dealsize;

--10 Creates customer revenue segmentation tiers
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

--11 Top countries and cities by totalsales

SELECT country, SUM(sales) AS total_sales
FROM nova_retail
GROUP BY country
ORDER BY total_sales DESC;