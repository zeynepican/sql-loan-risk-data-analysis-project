
/*
===============================================================================
DATA SEGMENTATION ANALYSIS
===============================================================================

Purpose:
    Segment loan applications based on borrower characteristics, loan amounts,
    and debt burden to identify differences in portfolio composition and
    default risk across distinct groups.

Key Metrics:
    - Total Applications
    - Defaulted Applications
    - Applications with Known Default Status
    - Default Rate (%)
    - Loan Amount Range

Data Sources:
    - gold_analytics.fact_loan_application
    - gold_analytics.dim_customer
    - gold_analytics.dim_credit_profile

Methodology:
    1. Combine income and credit score segments to examine default risk across
       multiple dimensions simultaneously.
    2. Divide applications into four loan amount quartiles using NTILE(4).
    3. Compare default rates across existing debt burden segments.

    Default rate is calculated using applications with a known default status
    as the denominator. Applications with a NULL default status are excluded
    from this calculation.

    Loan amount quartiles are data-driven groups based on the distribution of
    non-NULL loan amounts. Quartiles may contain slightly different numbers
    of applications when ties occur.

    The analysis identifies associations and patterns in the dataset; it does
    not establish causal relationships.

===============================================================================
*/


/*
===============================================================================
1. INCOME AND CREDIT SCORE SEGMENTATION
===============================================================================

Business Question:
    How do default rates vary across income and credit score segments?

Analysis:
    Combine borrower income segments with credit score segments to identify
    groups with different default rates.

===============================================================================
*/

SELECT
    c.income_segment,
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
LEFT JOIN gold_analytics.dim_customer c
    ON f.customer_id = c.customer_id
LEFT JOIN gold_analytics.dim_credit_profile cp
    ON f.credit_profile_id = cp.credit_profile_id
GROUP BY
    c.income_segment,
    cp.credit_score_segment
ORDER BY
    default_rate_pct DESC NULLS LAST;


/*
===============================================================================
2. LOAN AMOUNT QUARTILE SEGMENTATION
===============================================================================

Business Question:
    How does default performance vary across loan amount ranges?

Analysis:
    Divide applications with known loan amounts into four quartiles.
    Compare the default rate and loan amount range within each quartile.

    Quartile 1 contains the lowest loan amounts, while Quartile 4 contains
    the highest loan amounts.

===============================================================================
*/

WITH loan_amount_segments AS (
    SELECT
        f.is_default,
        f.loan_amount,
        NTILE(4) OVER (
            ORDER BY f.loan_amount ASC
        ) AS loan_amount_quartile
    FROM gold_analytics.fact_loan_application f
    WHERE f.loan_amount IS NOT NULL
)

SELECT
    loan_amount_quartile,
    COUNT(*) AS total_applications,
    MIN(loan_amount) AS min_loan_amount,
    MAX(loan_amount) AS max_loan_amount,
    COUNT(*) FILTER (
        WHERE is_default = TRUE
    ) AS defaulted_applications,
    COUNT(*) FILTER (
        WHERE is_default IS NOT NULL
    ) AS applications_with_known_status,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE is_default = TRUE
        ) / NULLIF(
            COUNT(*) FILTER (
                WHERE is_default IS NOT NULL
            ),
            0
        ),
        2
    ) AS default_rate_pct
FROM loan_amount_segments
GROUP BY
    loan_amount_quartile
ORDER BY
    loan_amount_quartile;


/*
===============================================================================
3. DEBT BURDEN SEGMENTATION
===============================================================================

Business Question:
    How do debt burden segments differ in loan default risk?

Analysis:
    Compare application counts and default rates across the existing debt
    burden segments to examine whether observed default performance differs
    according to borrower debt burden.

===============================================================================
*/

SELECT
    f.debt_burden_segment,
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
GROUP BY
    f.debt_burden_segment
ORDER BY
    default_rate_pct DESC NULLS LAST;

