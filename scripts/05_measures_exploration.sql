/*
====================================================
MEASURES EXPLORATION - LOAN ANALYTICS PROJECT
====================================================

Purpose:
This script performs Measures Exploration on the
Loan Analytics Fact Table.

It focuses on understanding the overall statistical
behavior of numerical variables such as:

- Loan Amount (Exposure)
- Income (Capacity)
- Property Value (Collateral)
- Credit Score (Risk Indicator)
- Interest Rate (Pricing)
- Debt-to-Income Ratio (Risk)
- Loan-to-Value Ratio (Risk)
- Term (Loan Duration)

The goal is to:
- Understand dataset scale
- Identify minimum / maximum boundaries
- Observe average financial behavior
- Establish baseline metrics for further analysis

====================================================
*/

--1. LOAN AMOUNT
SELECT 
 SUM(loan_amount) AS "total loan amount",
 AVG (loan_amount) AS "average loan amount", 
 MIN(loan_amount) AS "min loan amount", 
 MAX(loan_amount) AS "max loan amount" 
 FROM gold_analytics.fact_loan_application

--2. RATE OF INTEREST
SELECT 
 AVG(rate_of_interest) AS "average rate of interest", 
 MIN(rate_of_interest) AS "min rate of interest",
 MAX(rate_of_interest) AS "max rate of interest" 
FROM gold_analytics.fact_loan_application

--3. DEBT TO INCOME RATIO
SELECT 
AVG(debt_to_income_ratio) AS "average debt to income ratio", 
MIN(debt_to_income_ratio) AS "min debt to income ratio", 
MAX(debt_to_income_ratio) AS "max debt to income ratio" 
FROM gold_analytics.fact_loan_application

--4. LOAN TO VALUE RATIO
SELECT 
AVG(loan_to_value_ratio) AS "average loan to value ratio", 
MIN(loan_to_value_ratio) AS "min loan to value ratio", 
MAX(loan_to_value_ratio) AS "max loan to value ratio" 
FROM gold_analytics.fact_loan_application

--5. CREDIT SCORE
SELECT 
AVG (credit_score) AS "average credit score", 
MIN(credit_score) AS "min credit score", 
MAX(credit_score) AS "max credit score" 
FROM gold_analytics.fact_loan_application

--6. INCOME
SELECT 
AVG(income) AS "average income", 
MIN(income) AS "min income",
MAX(income) AS "max income" 
FROM gold_analytics.fact_loan_application

--7. PROPERTY VALUE
SELECT 
AVG(property_value) AS "average property value",
MIN(property_value) AS "min property value", 
MAX(property_value) AS "max property value" 
FROM gold_analytics.fact_loan_application

--8. TERM
SELECT 
AVG(term) AS "average term", 
MIN(term) AS "min term", 
MAX(term) AS "max term" 
FROM gold_analytics.fact_loan_application


SELECT term, COUNT(*) AS application_count FROM gold_analytics.fact_loan_application
GROUP BY term
ORDER BY term

--10. DIMENSION SİZE CHECK
SELECT 'Total Customer Profile Count' AS measure_name, COUNT(*) AS measure_value FROM gold_analytics.dim_customer
UNION ALL
SELECT 'Total Credit Profile Count', COUNT(*) FROM gold_analytics.dim_credit_profile
UNION ALL
SELECT 'Total Property Profile Count', COUNT(*) FROM gold_analytics.dim_property
UNION ALL
SELECT 'Total Application Profile Count', COUNT(*) FROM gold_analytics.dim_application
UNION ALL
SELECT 'Total Loan Profile Count', COUNT(*) FROM gold_analytics.dim_loan
UNION ALL
SELECT 'Total Loan Application Count', COUNT(*) FROM gold_analytics.fact_loan_application















