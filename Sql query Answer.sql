-- Basic:
-- Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(a.quantity * b.price), 2) AS total_revenue
FROM
    orders_details a
        JOIN
    pizzas b ON a.pizza_id = b.pizza_id;
    
 
-- 3. Identify the highest-priced pizza.

select a.name,b.price
from pizza_types a join 
pizzas b on a.pizza_type_id=b.pizza_type_id 
order by price desc limit 1;


-- Identify the most common pizza size ordered.
select a.size, count(b.order_details_id) as order_Count
 from pizzas a join orders_details b 
 on a.pizza_id = b.pizza_id 
 group by a.size
 order by order_count desc
 limit 1;

-- List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name, 
sum(orders_details.quantity) as quantity 
 from pizza_types  join pizzas   
 on pizza_types.pizza_type_id = pizzas.pizza_type_id 
 join orders_details 
 on orders_details.pizza_id = pizzas.pizza_id
 group by pizza_types.name
 order by quantity desc
 limit 5 ;


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category  ordered .
select a.category, 
 sum(c.quantity) as Number_of_pizza_type
 from pizza_types a join pizzas b
 on a.pizza_type_id= b.pizza_type_id 
 join orders_details c
 on c.pizza_id = b.pizza_id 
 group by a.category order by Number_of_pizza_type desc;


-- Determine the distribution of orders by hour of the day.

select hour(order_time), count(order_id) as order_count from orders
group by hour(order_time)
order by order_count desc;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name)
 from pizza_types 
 group by category;
 
-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round (avg(quantity),0) as Avg_no_of_pizzas_perday from 
(select orders.order_date, sum(orders_details.quantity) as quantity
  from orders join orders_details 
  on orders.order_id = orders_details.order_id 
  group by orders.order_date) as order_quantity;


select day(order_date) as per_day_orders,
count(order_id)  from orders
group by per_day_orders;

-- List the top 5 most ordered pizza types along with their quantities.
 select name, 
 sum(c.quantity*b.price) as Revenue
 from pizza_types a join pizzas b
 on a.pizza_type_id= b.pizza_type_id 
 join orders_details c
 on c.pizza_id = b.pizza_id 
 group by name order by Revenue desc limit 5;
 
 
 
-- Advanced
-- Calculate the percentage contribution of each pizza type to total revenue
SELECT 
  pizza_types.category,
  ROUND(SUM(orders_details.quantity * pizzas.price) / 
       (SELECT 
          ROUND(SUM(orders_details.quantity * pizzas.price), 2) 
        FROM orders_details 
        JOIN pizzas ON pizzas.pizza_id = orders_details.pizza_id) * 100, 2) AS revenue 
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
JOIN orders_details ON orders_details.pizza_id = pizzas.pizza_id 
GROUP BY pizza_types.category 
ORDER BY revenue DESC;


-- Analyze the cumulative revenue generated over time.

SELECT 
  order_date, 
  SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue 
FROM 
  (SELECT 
     orders.order_date, 
     SUM(orders_details.quantity * pizzas.price) AS revenue 
   FROM orders_details 
   JOIN pizzas ON orders_details.pizza_id = pizzas.pizza_id 
   JOIN orders ON orders.order_id = orders_details.order_id 
   GROUP BY orders.order_date) AS sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT 
  category, 
  name, 
  revenue 
FROM 
  (SELECT 
     pizza_types.category, 
     pizza_types.name, 
     SUM(orders_details.quantity * pizzas.price) AS revenue, 
     RANK() OVER (PARTITION BY pizza_types.category ORDER BY SUM(orders_details.quantity * pizzas.price) DESC) AS rn 
   FROM pizza_types 
   JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
   JOIN orders_details ON orders_details.pizza_id = pizzas.pizza_id 
   GROUP BY pizza_types.category, pizza_types.name
  ) AS ranked_pizzas 
WHERE rn <= 3;
