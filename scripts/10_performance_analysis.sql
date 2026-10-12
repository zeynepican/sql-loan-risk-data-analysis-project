
/*
===============================================================================
PERFORMANCE ANALYSIS
===============================================================================

Purpose:
    Analyze loan default performance across different business dimensions,
    including credit score segments, income segments, loan types, and property
    regions.

    This analysis compares the number of applications, defaulted applications,
    and default rates to identify differences in portfolio performance.

Key Metrics:
    - Total Applications
    - Defaulted Applications
    - Applications with Known Default Status
    - Default Rate (%)

Data Sources:
    - gold_analytics.fact_loan_application
    - gold_analytics.dim_credit_profile
    - gold_analytics.dim_customer
    - gold_analytics.dim_loan
    - gold_analytics.dim_property

Methodology:
    Default rate is calculated by dividing the number of applications marked
    as defaults by the number of applications with a known default status.

    Applications with a NULL default status are excluded from the denominator
    to avoid distorting the calculated rate.

    The results describe observed relationships in the dataset and do not
    establish causal relationships.

===============================================================================
*/


/*
===============================================================================
1. CREDIT SCORE SEGMENT PERFORMANCE
===============================================================================

Business Question:
    Do default rates differ across credit score segments?

Analysis:
    Compare default rates across credit score segments to examine whether
    portfolio performance varies by credit risk classification.

===============================================================================
*/

SELECT
    cp.credit_score_segment,
    COUNT(*) AS total_applications,
    COUNT(*) FILTER (
        WHERE f.is_default = TRUE
    ) AS defaulted_applications,
    COUNT(*) FILTER (
        WHERE f.is_default IS NOT NULL
    ) AS applications_with_known_status,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE f.is_default = TRUE
        ) / NULLIF(
            COUNT(*) FILTER (
                WHERE f.is_default IS NOT NULL
            ),
            0
        ),
        2
    ) AS default_rate_pct
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_credit_profile cp
    ON f.credit_profile_id = cp.credit_profile_id
GROUP BY
    cp.credit_score_segment
ORDER BY
    default_rate_pct DESC NULLS LAST;


/*
===============================================================================
2. INCOME SEGMENT PERFORMANCE
===============================================================================

Business Question:
    Do default rates differ across borrower income segments?

Analysis:
    Compare default rates across income segments to examine how observed
    default performance varies among borrowers with different income levels.

===============================================================================
*/

SELECT
    c.income_segment,
    COUNT(*) AS total_applications,
    COUNT(*) FILTER (
        WHERE f.is_default = TRUE
    ) AS defaulted_applications,
    COUNT(*) FILTER (
        WHERE f.is_default IS NOT NULL
    ) AS applications_with_known_status,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE f.is_default = TRUE
        ) / NULLIF(
            COUNT(*) FILTER (
                WHERE f.is_default IS NOT NULL
            ),
            0
        ),
        2
    ) AS default_rate_pct
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY
    c.income_segment
ORDER BY
    default_rate_pct DESC NULLS LAST;


/*
===============================================================================
3. LOAN TYPE PERFORMANCE
===============================================================================

Business Question:
    Do default rates differ across loan types?

Analysis:
    Compare default rates by loan type to identify differences in observed
    default performance across loan categories.

===============================================================================
*/

SELECT
    l.loan_type,
    COUNT(*) AS total_applications,
    COUNT(*) FILTER (
        WHERE f.is_default = TRUE
    ) AS defaulted_applications,
    COUNT(*) FILTER (
        WHERE f.is_default IS NOT NULL
    ) AS applications_with_known_status,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE f.is_default = TRUE
        ) / NULLIF(
            COUNT(*) FILTER (
                WHERE f.is_default IS NOT NULL
            ),
            0
        ),
        2
    ) AS default_rate_pct
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_loan l
    ON f.loan_id = l.loan_id
GROUP BY
    l.loan_type
ORDER BY
    default_rate_pct DESC NULLS LAST;


/*
===============================================================================
4. PROPERTY REGION PERFORMANCE
===============================================================================

Business Question:
    Do default rates differ across property regions?

Analysis:
    Compare default rates by property region to examine geographic differences
    in observed loan default performance.

===============================================================================
*/

SELECT
    p.region,
    COUNT(*) AS total_applications,
    COUNT(*) FILTER (
        WHERE f.is_default = TRUE
    ) AS defaulted_applications,
    COUNT(*) FILTER (
        WHERE f.is_default IS NOT NULL
    ) AS applications_with_known_status,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE f.is_default = TRUE
        ) / NULLIF(
            COUNT(*) FILTER (
                WHERE f.is_default IS NOT NULL
            ),
            0
        ),
        2
    ) AS default_rate_pct
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_property p
    ON f.property_id = p.property_id
GROUP BY
    p.region
ORDER BY
    default_rate_pct DESC NULLS LAST;

