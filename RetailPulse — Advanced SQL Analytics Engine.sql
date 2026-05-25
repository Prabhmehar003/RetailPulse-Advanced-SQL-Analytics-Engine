-- ============================================================
--        RETAIL SALES - ADVANCED SQL ANALYTICS PROJECT
--        Author    : Prabhmehar Dhalio
--        Database  : PostgreSQL
--        Created   : 2026
--        Purpose   : End-to-end retail sales analysis covering
--                    data engineering, cleaning, exploration,
--                    and advanced business intelligence queries.
-- ============================================================


-- ============================================================
-- SECTION 1 : DATABASE & TABLE SETUP
-- ============================================================

CREATE DATABASE retail_db;

DROP TABLE IF EXISTS retail_sales;
---Here I used the the syntax:- coloumn_name(Name of the field)    Data_type(What kind of data it stores)   Constraint(Rules applied to data)

CREATE TABLE retail_sales(
transactions_id INT PRIMARY KEY,
sale_date DATE NOT NULL,
sale_time TIME NOT NULL,
customer_id INT NOT NULL,
gender VARCHAR(15),
age INT CHECK(age BETWEEN 0 AND 120),
category VARCHAR(20),
quantity INT CHECK(quantity>0),
price_per_unit NUMERIC(10,2),
cogs NUMERIC(10,2),
total_sale NUMERIC(10,2)
);

-- Preview inserted data
SELECT * FROM retail_sales;


-- ============================================================
-- SECTION 2 : DATA QUALITY & CLEANING
-- ============================================================

-- 2A. Identify NULL values across every column
SELECT * FROM retail_sales
WHERE transactions_id IS NULL
OR sale_date IS NULL
OR sale_time IS NULL
OR customer_id IS NULL
OR gender IS NULL
OR age IS NULL
OR category IS NULL
OR quantity IS NULL
OR price_per_unit IS NULL
OR cogs IS NULL
OR total_sale IS NULL;

-- 2B. Identify exact duplicate transaction IDs
---This is Data intergrity Validation step(Checking whether the data is correct, accurate, and reliable)
---Although Primary key already stops duplicate transaction IDs, but I still used this query to double-check that the imported data is clean and correct

SELECT transactions_id, COUNT(*) AS occurenece 
FROM retail_sales
GROUP BY  transactions_id
HAVING COUNT(*) > 1;

---- 2C. Detect logical inconsistencies 
---This query checks whether the total sale value is correctly calculated from quantity and price per unit

SELECT transactions_id,quantity,price_per_unit,total_sale,
ROUND((quantity*price_per_unit)::NUMERIC,2) AS expected_total, ---This is the main reason for ::NUMERIC.In your table, quantity is defined as INT and price_per_unit is NUMERIC. When you multiply them it will give error.
ABS(total_sale -(quantity*price_per_unit)) AS Discrepancy ---ABS removes the negative sign from any negative number — always gives you a positive result.
FROM retail_sales
WHERE ABS(total_sale -(quantity*price_per_unit)) > 1 
ORDER BY Discrepancy DESC;

-- 2D. Detect statistical outliers using IQR(Inter Quartile Range)method
---IQR finds the middle 50% of your data, builds a safe zone around it, and anything sitting far outside that zone is flagged as an outlier — a suspiciously weird value worth investigating.
WITH stats AS(
SELECT 
    PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY total_sale) AS q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY total_sale) AS q3
FROM retail_sales)
SELECT t.*
FROM retail_sales t,stats
WHERE t.total_sale < (stats.q1-1.5*(stats.q3-stats.q1))
OR t.total_sale > (stats.q3 + 1.5*(stats.q3-stats.q1));


-- 2E. Remove NULL records
DELETE FROM retail_sales
WHERE transactions_id IS NULL
OR sale_date IS NULL
OR sale_time IS NULL
OR customer_id IS NULL
OR gender IS NULL
OR age IS NULL
OR category IS NULL
OR quantity IS NULL
OR price_per_unit IS NULL
OR cogs IS NULL
OR total_sale IS NULL;


