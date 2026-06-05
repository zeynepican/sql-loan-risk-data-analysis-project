/*
====================================================
DATABASE EXPLORATION
====================================================

Purpose:
This script performs an initial exploration of the
Loan Analytics database.

The goal is to understand the overall structure of
the analytics layer before conducting detailed
analysis.

The script helps identify:
- Available tables and views
- Table schemas
- Column names and data types
- Nullability of columns
- Character length constraints
- Record counts for each table and view

Instructions:
Run each query separately and review the results
before proceeding to the next query.

====================================================
*/


/*
====================================================
EXPLORE DATABASE OBJECTS
====================================================

Purpose:
Lists all available tables and views within the
database along with their schemas and object types.

====================================================
*/

SELECT 
    TABLE_CATALOG, 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES;


/*
====================================================
EXPLORE DIM_CUSTOMER STRUCTURE
====================================================

Purpose:
Displays column metadata for the customer dimension,
including data types, nullability, and character
length limitations.

====================================================
*/

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold_analytics'
  AND TABLE_NAME = 'dim_customer';


/*
====================================================
EXPLORE DIM_LOAN STRUCTURE
====================================================

Purpose:
Displays column metadata for the loan dimension.

====================================================
*/

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold_analytics'
  AND TABLE_NAME = 'dim_loan';


/*
====================================================
EXPLORE DIM_PROPERTY STRUCTURE
====================================================

Purpose:
Displays column metadata for the property dimension.

====================================================
*/

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold_analytics'
  AND TABLE_NAME = 'dim_property';


/*
====================================================
EXPLORE DIM_CREDIT_PROFILE STRUCTURE
====================================================

Purpose:
Displays column metadata for the credit profile
dimension.

====================================================
*/

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold_analytics'
  AND TABLE_NAME = 'dim_credit_profile';


/*
====================================================
EXPLORE DIM_APPLICATION STRUCTURE
====================================================

Purpose:
Displays column metadata for the application
dimension.

====================================================
*/

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold_analytics'
  AND TABLE_NAME = 'dim_application';


/*
====================================================
EXPLORE FACT_LOAN_APPLICATION STRUCTURE
====================================================

Purpose:
Displays column metadata for the fact table
containing loan application records.

====================================================
*/

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold_analytics'
  AND TABLE_NAME = 'fact_loan_application';


/*
====================================================
EXPLORE VIEW_LOAN_DEFAULT STRUCTURE
====================================================

Purpose:
Displays column metadata for the analytical view
used throughout the project.

====================================================
*/

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold_analytics'
  AND TABLE_NAME = 'view_loan_default';


/*
====================================================
COUNT RECORDS BY TABLE
====================================================

Purpose:
Returns the total number of records contained in
each table and view within the analytics layer.

This helps validate data availability and confirms
that the imported foreign tables contain the
expected number of records.

====================================================
*/

SELECT 'dim_customer' AS table_name, COUNT(*) AS record_count
FROM gold_analytics.dim_customer

UNION ALL

SELECT 'dim_loan', COUNT(*)
FROM gold_analytics.dim_loan

UNION ALL

SELECT 'dim_property', COUNT(*)
FROM gold_analytics.dim_property

UNION ALL

SELECT 'dim_credit_profile', COUNT(*)
FROM gold_analytics.dim_credit_profile

UNION ALL

SELECT 'dim_application', COUNT(*)
FROM gold_analytics.dim_application

UNION ALL

SELECT 'fact_loan_application', COUNT(*)
FROM gold_analytics.fact_loan_application

UNION ALL

SELECT 'view_loan_default', COUNT(*)
FROM gold_analytics.view_loan_default

ORDER BY record_count DESC;
