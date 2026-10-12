
/*
===============================================================================
PART-TO-WHOLE ANALYSIS
===============================================================================

Purpose:
    Analyze the composition of the loan portfolio by measuring the share of
    total applications and total defaults attributable to each loan type.

Key Metrics:
    - Total Applications
    - Application Share (%)
    - Defaulted Applications
    - Share of Total Defaults (%)

Data Sources:
    - gold_analytics.fact_loan_application
    - gold_analytics.dim_loan

Methodology:
    1. Calculate each loan type's share of all loan applications.
    2. Calculate each loan type's share of all applications marked as defaults.

    Application share is calculated using all applications in the fact table
    as the denominator.

    Default share is calculated using all applications marked as defaults
    (is_default = TRUE) as the denominator.

    Applications with a NULL default status are included in the application
    share but excluded from the default share.

    Percentages describe portfolio composition and do not establish causal
    relationships.

===============================================================================
*/


/*
===============================================================================
1. APPLICATION SHARE BY LOAN TYPE
===============================================================================

Business Question:
    What proportion of total loan applications does each loan type represent?

Analysis:
    Calculate the percentage of all loan applications associated with each
    loan type to understand the composition of the loan portfolio.

===============================================================================
*/

WITH loan_type_applications AS (
    SELECT
        l.loan_type,
        COUNT(*) AS total_applications
    FROM gold_analytics.fact_loan_application f
    LEFT JOIN gold_analytics.dim_loan l
        ON f.loan_id = l.loan_id
    GROUP BY
        l.loan_type
)

SELECT
    loan_type,
    total_applications,
    ROUND(
        100.0 * total_applications
        / NULLIF(SUM(total_applications) OVER (), 0),
        2
    ) AS application_share_pct
FROM loan_type_applications
ORDER BY
    application_share_pct DESC NULLS LAST;


/*
===============================================================================
2. DEFAULT SHARE BY LOAN TYPE
===============================================================================

Business Question:
    What proportion of total loan defaults comes from each loan type?

Analysis:
    Calculate each loan type's share of all applications marked as defaults.
    Compare the distribution of defaults across loan types to understand
    which categories contribute most to the total number of defaults.

===============================================================================
*/

WITH loan_type_defaults AS (
    SELECT
        l.loan_type,
        COUNT(*) FILTER (
            WHERE f.is_default = TRUE
        ) AS defaulted_applications
    FROM gold_analytics.fact_loan_application f
    LEFT JOIN gold_analytics.dim_loan l
        ON f.loan_id = l.loan_id
    GROUP BY
        l.loan_type
)

SELECT
    loan_type,
    defaulted_applications,
    ROUND(
        100.0 * defaulted_applications
        / NULLIF(SUM(defaulted_applications) OVER (), 0),
        2
    ) AS default_share_pct
FROM loan_type_defaults
ORDER BY
    default_share_pct DESC NULLS LAST;


