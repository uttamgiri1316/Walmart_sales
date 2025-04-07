SELECT * FROM walmart_db.walmart_db;
use walmart_db;
select count(*) from walmart_db;

-- Business Problems
-- Q.1 
-- Find different payment method and number of transactions, number of qty sold

SELECT 
      payment_method,
      COUNT(*) as no_payments,
      SUM(quantity) as no_qty_sold
FROM walmart_db
GROUP BY payment_method
ORDER BY no_qty_sold desc;

-- Q.2
-- Identify the highest-rated category in each branch, displaying the branch,category
-- AVG RATING

SELECT 
    branch,
    category,
    avg_rating,
    RANK() OVER(PARTITION BY branch ORDER BY avg_rating DESC) AS ranker
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating
    FROM walmart_db
    GROUP BY branch, category
) AS sub;

-- Q.3 
-- Identify the busiest day for each branch based on the number of transactions.

SELECT *
FROM (
    SELECT 
        branch,
        DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranker
    FROM walmart_db
    GROUP BY branch, day_name
) AS ranked_data
WHERE ranker = 1;

-- Q.4 
-- Calculate the total quantity of items sold per payment method. List payments_method and total_payments

SELECT 
	payment_method,
    SUM(quantity) as no_qty_sold
FROM walmart_db
GROUP BY payment_method;

-- Q.5 
-- Determine the average,minimum and maximum rating of products for each city.
-- List the city, average_rating, min_rating, and max_rating.
SELECT 
	city,
	category,
	MIN(rating) as min_rating,
    MAx(rating) as max_rating,
    AVG(rating) as avg_rating
FROM walmart_db
GROUP BY 1,2;

-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price*quantity*profit_margin)
-- List category and total_profit,ordered form highet to lowest profit.

SELECT 
	category,
     SUM(amount) as total_revenue,
    SUM(amount * profit_margin) as profit
FROM walmart_db
GROUP BY 1;
    
-- Q.7
-- Determine the most common payments method for each Branch
-- Display Branch and the preferrec_payment_method.

WITH cte
AS
(SELECT 
	branch,
    payment_method,
    COUNT(*) AS total_trans,
    RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as ranker
FROM walmart_db
GROUP BY 1,2
)
SELECT * from cte
where ranker-1;

-- Q.8
-- Categories sales into 3 groups MORINING , AFTERNOON,EVENING
-- Find out each of the shift and number of invoices

SELECT 
    *,
    TIME(STR_TO_DATE(time, '%H:%i:%s')) AS only_time,
    CASE 
        WHEN HOUR(STR_TO_DATE(time, '%H:%i:%s')) < 12 THEN 'Morning'
        WHEN HOUR(STR_TO_DATE(time, '%H:%i:%s'))BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_period
FROM walmart_db;

-- Q.9
-- Indetify 5 branches with highest decrease ratio in
-- revevenue compare to last year(current year 2023 and last year 2022)

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(amount) AS revenue
    FROM walmart_db
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(amount) AS revenue
    FROM walmart_db
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;











