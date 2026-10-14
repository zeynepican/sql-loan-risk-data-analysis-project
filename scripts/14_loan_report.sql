/*
===============================================================================
REPORT: LOAN PORTFOLIO REPORT
===============================================================================

Purpose:
    Summarizes loan portfolio volume, loan amounts, and default performance
    by loan type.


Metrics:
    - Total applications
    - Applications with known default status
    - Defaulted applications
    - Default rate (%)
    - Application share (%)
    - Default share (%)
    - Total loan amount
    - Average loan amount

===============================================================================
*/

-- ============================================================================
-- 1. CREATE LOAN PORTFOLIO REPORT
-- ============================================================================

DROP VIEW IF EXISTS gold_analytics.report_loan_portfolio;

CREATE VIEW gold_analytics.report_loan_portfolio AS

WITH loan_type_metrics AS (
    SELECT
        l.loan_type,

        COUNT(*) AS total_applications,

        COUNT(*) FILTER (
            WHERE f.is_default IS NOT NULL
        ) AS applications_with_known_status,

        COUNT(*) FILTER (
            WHERE f.is_default = TRUE
        ) AS defaulted_applications,

        SUM(f.loan_amount) AS total_loan_amount,

        ROUND(
            AVG(f.loan_amount),
            2
        ) AS avg_loan_amount

    FROM gold_analytics.fact_loan_application AS f

    LEFT JOIN gold_analytics.dim_loan AS l
        ON f.loan_id = l.loan_id

    GROUP BY
        l.loan_type
)

SELECT
    loan_type,
    total_applications,
    applications_with_known_status,
    defaulted_applications,

    ROUND(
        100.0 * defaulted_applications
        / NULLIF(applications_with_known_status, 0),
        2
    ) AS default_rate_pct,

    ROUND(
        100.0 * total_applications
        / NULLIF(SUM(total_applications) OVER (), 0),
        2
    ) AS application_share_pct,

    ROUND(
        100.0 * defaulted_applications
        / NULLIF(SUM(defaulted_applications) OVER (), 0),
        2
    ) AS default_share_pct,

    total_loan_amount,
    avg_loan_amount

FROM loan_type_metrics;


-- ============================================================================
-- 2. DISPLAY THE REPORT
-- ============================================================================

SELECT *
FROM gold_analytics.report_loan_portfolio
ORDER BY total_applications DESC;