-- 2F. Post-cleaning row count
SELECT COUNT(*) AS clean_record_count FROM retail_sales;


-- ============================================================
-- SECTION 3 : DATA EXPLORATION (EDA)
-- ============================================================


-- 3A. Dataset overview: date range and totals
SELECT 
COUNT(*) AS total_transactions,
COUNT(DISTINCT customer_id) AS unique_customers,
COUNT(DISTINCT category) AS unique_categories,
MIN(sale_date) AS earliest_sale,
MAX(sale_date) AS latest_sale,
ROUND(SUM(total_sale)::NUMERIC, 2) AS gross_revenue,
ROUND(AVG(total_sale)::NUMERIC, 2) AS avg_transaction_value
FROM retail_sales;

-- 3B. Sales volume and revenue per category
SELECT 
category,
COUNT(*) AS total_transactions,
SUM(quantity) AS units_sold,
    ROUND(SUM(total_sale)::NUMERIC, 2) AS revenue,
    ROUND(100.0 * SUM(total_sale) / SUM(SUM(total_sale)) OVER (),2) AS revenue_share_pct ---SUM(SUM(total_sale)) OVER () says:"Take those individual category totals — and add ALL of them together into one grand total"OVER () is like temporarily breaking down all the walls between groups and saying:"Step outside your own group for a moment — look at ALL the data together — now calculate."
FROM retail_sales
GROUP BY category
ORDER BY revenue DESC;

-- 3C. Gender distribution per category
SELECT 
gender,
category,
COUNT(transactions_id) AS transactions
FROM retail_sales
GROUP BY category,gender;



-- ============================================================
-- SECTION 4 : BUSINESS ANALYTICS — CORE QUESTIONS
-- ============================================================

-- Q1. All transactions on a specific date
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';   ---Single quotes is used for Values/Data — actual content and whereas Double quotes is used for Names/Labels — column or table names.

-- Q2. Clothing transactions with qty >= 4 in November 2022
SELECT *
FROM retail_sales
WHERE category = 'Clothing' AND quantity >=4 AND sale_date BETWEEN '2022-11-01' AND '2022-11-30'; 

-- Q3. Total revenue per category
SELECT category,
ROUND(SUM(total_sale)::NUMERIC, 2) AS total_revenue
FROM retail_sales
GROUP BY category
ORDER BY total_revenue DESC;

-- Q4. Average customer age per category
SELECT category,
ROUND(AVG(age), 1) AS avg_customer_age
FROM  retail_sales
GROUP BY category
ORDER BY avg_customer_age;

-- Q5. High-value transactions (total_sale > 1000)
SELECT transactions_id,customer_id,age,quantity,total_sale
FROM retail_sales
WHERE total_sale > 1000

-- Q6. Transaction count by gender and category 
SELECT category,gender,COUNT(transactions_id) AS transaction_count
FROM retail_sales
GROUP BY category, gender
ORDER BY category, gender;

-- Q7. Best-selling month per year (using RANK window function)
WITH monthly_avg AS (
SELECT
EXTRACT(YEAR  FROM sale_date)::INT AS year,
EXTRACT(MONTH FROM sale_date)::INT AS month,
TO_CHAR(sale_date, 'Month')  AS month_name,
ROUND(AVG(total_sale)::NUMERIC, 2) AS avg_sale,
RANK() OVER ( 
PARTITION BY EXTRACT(YEAR FROM sale_date)
ORDER BY AVG(total_sale) DESC
) AS sales_rank
FROM retail_sales
GROUP BY year, month, month_name
)
SELECT year, month, month_name, avg_sale
FROM monthly_avg
WHERE sales_rank = 1;

---Ques8 Write a SQL query to find the top 5 customers based on the highest total sales
SELECT 
customer_id,SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

---Ques9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT COUNT(Distinct customer_id) as unique_customers, category
FROM retail_sales
GROUP BY category;

