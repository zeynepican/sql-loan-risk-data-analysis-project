/*
====================================================
MAGNITUDE ANALYSIS
====================================================

Purpose:
Analyze the financial, portfolio, collateral,
and customer-related magnitudes across different
business dimensions.

These queries measure the size, volume, and
distribution of key business metrics such as:

- Loan Amount
- Property Value
- Income
- Application Volume
- Portfolio Size

The objective is to identify which customer,
credit, property, and loan segments contribute
the most to the overall lending portfolio.

====================================================
*/

/*
Business Question:
Which regions are associated with higher-value
properties?

Measures the average collateral value across
different geographic regions.
*/

SELECT region, AVG(property_value) AS avg_property_value
FROM gold_analytics.fact_loan_application a
LEFT JOIN gold_analytics.dim_property d
ON a.property_id = d.property_id
GROUP BY region


/*
Business Question:
How does average borrower income differ by
gender?

Measures income magnitude across gender groups.
*/
SELECT gender, AVG(income) AS avg_income
FROM gold_analytics.fact_loan_application a
LEFT JOIN gold_analytics.dim_customer c
ON a.customer_id = c.customer_id
GROUP BY gender

/*
Business Question:
Which loan types are associated with larger
average loan amounts?

Measures average lending magnitude by loan type.
*/
SELECT loan_type, AVG(loan_amount) AS avg_loan_amount
FROM gold_analytics.fact_loan_application a
LEFT JOIN gold_analytics.dim_loan l
ON a.loan_id = l.loan_id
GROUP BY loan_type

/*
Business Question:
Which loan products contribute the most to
the lending portfolio?

Measures portfolio size, average interest rate,
and average loan term by product category.
*/
SELECT 
    l.business_or_commercial,
    l.loan_type,
    SUM(f.loan_amount) AS total_loan_amount, -- Ürün bazlı portföy büyüklüğü
    ROUND(AVG(f.rate_of_interest), 3) AS avg_interest_rate, -- Faiz büyüklüğü (ortalama)
    AVG(f.term) AS avg_term_months                          -- Vade büyüklüğü (süre)
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_loan l ON f.loan_id = l.loan_id
GROUP BY l.business_or_commercial, l.loan_type
ORDER BY total_loan_amount DESC;
/*
Business Question:
Which age groups generate the largest loan
volumes?

Measures total lending exposure and average
income across age categories.
*/
SELECT 
c.age,
SUM(f.loan_amount) AS total_loan_amount,
AVG(f.income) AS avg_income
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_customer c
ON f.customer_id = c.customer_id
GROUP BY age
ORDER BY total_loan_amount DESC
/*
Business Question:
Which credit score segments account for the
largest lending volumes?

Measures portfolio magnitude across borrower
credit quality segments.
*/
SELECT
    cp.credit_score_segment,
    SUM(f.loan_amount) AS total_loan_amount,
    AVG(f.credit_score) AS avg_credit_score
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_credit_profile cp
    ON f.credit_profile_id = cp.credit_profile_id
GROUP BY cp.credit_score_segment
ORDER BY total_loan_amount DESC;

/*
Business Question:
Which property occupancy types contribute the
largest collateral values?

Measures total and average property values by
occupancy category.
*/
SELECT
    p.occupancy_type,
    SUM(f.property_value) AS total_property_value,
    AVG(f.property_value) AS avg_property_value
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_property p
    ON f.property_id = p.property_id
GROUP BY p.occupancy_type
ORDER BY total_property_value DESC;
/*
Business Question:
Which security types support the largest loan
portfolios?

Measures loan portfolio magnitude by security
classification.
*/
SELECT
    l.security_type,
    SUM(f.loan_amount) AS total_loan_amount,
    AVG(f.loan_amount) AS avg_loan_amount
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_loan l
    ON f.loan_id = l.loan_id
GROUP BY l.security_type
ORDER BY total_loan_amount DESC;
/*
Business Question:
How is lending volume distributed across
credit types?

Measures portfolio size and average loan amount
by credit type.
*/
SELECT
    cp.credit_type,
    SUM(f.loan_amount) AS total_loan_amount,
    AVG(f.loan_amount) AS avg_loan_amount
FROM gold_analytics.fact_loan_application f
JOIN gold_analytics.dim_credit_profile cp
    ON f.credit_profile_id = cp.credit_profile_id
GROUP BY cp.credit_type
ORDER BY total_loan_amount DESC;
/*
Business Question:
Which borrower debt burden segments account
for the largest lending exposure?

Measures total loan volume and average debt-to-
income ratio across debt burden categories.
*/
SELECT
    debt_burden_segment,
    SUM(loan_amount) AS total_loan_amount,
    AVG(debt_to_income_ratio) AS avg_dti
FROM gold_analytics.fact_loan_application
GROUP BY debt_burden_segment
ORDER BY total_loan_amount DESC;
/*
Business Question:
How does portfolio size vary across loan limit
categories?

Measures total and average loan amounts by
loan limit classification.
*/
SELECT
    l.loan_limit,
    SUM(f.loan_amount) AS total_loan_amount,
    AVG(f.loan_amount) AS avg_loan_amount
FROM gold_analytics.fact_loan_application f
JOIN gold_analytics.dim_loan l
    ON f.loan_id = l.loan_id
GROUP BY l.loan_limit
ORDER BY total_loan_amount DESC;

/*
Business Question:
Which region and income segment combinations
generate the highest lending demand?

Measures application volume, total loan volume,
average loan size, and average income across
regional income segments.
*/
SELECT 
    p.region,
    c.income_segment,
    COUNT(f.fact_loan_id) AS total_applications,              -- Hacimsel Büyüklük
    SUM(f.loan_amount) AS total_loan_amount,                 -- Toplam Finansal Büyüklük
    ROUND(AVG(f.loan_amount), 2) AS avg_loan_per_app,        -- Kredi Başına Ortalama Magnitude
    ROUND(AVG(f.income), 2) AS average_income                -- Gelir Seviyesi
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_property p ON f.property_id = p.property_id
LEFT JOIN gold_analytics.dim_customer c ON f.customer_id = c.customer_id
GROUP BY p.region, c.income_segment
ORDER BY avg_loan_per_app DESC; -- En yüksek kredi iştahına göre sıraladık









