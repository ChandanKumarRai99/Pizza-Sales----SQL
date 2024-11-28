create database pizzahut;
create table orders ( order_id int not null, order_date date not null, order_time time not null, primary key(order_id));
select * from orders;
create table order_details ( order_details_id int not null, order_id int not null, pizza_id text, quantity int not null, 
primary key(order_details_id));
select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;


-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_order_placed
FROM
    orders;


-- Calculate the total revenue generated from pizza sales.
SELECT 
    round(sum(o.quantity * p.price),2) AS total_revenue
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id;


-- Identify the highest-priced pizza.
SELECT 
    t.name, p.price
FROM
    pizza_types t
        JOIN
    pizzas p ON t.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.
SELECT 
    p.size AS pizza_size,
    COUNT(o.order_details_id) AS order_count
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY p.size
ORDER BY order_count DESC
LIMIT 1; 


-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    p.pizza_type_id AS pizza_type, SUM(o.quantity) AS quantity
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY p.pizza_type_id
ORDER BY quantity DESC
LIMIT 5;


-- Intermediate question

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    t.category AS category, SUM(o.quantity) AS quantity
FROM
    pizza_types t
        JOIN
    pizzas ON t.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details o ON pizzas.pizza_id = o.pizza_id
GROUP BY category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY order_count DESC;


-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) as total_pizza_type from pizza_types
group by category order by total_pizza_type desc;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(average), 0) AS avg_ordered_per_day
FROM
    (SELECT 
        o.order_date, SUM(t.quantity) AS average
    FROM
        orders o
    JOIN order_details t ON o.order_id = t.order_id
    GROUP BY o.order_date
    ORDER BY o.order_date) AS order_quantity;
    
    
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    t.name, SUM(p.price * o.quantity) AS revenue
FROM
    pizza_types t
        JOIN
    pizzas p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY t.name
ORDER BY revenue DESC
LIMIT 3;


-- Advanced Questions:

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    t.category,
    ROUND(SUM(p.price * o.quantity), 2) AS revenue,
    round(SUM(p.price * o.quantity) / (SELECT 
                    SUM(p.price * o.quantity)
                FROM
                    pizzas p
                        JOIN
                    order_details o ON p.pizza_id = o.pizza_id) * 100,
            2) AS percentage_distribution
FROM
    pizza_types t
        JOIN
    pizzas p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY t.category
ORDER BY revenue DESC;


-- Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cum_revenue from
(select o.order_date, sum(p.price * t.quantity) as revenue
from
pizzas p join order_details t on p.pizza_id = t.pizza_id
join 
orders o on t.order_id= o.order_id
group by o.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category,name, revenue from 
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rank_reven from
(select t.category, t.name, sum(p.price * d.quantity) as revenue from pizza_types t
join pizzas p on t.pizza_type_id= p.pizza_type_id
join order_details d on p.pizza_id= d.pizza_id
group by t.category,t.name
order by t.category) as a) as b where rank_reven <= 3;