---Ques10  Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
WITH hourly_sale
AS
(SELECT *,
CASE 
    WHEN EXTRACT(HOUR FROM sale_time) <12 THEN 'Morning'
	WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
	ELSE 'Evening'
END AS Shift
FROM retail_sales
)

SELECT 
Shift,COUNT(transactions_id)
FROM hourly_sale
GROUP BY Shift;
---Here above we have created common table expression(CTE) as without it we can not use the new created coloumn for order by and group by.


 -- ============================================================
-- SECTION 5 : ADVANCED ANALYTICS (STANDS YOU APART)
-- ============================================================ 


-- ─────────────────────────────────────────────────────────────
-- A5.1  MONTH-OVER-MONTH REVENUE GROWTH (LAG window function)
-- ─────────────────────────────────────────────────────────────
WITH monthly_revenue AS (
SELECT 
EXTRACT(YEAR FROM sale_date)::INT AS year,
EXTRACT(MONTH FROM sale_date)::INT AS month,
ROUND(SUM(total_sale)::NUMERIC,2) AS revenue
FROM retail_sales
GROUP BY year,month
),
mom_growth AS(
SELECT*,
LAG(revenue) OVER(ORDER BY year,month) AS prev_month_revenue,  ---LAG simply fetches the value from the PREVIOUS row
ROUND(
100.0 *  100.0 * (revenue - LAG(revenue) OVER (ORDER BY year, month))/NULLIF(LAG(revenue)OVER(ORDER BY year,month),0),2) AS mom_growth_percentage
FROM monthly_revenue
)

SELECT year,month,revenue,prev_month_revenue,
COALESCE(mom_growth_percentage::TEXT||'%','N/A') AS mom_growth ---COALESCE fixes this:"If the value is NULL — replace it with something else"
FROM mom_growth   ---The ::TEXT converts the number to text so we can attach % sign using || which is SQL's way of joining text together.
ORDER BY year,month;

-- ─────────────────────────────────────────────────────────────
-- A5.2  CUMULATIVE / RUNNING REVENUE (Year-to-Date)
-- ─────────────────────────────────────────────────────────────
SELECT sale_date,
ROUND(SUM(total_sale)::NUMERIC,2) AS daily_revenue,
ROUND(SUM(SUM(total_sale)) OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY sale_date)::NUMERIC,2)  ---ORDER BY inside OVER() tells SQL — add rows one by one in order — not all at once
FROM retail_sales
GROUP BY sale_date
ORDER BY sale_date;


-- ─────────────────────────────────────────────────────────────
-- A5.3  CUSTOMER RFM SEGMENTATION
--       Recency · Frequency · Monetary
-- ─────────────────────────────────────────────────────────────

WITH rfm_base AS(
SELECT 
customer_id,
MAX(sale_date) AS last_purchase_date,
(MAX(sale_date) -MIN(sale_date)) AS tenure_days,
COUNT(transactions_id) AS frequency,
    ROUND(SUM(total_sale)::NUMERIC, 2) AS monetary
    FROM retail_sales
    GROUP BY customer_id
),
rfm_scored AS(
SELECT*,
NTILE(4) OVER(ORDER BY last_purchase_date DESC) AS r_score,  ----NTILE simply divides all customers into equal groups and gives each group a number.NTILE(4) = divide into 4 equal groups — like 4 buckets.
NTILE(4) OVER(ORDER BY frequency DESC) AS f_score,
NTILE(4) OVER(ORDER BY monetary DESC) AS m_score
FROM rfm_base
)

SELECT 
customer_id,
last_purchase_date,
frequency,
monetary,
r_score,
f_score,
m_score,
(r_score + f_score + m_score)  AS rfm_total,
    CASE 
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Champion'
        WHEN (r_score + f_score + m_score) >= 7  THEN 'Loyal Customer'
        WHEN (r_score + f_score + m_score) >= 5  THEN 'Potential Loyalist'
        WHEN r_score >= 3 THEN 'New Customer'
        ELSE 'At Risk'
    END AS customer_segment
FROM rfm_scored
ORDER BY rfm_total DESC;


