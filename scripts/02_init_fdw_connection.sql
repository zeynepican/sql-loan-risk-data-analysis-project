/*
====================================================
ANALYTICS LAYER SETUP (FDW CONNECTION)
====================================================

Purpose:
This script connects the Analytics Database to the
Data Warehouse (DWH) using PostgreSQL FDW.

It imports the Gold layer tables as foreign tables
for analysis purposes.

IMPORTANT:
- Run each section sequentially.
- Do NOT expose credentials in production or GitHub.
- Replace placeholders for user and password locally.

====================================================
*/

-- Enable FDW extension
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Create connection to Data Warehouse
CREATE SERVER dwh_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (
    host 'localhost',
    dbname 'loan_analytics_dwh',
    port '5432'
);

-- Map user credentials (replace locally)
CREATE USER MAPPING FOR CURRENT_USER
SERVER dwh_server
OPTIONS (
    user 'YOUR_DB_USER',
    password 'YOUR_DB_PASSWORD'
);

-- Import Gold layer as analytics schema
IMPORT FOREIGN SCHEMA gold
FROM SERVER dwh_server
INTO gold_analytics;
