-- Create and use the database
CREATE DATABASE IF NOT EXISTS retail_inventory_sql
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE retail_inventory_sql;

-- Recreate the base table
DROP TABLE IF EXISTS retail_inventory;

CREATE TABLE retail_inventory (
  dt DATE,
  store_id INT,
  product_id INT,
  units_sold INT,
  price DECIMAL(10,2),
  promo_flag TINYINT,
  seasonality_factor VARCHAR(30),
  external_factor VARCHAR(40),
  demand_trend VARCHAR(15),
  customer_segment VARCHAR(15),
  PRIMARY KEY (dt, store_id, product_id)
);

-- Load CSV data into the table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/demand_forecasting.csv'
INTO TABLE retail_inventory
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, @dt, store_id, units_sold, price, @promo,
 seasonality_factor, external_factor, demand_trend, customer_segment)
SET
  dt = STR_TO_DATE(@dt, '%Y-%m-%d'),
  promo_flag = CASE
    WHEN @promo = 'Yes' THEN 1
    WHEN @promo = 'No' THEN 0
    ELSE NULL
  END,
  customer_segment = TRIM(TRAILING '\r' FROM customer_segment),
  seasonality_factor = TRIM(TRAILING '\r' FROM seasonality_factor),
  external_factor = TRIM(TRAILING '\r' FROM external_factor),
  demand_trend = TRIM(TRAILING '\r' FROM demand_trend);

-- Show import warnings (if any)
SHOW COUNT(*) WARNINGS;
SHOW WARNINGS;

-- Basic import validation
SELECT COUNT(*) AS rows_imported
FROM retail_inventory;

SELECT MIN(dt) AS min_date, MAX(dt) AS max_date
FROM retail_inventory;

SELECT 
  COUNT(DISTINCT store_id) AS stores,
  COUNT(DISTINCT product_id) AS products
FROM retail_inventory;

SELECT
  SUM(dt IS NULL) AS null_dt,
  SUM(store_id IS NULL) AS null_store,
  SUM(product_id IS NULL) AS null_product,
  SUM(units_sold IS NULL) AS null_units_sold,
  SUM(price IS NULL) AS null_price
FROM retail_inventory;

-- Overall Sales KPI (gross only)
SELECT
  SUM(units_sold) AS total_units_sold,
  ROUND(SUM(units_sold * price), 2) AS gross_revenue
FROM retail_inventory;

-- Top 10 Products by Revenue + Revenue Share
WITH prod AS (
  SELECT
    product_id,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(units_sold * price), 2) AS gross_revenue
  FROM retail_inventory
  GROUP BY product_id
),
tot AS (
  SELECT SUM(gross_revenue) AS total_gross_revenue
  FROM prod
),
top10 AS (
  SELECT *
  FROM prod
  ORDER BY gross_revenue DESC
  LIMIT 10
)
SELECT
  t.product_id,
  t.total_units_sold,
  t.gross_revenue,
  ROUND(100 * t.gross_revenue / tot.total_gross_revenue, 2) AS revenue_share_percent
FROM top10 t
CROSS JOIN tot
ORDER BY t.gross_revenue DESC;

-- Store Revenue Ranking (gross only)
SELECT
  store_id,
  SUM(units_sold) AS total_units_sold,
  ROUND(SUM(units_sold * price), 2) AS gross_revenue
FROM retail_inventory
GROUP BY store_id
ORDER BY gross_revenue DESC;

-- Store–Product Revenue Detail (gross only)
SELECT
  store_id,
  product_id,
  SUM(units_sold) AS total_units_sold,
  ROUND(SUM(units_sold * price), 2) AS gross_revenue
FROM retail_inventory
GROUP BY store_id, product_id
ORDER BY gross_revenue DESC;

-- Product Revenue Summary (gross only)
SELECT
  product_id,
  SUM(units_sold) AS total_units_sold,
  ROUND(SUM(units_sold * price), 2) AS gross_revenue
FROM retail_inventory
GROUP BY product_id
ORDER BY gross_revenue DESC;

-- Revenue share by seasonality_factor
WITH s AS (
  SELECT
    seasonality_factor,
    ROUND(SUM(units_sold * price), 2) AS gross_revenue
  FROM retail_inventory
  GROUP BY seasonality_factor
),
tot AS (
  SELECT SUM(gross_revenue) AS total_gross_revenue
  FROM s
)
SELECT
  s.seasonality_factor,
  s.gross_revenue,
  ROUND(100 * s.gross_revenue / tot.total_gross_revenue, 2) AS revenue_share_percent
FROM s
CROSS JOIN tot
ORDER BY s.gross_revenue DESC;

-- Revenue share by customer_segment
WITH c AS (
  SELECT
    customer_segment,
    ROUND(SUM(units_sold * price), 2) AS gross_revenue
  FROM retail_inventory
  GROUP BY customer_segment
),
tot AS (
  SELECT SUM(gross_revenue) AS total_gross_revenue
  FROM c
)
SELECT
  c.customer_segment,
  c.gross_revenue,
  ROUND(100 * c.gross_revenue / tot.total_gross_revenue, 2) AS revenue_share_percent
FROM c
CROSS JOIN tot
ORDER BY c.gross_revenue DESC;