-- ─────────────────────────────────────────────────────────────
-- A5.4  CATEGORY REVENUE RANKING PER MONTH (DENSE_RANK)
-- ─────────────────────────────────────────────────────────────
WITH category_monthly AS (
SELECT 
EXTRACT(YEAR  FROM sale_date)::INT AS year
EXTRACT(MONTH FROM sale_date)::INT AS month,
category,
ROUND(SUM(total_sale)::NUMERIC, 2) AS revenue
FROM retail_sales
GROUP BY year, month, category
)
SELECT 
year,
month,
category,
revenue,
DENSE_RANK() OVER ( PARTITION BY year, month ORDER BY revenue DESC) AS category_rank ----DENSE_RANK never skips a number — RANK does.It is smarter brother of rank
FROM category_monthly
ORDER BY year, month, category_rank;


-- ─────────────────────────────────────────────────────────────
-- A5.5  GROSS PROFIT MARGIN ANALYSIS
-- ─────────────────────────────────────────────────────────────
SELECT 
    category,
    ROUND(SUM(total_sale)::NUMERIC, 2) AS total_revenue,
    ROUND(SUM(cogs)::NUMERIC, 2) AS total_cogs,
    ROUND((SUM(total_sale) - SUM(cogs))::NUMERIC, 2) AS gross_profit,
    ROUND(100.0 * (SUM(total_sale) - SUM(cogs)) / NULLIF(SUM(total_sale), 0),2) AS gross_margin_pct
FROM retail_sales
GROUP BY category
ORDER BY gross_margin_pct DESC;



-- ============================================================
-- SECTION 6 : VIEWS FOR REPORTING LAYER
-- ============================================================
 
-- Reusable view: category KPI summary
CREATE OR REPLACE VIEW vw_category_kpi AS
SELECT 
category,
COUNT(transactions_id) AS total_transactions,
COUNT(DISTINCT customer_id) AS unique_customers,
SUM(quantity) AS units_sold,
ROUND(SUM(total_sale)::NUMERIC, 2) AS revenue,
ROUND(SUM(cogs)::NUMERIC, 2) AS cogs,
ROUND((SUM(total_sale)-SUM(cogs))::NUMERIC, 2) AS gross_profit,
ROUND(AVG(total_sale)::NUMERIC, 2)  AS avg_transaction_value
FROM retail_sales
GROUP BY category;
 
-- Usage:
SELECT * FROM vw_category_kpi ORDER BY revenue DESC;
 
-- Reusable view: daily revenue tracker
CREATE OR REPLACE VIEW vw_daily_revenue AS
SELECT 
sale_date,
COUNT(transactions_id) AS orders,
ROUND(SUM(total_sale)::NUMERIC, 2)  AS revenue,
ROUND(SUM(SUM(total_sale)) OVER (PARTITION BY EXTRACT(YEAR FROM sale_date)ORDER BY sale_date)::NUMERIC, 2) AS ytd_revenue
FROM retail_sales
GROUP BY sale_date;
 
-- Usage:
SELECT * FROM vw_daily_revenue ORDER BY sale_date;


-- ============================================================
-- SECTION 7 : PERFORMANCE OPTIMISATION
-- ============================================================
 
-- Index on sale_date — speeds up all date-range filters
CREATE INDEX IF NOT EXISTS idx_retail_sale_date
    ON retail_sales (sale_date);
 
-- Index on category — speeds up GROUP BY / WHERE on category
CREATE INDEX IF NOT EXISTS idx_retail_category
    ON retail_sales (category);
 
-- Composite index for customer lifetime value queries
CREATE INDEX IF NOT EXISTS idx_retail_customer_total
    ON retail_sales (customer_id, total_sale);
 
-- Partial index: high-value transactions (common filter)
CREATE INDEX IF NOT EXISTS idx_retail_high_value
    ON retail_sales (total_sale)
    WHERE total_sale > 1000;



-- ============================================================
--                    END OF PROJECT
-- ============================================================
 