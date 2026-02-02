Retail Inventory Analysis (SQL + Excel + Power BI)

This project analyzes a retail inventory dataset (sales, pricing, promotions, seasonality, and customer segments).
Workflow: Download data → load into MySQL with SQL script → run analysis queries → visualize in Power BI.

Project Structure

Retail Inventory SQL.sql (table creation + import + analysis queries)

Retail Inventory Dashboard Screenshot.png (screenshot of the report)

README.md

Dataset source: Kaggle
Link: https://www.kaggle.com/datasets/suvroo/inventory-optimization-for-retail/data

Important: This is a public dataset link. You must download the file and save it on your own computer.

Setup (MySQL)

Open Retail Inventory SQL.

Find this line and replace the path with the location of your file on your computer:

LOAD DATA INFILE '/path/to/demand_forecasting.csv'


Run the SQL file in MySQL. It will:

create the database and table

import the CSV

run validation checks

generate KPI + product/store/segment revenue queries

What’s Inside the SQL Analysis

Main outputs (gross revenue only):

Overall Sales KPI (total units sold, gross revenue)

Top Products by Revenue + Revenue Share

Store Revenue Ranking

Store–Product Revenue Detail

Revenue Share by Seasonality Factor

Revenue Share by Customer Segment

A screenshot of the Power BI dashboard is included (powerbi_dashboard.png). It shows shows quick business insights, such as:

Gross Revenue KPI

Top stores by revenue

Revenue share by seasonality factor

License

This project is for learning and portfolio use.

Acknowledgments

Dataset provided by the author on Kaggle (public link above).