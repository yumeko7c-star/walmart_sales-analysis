USE walmart_db;
select*from walmart; 
---
select count(*) from walmart ; 
select
 payment_method,
 count(*)
from walmart 
group by payment_method;
 select 
 Branch 
 from walmart;
 
select min(quantity) from walmart;
-- B P 
-- Q1... FIND THE DIFFERENT PAYMENT METHOD AND NUMBER OF TRANSCATIONS, NUMBER OF QTY SOLD 
select
 payment_method,
 count(*) as no_payment,
 sum(quantity ) as no_qty_sold
from walmart 
group by payment_method;

-- Q2 IDENTIFY THE HIGHEST-RATED CATEGORY IN EACH BRANCH , DISPLAYING THE BRANCH,CATEGORY AVG RATING
SELECT *
FROM
(
    SELECT
        Branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS ranking
    FROM walmart
    GROUP BY Branch, category
) AS t
WHERE ranking = 1;

-- Q3 identify the busniss day for each branch on the number of transcation 
SELECT *
FROM (
    SELECT
        Branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (
            PARTITION BY Branch
            ORDER BY COUNT(*) DESC
        ) AS ranking
    FROM walmart
    GROUP BY Branch, day_name
) AS t
WHERE ranking = 1;

-- Q4 CALCLUTE THE TOTAL QTY OF ITMES SOLD PER PAYMENT METHOD,LIST PAYMENT_METHOD AND TOTAL_QTY.

select
 payment_method,
 SUM(quantity)AS no_qty_sold
from walmart 
group by payment_method;

-- Q5 DETERMINE THE AVERGE ,MINIMUM,AND MAXIUM RATING OF CATEOGRY FOR EACH CITY.
select
city,
category,
min(rating) as min_rating ,
max(rating) as max_rating ,
avg(rating)as avg_rating
from walmart 
group by 1,2;


-- Q6 CALCLAUTE THE TOTAL PROFIT FOR EACH CATEGORY BY CONSDERING TOTAL_PROFIT 

SELECT 
CATEGORY,
sum(total)as total_revenue,
sum(total*profit_margin) as profit
from walmart
group by 1;


-- Q3 DETERMINE THE MOST COMMON PAYMENT METHOD FOR EACH BRANCH.
SELECT *,
       RANK() OVER(
           PARTITION BY Branch
           ORDER BY total_trans DESC
       ) AS ranking
FROM (
    SELECT
        Branch,
        payment_method,
        COUNT(*) AS total_trans
    FROM walmart
    GROUP BY Branch, payment_method
) AS t;





-- Q8 CATAGORIZE SALES INTO 3 GROUP MORNING,AFTERNOON,EVENING 
SELECT
    branch,
    CASE
        WHEN HOUR(CAST(time AS TIME)) < 12 THEN 'Morning'
        WHEN HOUR(CAST(time AS TIME)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day,
    count(*)
FROM walmart 
group by 1,2;

-- Q9 IDENTIFY 5 BRANCH WITH DEVRESE RATIO IN EVEVENUE COMPARE TO LAST YEAR(CURR2023LAST2022)
WITH revenue_2022 AS
(
    SELECT
        Branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
    GROUP BY Branch
),

revenue_2023 AS
(
    SELECT
        Branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
    GROUP BY Branch
)

SELECT 
ls.branch,
ls.revenue as last_year_revenue,
cs.revenue as cr_year_revenue,
ROUND(((ls.revenue - cs.revenue) / ls.revenue) * 100, 2) AS rdr
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs
ON ls.Branch = cs.Branch
where ls.revenue>cs.revenue
order by 4 desc
limit 5;