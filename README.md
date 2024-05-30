# SQL Queries for Business Insights

This repository contains a collection of SQL queries designed to extract meaningful business insights from an `orders` database. The queries utilize Common Table Expressions (CTEs), subqueries, and rank-based methods to perform advanced data analysis. These methods help in breaking down complex queries, improving readability, and maintaining efficient query execution.

## Table of Contents

- [Product Categories with Highest Average Profit Margin](#product-categories-with-highest-average-profit-margin)
- [Customer Segment Analysis](#customer-segment-analysis)
- [Sub-category with Highest Average Sales](#sub-category-with-highest-average-sales)
- [Total Sales of Customers](#total-sales-of-customers)
- [State-wise Sales, Profit, and Discount Analysis](#state-wise-sales-profit-and-discount-analysis)
- [City Ranking by Orders](#city-ranking-by-orders)
- [Shipping Mode Analysis](#shipping-mode-analysis)
- [Discount Rate Differences per Category](#discount-rate-differences-per-category)
- [Average Quantity Sold per Category](#average-quantity-sold-per-category)
- [Customer Sales Difference](#customer-sales-difference)
- [Yearly Profit Analysis](#yearly-profit-analysis)
- [Second Class Shipping Percentage](#second-class-shipping-percentage)
- [Customer Ranking by Sales](#customer-ranking-by-sales)
- [Highest Average Discount Rate per Category](#highest-average-discount-rate-per-category)

## Product Categories with Highest Average Profit Margin

This query identifies product categories with the highest average profit margins and ranks them accordingly.

```sql
SELECT category, avg_profit_margin, rank() OVER (ORDER BY avg_profit_margin DESC) AS rank_category
FROM (
    SELECT category, AVG(profit / sales) AS avg_profit_margin
    FROM orders
    GROUP BY category
) AS results;
```
- **Focus**: The subquery calculates the average profit margin for each category, and the main query ranks these categories.
  
![image](https://github.com/Sudarshan028/SQL-Queries-for-Business-Insights/assets/160358210/b2f032d1-1ba8-4cbc-be71-dbea3939c991)


## Customer Segment Analysis

This query calculates total sales, profit, and average discount for each customer segment, identifying the segment with the highest average discount rate.

```sql
WITH re AS (
    SELECT segment, SUM(sales) AS total_sales, SUM(profit) AS total_profit, AVG(discount) AS avg_discount
    FROM orders
    GROUP BY segment
)
SELECT segment, total_sales, total_profit, avg_discount
FROM re
WHERE avg_discount = (SELECT MAX(avg_discount) FROM re);
```
- **Focus**: The CTE `re` aggregates sales, profit, and discount by segment, while the main query finds the segment with the highest average discount.

![image](https://github.com/Sudarshan028/SQL-Queries-for-Business-Insights/assets/160358210/b7011082-f63e-4c74-99fd-d5742dc0dda9)


## Sub-category with Highest Average Sales

This query determines which product sub-category has the highest average sales among orders with quantities greater than the average.

```sql
WITH mi AS (
    SELECT AVG(quantity) AS avg_quantity FROM orders
)
SELECT TOP 1 sub_category, AVG(sales) AS avg_sales
FROM orders
WHERE quantity > (SELECT avg_quantity FROM mi)
GROUP BY sub_category
ORDER BY avg_sales DESC;
```
- **Focus**: The CTE `mi` calculates the average quantity, and the main query filters orders based on this average to find the top sub-category by average sales.

![image](https://github.com/Sudarshan028/SQL-Queries-for-Business-Insights/assets/160358210/94d176c1-95e0-42da-b5d6-15c8f0d32245)


## Total Sales of Customers

This query calculates the total sales for each customer.

```sql
WITH lk AS (
    SELECT order_id, customer_id, SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id, order_id
)
SELECT customer_id, SUM(total_sales) AS total_sales1
FROM lk
GROUP BY customer_id
ORDER BY total_sales1 DESC;
```
- **Focus**: The CTE `lk` aggregates sales by customer and order, while the main query sums these sales to get the total sales per customer.

![image](https://github.com/Sudarshan028/SQL-Queries-for-Business-Insights/assets/160358210/30fa34f0-8f0b-4b1c-8d51-fff3f859cfbe)


## State-wise Sales, Profit, and Discount Analysis

This query finds the state with the highest total sales and provides the total sales, profit, and average discount rate for each state.

```sql
WITH et AS (
    SELECT order_id, state, SUM(sales) AS total_sales, SUM(profit) AS total_profit, AVG(discount) AS avg_discount
    FROM orders
    GROUP BY order_id, state
)
SELECT TOP 1 state, SUM(total_sales) AS total_sales1
FROM et
GROUP BY state
ORDER BY total_sales1 DESC;
```
- **Focus**: The CTE `et` aggregates sales, profit, and discount by state, and the main query identifies the state with the highest total sales.

![image](https://github.com/Sudarshan028/SQL-Queries-for-Business-Insights/assets/160358210/0216f719-08ed-45ff-afb0-34dc4300fea4)


## City Ranking by Orders

This query ranks each city based on the total number of orders placed and calculates the percentage contribution of each city to the total number of orders.

```sql
WITH st AS (
    SELECT city, COUNT(order_id) AS city_wise_orders
    FROM orders
    GROUP BY city
), mt AS (
    SELECT city, city_wise_orders, RANK() OVER (ORDER BY city_wise_orders DESC) AS rank_orders
    FROM st
), qt AS (
    SELECT SUM(city_wise_orders) AS total_orders
    FROM mt
), tm AS (
    SELECT mt.*, qt.*
    FROM mt
    INNER JOIN qt ON 1=1
)
SELECT city, city_wise_orders, rank_orders, (city_wise_orders / total_orders) * 100.0 AS percentage_of_total_orders
FROM tm
GROUP BY city, city_wise_orders, rank_orders, total_orders;
```
- **Focus**: The CTEs `st`, `mt`, `qt`, and `tm` sequentially count orders per city, rank them, calculate the total number of orders, and then compute the percentage contribution.

![image](https://github.com/Sudarshan028/SQL-Queries-for-Business-Insights/assets/160358210/d8f745c5-e273-4b1b-af91-e3bbd13bde00)

## Shipping Mode Analysis

This query finds the most commonly used shipping mode for orders with profits higher than the average profit per order.

```sql
WITH pt AS (
    SELECT AVG(profit) AS avg_profit FROM orders
), qw AS (
    SELECT ship_mode FROM orders WHERE profit > (SELECT avg_profit FROM pt)
)
SELECT ship_mode, COUNT(ship_mode) AS total_used
FROM qw
GROUP BY ship_mode
ORDER BY total_used DESC;
```
- **Focus**: The CTE `pt` calculates the average profit, and the main query counts the occurrences of each shipping mode for orders exceeding this average.

![image](https://github.com/Sudarshan028/SQL-Queries-for-Business-Insights/assets/160358210/2f7cd3ea-6da8-45c1-8398-c8d4970429f3)


## Discount Rate Differences per Category

This query calculates the difference between the highest and lowest discount rates applied to orders for each product category.

```sql
WITH dis AS (
    SELECT category, order_id, SUM(discount) AS total_discount
    FROM orders
    GROUP BY order_id, category
)
SELECT category, MAX(total_discount) - MIN(total_discount) AS difference_discount
FROM dis
GROUP BY category;
```
- **Focus**: The CTE `dis` aggregates discounts by order and category, and the main query computes the discount range per category.

![image](https://github.com/Sudarshan028/SQL-Queries-for-Business-Insights/assets/160358210/dac5d636-3026-44ee-865b-09dfe963e130)

## Average Quantity Sold per Category

This query calculates the average quantity sold for each product category and identifies the category with the highest total sales.

```sql
WITH er AS (
    SELECT category, order_id, SUM(quantity) AS total_quantity, SUM(sales) AS total_sales
    FROM orders
    GROUP BY category, order_id
)
SELECT category, AVG(total_quantity) AS avg_quantity, SUM(total_sales) AS total_final_sales
FROM er
GROUP BY category
ORDER BY total_final_sales DESC;
```
- **Focus**: The CTE `er` aggregates quantities and sales by category and order, and the main query calculates average quantities and total sales per category.

![image](https://github.com/Sudarshan028/SQL-Queries-for-Business-Insights/assets/160358210/f720c549-ebc1-4dcb-b93a-22f86a3f15e3)


## Customer Sales Difference

This query calculates the difference between the highest and lowest sales amounts across all orders for each customer.

```sql
WITH ts AS (
    SELECT customer_id, order_id, SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id, order_id
)
SELECT customer_id, MAX(total_sales) AS max_sales, MIN(total_sales) AS min_sales, MAX(total_sales) - MIN(total_sales) AS difference_of_sales
FROM ts
GROUP BY customer_id;
```
- **Focus**: The CTE `ts` aggregates sales by customer and order, and the main query calculates the sales range for each customer.

![image](https://github.com/Sudarshan028/SQL-Queries-for-Business-Insights/assets/160358210/426c41b8-e5b7-410c-9423-11eba75dd2e6)


## Yearly Profit Analysis

This query calculates the total profit for each year and the percentage contribution of each year to the total profit.

```sql
WITH st AS (
    SELECT SUM(profit) AS total_profit FROM orders
), yt AS (
    SELECT *, YEAR(ship_date) AS year_of_shipping FROM orders
), tm AS (
    SELECT year_of_shipping, SUM(profit) AS profit_yearwise
    FROM yt
    GROUP BY year_of_shipping
), ty AS (
    SELECT tm.*, st.total_profit
    FROM tm
    INNER JOIN st ON 1=1
)
SELECT *, (profit_yearwise / total_profit * 100.0) AS percentage_contribute
FROM ty;
```
- **Focus**: The CTEs `st`, `yt`, `tm`, and `ty` sequentially calculate the total profit, extract the year from shipping dates, aggregate profits by year, and compute the yearly percentage contribution to total profit.

![image](https://github.com/Sudarshan028/SQL-Queries-for-Business-Insights/assets/160358210/080e8490-e694-48db-b2ad-104f39a46dcb)


## Second Class Shipping Percentage

This query determines the percentage of orders with sales higher than the average that were shipped using the second class shipping mode.

```sql
WITH tt AS (
    SELECT AVG(sales) AS total_sales_orderwise FROM orders
), tu AS (
    SELECT ship_mode, COUNT(order_id) AS total_orders_shipwise
    FROM orders
    WHERE sales > (SELECT total_sales_orderwise FROM tt)
    GROUP BY ship_mode
), ad AS (
    SELECT SUM(total_orders_shipwise) AS total_orders FROM tu
)
SELECT tu.ship_mode, (tu.total_orders_shipwise / (SELECT total_orders

 FROM ad)) * 100 AS percentage
FROM tu
WHERE tu.ship_mode = 'second class';
```
- **Focus**: The CTEs `tt`, `tu`, and `ad` calculate the average sales, count orders by shipping mode, and compute the percentage of second class shipments.

![image](https://github.com/Sudarshan028/SQL-Queries-for-Business-Insights/assets/160358210/2e42a77a-03cc-446b-8838-a3279d20846d)


## Customer Ranking by Sales

This query ranks customers based on total sales amount and calculates the percentage contribution of each customer to the total sales.

```sql
WITH cv AS (
    SELECT customer_id, order_id, SUM(sales) AS total_sales_orderswise
    FROM orders
    GROUP BY customer_id, order_id
), tv AS (
    SELECT customer_id, SUM(total_sales_orderswise) AS total_sales
    FROM cv
    GROUP BY customer_id
), cb AS (
    SELECT SUM(total_sales) AS overall_sales FROM tv
), ht AS (
    SELECT *, RANK() OVER (ORDER BY total_sales DESC) AS rank_saleswise
    FROM tv
)
SELECT ht.*, (ht.total_sales / (SELECT overall_sales FROM cb)) * 100 AS percentage_sales
FROM ht;
```
- **Focus**: The CTEs `cv`, `tv`, `cb`, and `ht` sequentially aggregate sales by customer, calculate total and overall sales, and rank customers based on total sales.

![image](https://github.com/Sudarshan028/SQL-Queries-for-Business-Insights/assets/160358210/586209a4-e4d3-4bee-822a-6615134194c2)


## Highest Average Discount Rate per Category

This query identifies the product category with the highest average discount rate among orders with quantities greater than the average.

```sql
WITH ui AS (
    SELECT AVG(quantity) AS avg_quantity FROM orders
)
SELECT TOP 1 category, AVG(discount) AS avg_discount
FROM orders
WHERE quantity > (SELECT avg_quantity FROM ui)
GROUP BY category
ORDER BY avg_discount DESC;
```
- **Focus**: The CTE `ui` calculates the average quantity, and the main query filters orders based on this average to find the category with the highest average discount.

![image](https://github.com/Sudarshan028/SQL-Queries-for-Business-Insights/assets/160358210/a809ee75-7316-42e4-9aae-65ee45396f3d)


## Usage

These queries are written to be executed on an SQL database containing an `orders` table. Make sure to customize the table and column names if they differ in your database schema.

## Contributing

Contributions to enhance the functionality or add new queries are welcome. Please submit a pull request with a detailed description of your changes.

## License

This project is licensed under the MIT License.
