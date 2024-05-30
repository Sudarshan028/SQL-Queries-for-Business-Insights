select * from orders;
--Which product categories have the highest average profit margin, and what is the rank of each category based on this metric?
select category,avg_profit_margin,rank() over(order by avg_profit_margin desc) as rank_category
from (select category, avg(profit/Sales) as avg_profit_margin from orders
group by category)  as reults;


--For each customer segment, what is the total sales and profit, and which segment has the highest average discount rate?
with re as (select segment, sum(sales) as total_sales, sum(profit)as total_profit, avg(discount) as avg_discount from orders
group by segment)

select segment, total_sales, total_profit, avg_discount from
re
where avg_discount = (select max(avg_discount) from re);

--Among orders with a quantity greater than the average quantity per order, which product sub-category has the highest average sales?
with mi as (select avg(quantity) as avg_quantity from orders)

select top 1 sub_category , avg(sales) as avg_sales from orders
where quantity > (select avg_quantity from mi)
group by sub_category
order by avg_sales desc;

--What is total sales of the customers combined?
with lk as (select order_id, customer_id, sum(sales) as total_sales from orders
group by customer_id, order_id)

select customer_id, sum(total_sales) as total_sales1 from lk
group by customer_id
order by total_sales1 desc;

 

--For each state, what is the total sales, profit, and average discount rate, and which state has the highest total sales?
with et as (select order_id , state, sum(sales) as total_sales, sum(profit) as total_profit, avg(discount) as avg_discount from orders
group by order_id, state)

select top 1 state, sum(total_sales) as total_sales1 from et
group by state 
order by total_sales1 desc;

--What is the rank of each city based on the total number of orders placed, and what percentage of total orders does each city contribute?
with st as (select city, count(order_id) as city_wise_orders from orders
group by city)

, mt as (select city, city_wise_orders ,rank() over(order by city_wise_orders desc) as rank_orders from st
group by city, city_wise_orders)

, qt as (select sum(city_wise_orders) as total_orders from mt)

, tm as (select mt.* , qt.* from mt
inner join qt on 1=1)

select city , city_wise_orders, rank_orders, (city_wise_orders/total_orders)*100.0 as percentage_of_total_orders from tm 
group by city , city_wise_orders, rank_orders , total_orders;

--Among orders with a profit higher than the average profit per order, which shipping mode is most commonly used?
with pt as (select avg(profit) as avg_profit from orders)
, qw as (select ship_mode from orders where profit > (select avg_profit from pt))
select ship_mode, count(ship_mode) as total_used from qw
group by ship_mode 
order by total_used desc;

--For each product category, what is the difference between the highest and lowest discount rates applied to orders?
with dis as (select category, order_id, sum(discount) as total_discount  from orders
group by order_id, category)

select category, max(total_discount)-min(total_discount) as difference_discount from dis
group by category;




--What is the average quantity sold for each product category, and which category has the highest total sales? 
with er as (select category, order_id, sum(quantity) as total_quantity, sum(sales) as total_sales from orders
group by category, order_id)

select category, avg(total_quantity) as avg_quantity, sum(total_sales) as total_final_sales from er
group by category
order by total_final_sales desc;



--For each customer, what is the difference between the highest and lowest sales amount across all orders?
with ts as (select customer_id,order_id, sum(sales) as total_sales from orders
group by customer_id, order_id)

select customer_id ,max(total_sales) as max_sales,min(total_sales) as min_sales,  max(total_sales)-min(total_sales) as difference_of_sales from ts
group by customer_id;

--What is the total profit for each year, and what percentage of total profit does each year contribute?
with st as (select sum(profit) as total_profit from orders)

,yt as (select *, year(ship_date) as year_of_shipping from orders)

,tm as (select year_of_shipping, sum(profit) as profit_yearwise from yt
group by year_of_shipping)

, ty as (select tm.*, st.total_profit from tm
inner join st on 1=1)

select *, (profit_yearwise/total_profit *100.0) as percentage_contribute from ty



--Among orders with a sales value higher than the average sales per order, what percentage of orders were shipped using the second class shipping mode?
select * from orders;
with tt as (select avg(sales) as toatal_sales_orderwise from orders)

, tu as (select ship_mode,count(order_id) as total_orders_shipwise from orders
where sales > (select toatal_sales_orderwise from tt)
group by ship_mode)

, ad as (select sum(total_orders_shipwise) as total_orders  from tu)

select tu.ship_mode, ((tu.total_orders_shipwise)/(select total_orders from ad)) as pre  from tu
where tu.ship_mode = 'second class';


--What is the rank of each customer based on the total sales amount, and what percentage of total sales does each customer contribute?
with cv as (select customer_id , order_id, sum(sales) as total_sales_orderswise from orders
group by customer_id, order_id)

, tv as (select customer_id, sum(total_sales_orderswise) as total_sales from cv
group by customer_id)

, cb as (select sum(total_sales) as overall_sales from tv)

,ht as (select *, rank() over(order by total_sales desc) as rank_saleswise from tv)

select ht.* , ht.total_sales/(select overall_sales from cb) *100 as percentage_sales from ht


--Among orders with a quantity greater than the average quantity per order, which product category has the highest average discount rate?
with ui as (select avg(quantity) as avg_quantity from orders)

select top 1 category , avg(discount) as avg_discount from orders
where quantity > (select avg_quantity from ui)
group by category
order by avg_discount desc;

--