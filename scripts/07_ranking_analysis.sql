
/*
====================================================
RANKING ANALYSIS
====================================================

Purpose:
This analysis uses ranking techniques and window
functions to compare loan application records across
customer, geographic, credit, and product segments.

The analysis focuses on:
- Total loan volume and portfolio concentration
- Average loan amounts
- Credit score segments
- Log-transformed loan-to-income measures
- Loan term structure
- Income segment distribution

The goal is to identify differences between segments
and support portfolio analysis and monitoring.

Note:
The results describe recorded application data.
They do not directly measure actual default rates.

====================================================
*/


/*
Business Question:
Which credit score and debt burden segments
have the highest average loan amounts?

Business Insight:
This analysis compares application counts and average
loan amounts across credit score and debt burden
segments to examine differences in recorded lending
exposure.
*/

SELECT 
    cp.credit_score_segment,
    f.debt_burden_segment,
    COUNT(f.fact_loan_id) AS total_applications,
    ROUND(AVG(f.loan_amount), 2) AS avg_loan_amount,
    DENSE_RANK() OVER (
        ORDER BY AVG(f.loan_amount) DESC
    ) AS avg_loan_amount_rank
FROM gold_analytics.fact_loan_application f
JOIN gold_analytics.dim_credit_profile cp
    ON f.credit_profile_id = cp.credit_profile_id
GROUP BY
    cp.credit_score_segment,
    f.debt_burden_segment
ORDER BY avg_loan_amount_rank
LIMIT 5;


/*
Business Question:
Which combinations of age, income segment, and region
have the highest total loan amounts across application
records?

Business Insight:
This analysis identifies the age, income, and region
combinations associated with the largest summed loan
amounts in the available application records.
*/

WITH ProfileVolume AS (
    SELECT 
        c.age,
        c.income_segment,
        p.region,
        SUM(f.loan_amount) AS total_loan_amount,
        RANK() OVER (
            ORDER BY SUM(f.loan_amount) DESC
        ) AS volume_rank
    FROM gold_analytics.fact_loan_application f
    LEFT JOIN gold_analytics.dim_customer c
        ON f.customer_id = c.customer_id
    LEFT JOIN gold_analytics.dim_property p
        ON f.property_id = p.property_id
    GROUP BY
        c.age,
        c.income_segment,
        p.region
)
SELECT *
FROM ProfileVolume
WHERE volume_rank <= 5
ORDER BY volume_rank, total_loan_amount DESC;


/*
Business Question:
How is total loan volume distributed across geographic
regions?

Business Insight:
This analysis compares application counts, total
recorded loan amounts, and average loan amounts across
regions to examine geographic concentration in the
available application records.
*/

WITH RegionalVolume AS (
    SELECT 
        p.region,
        COUNT(f.fact_loan_id) AS total_applications,
        SUM(f.loan_amount) AS total_loan_amount,
        ROUND(AVG(f.loan_amount), 2) AS avg_loan_amount,
        DENSE_RANK() OVER (
            ORDER BY SUM(f.loan_amount) DESC
        ) AS volume_rank
    FROM gold_analytics.fact_loan_application f
    LEFT JOIN gold_analytics.dim_property p
        ON f.property_id = p.property_id
    GROUP BY p.region
)
SELECT *
FROM RegionalVolume
ORDER BY volume_rank;


/*
Business Question:
How do application counts, total loan amounts, and
average credit scores vary across credit score segments?

Business Insight:
This analysis compares lending volume and average
credit scores across the defined credit score segments.
It describes the distribution of recorded lending
activity but does not directly measure actual
default risk.
*/

SELECT 
    cp.credit_score_segment,
    COUNT(f.fact_loan_id) AS total_applications,
    SUM(f.loan_amount) AS total_loan_amount,
    ROUND(AVG(f.credit_score), 2) AS avg_credit_score,
    DENSE_RANK() OVER (
        ORDER BY AVG(f.credit_score) ASC
    ) AS avg_credit_score_rank
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_credit_profile cp
    ON f.credit_profile_id = cp.credit_profile_id
WHERE cp.credit_score_segment IS NOT NULL
GROUP BY cp.credit_score_segment
ORDER BY avg_credit_score_rank;


/*
Business Question:
Which loan product combinations have the longest
average loan terms?

Business Insight:
This analysis compares application counts, total
recorded loan amounts, and average loan terms across
product combinations.
*/

WITH ProductTerms AS (
    SELECT 
        l.business_or_commercial,
        l.loan_type,
        COUNT(f.fact_loan_id) AS total_applications,
        SUM(f.loan_amount) AS total_loan_amount,
        ROUND(AVG(f.term), 1) AS avg_term,
        DENSE_RANK() OVER (
            ORDER BY AVG(f.term) DESC
        ) AS term_length_rank
    FROM gold_analytics.fact_loan_application f
    LEFT JOIN gold_analytics.dim_loan l
        ON f.loan_id = l.loan_id
    GROUP BY
        l.business_or_commercial,
        l.loan_type
)
SELECT *
FROM ProductTerms
ORDER BY term_length_rank, total_loan_amount DESC;


/*
Business Question:
Which age-group and income-segment combinations have
the highest average log-transformed loan-to-income
ratio within each region?

Business Insight:
This analysis ranks age and income segment combinations
by their average log-transformed loan-to-income measure
within each region.

Application counts should be considered when interpreting
the results, especially for small groups. The measure is
not a raw debt-to-income ratio or a direct measure of
default risk.
*/

WITH RankedProfiles AS (
    SELECT 
        p.region,
        c.age,
        c.income_segment,
        COUNT(f.fact_loan_id) AS total_applications,
        ROUND(
            AVG(f.debt_to_income_ratio), 2
        ) AS avg_log_loan_income_ratio,
        DENSE_RANK() OVER (
            PARTITION BY p.region
            ORDER BY AVG(f.debt_to_income_ratio) DESC
        ) AS log_loan_income_ratio_rank
    FROM gold_analytics.fact_loan_application f
    LEFT JOIN gold_analytics.dim_property p
        ON f.property_id = p.property_id
    LEFT JOIN gold_analytics.dim_customer c
        ON f.customer_id = c.customer_id
    WHERE p.region IS NOT NULL
      AND c.age IS NOT NULL
      AND c.income_segment IS NOT NULL
    GROUP BY
        p.region,
        c.age,
        c.income_segment
)
SELECT *
FROM RankedProfiles
WHERE log_loan_income_ratio_rank <= 3
ORDER BY
    region,
    log_loan_income_ratio_rank,
    avg_log_loan_income_ratio DESC;


/*
Business Question:
What is the distribution of total loan volume across
income segments?

Business Insight:
This analysis measures each income segment's
contribution to total recorded loan volume and compares
application counts and average loan amounts to examine
portfolio concentration.
*/

WITH IncomeMarketShare AS (
    SELECT 
        c.income_segment,
        COUNT(f.fact_loan_id) AS total_applications,
        SUM(f.loan_amount) AS total_loan_amount,
        ROUND(AVG(f.loan_amount), 2) AS avg_loan_amount,
        ROUND(
            SUM(f.loan_amount) * 100.0
            / NULLIF(
                SUM(SUM(f.loan_amount)) OVER (),
                0
            ),
            2
        ) AS portfolio_share_percent
    FROM gold_analytics.fact_loan_application f
    LEFT JOIN gold_analytics.dim_customer c
        ON f.customer_id = c.customer_id
    GROUP BY c.income_segment
)
SELECT 
    income_segment,
    total_applications,
    total_loan_amount,
    avg_loan_amount,
    portfolio_share_percent,
    DENSE_RANK() OVER (
        ORDER BY total_loan_amount DESC
    ) AS volume_rank
FROM IncomeMarketShare
ORDER BY volume_rank;
