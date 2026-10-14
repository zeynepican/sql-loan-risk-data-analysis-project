
/*
===============================================================================
REPORT: BORROWER PROFILE REPORT
===============================================================================

Purpose:
    Provides a consolidated profile-level report with application volume,
    loan amounts, and default performance.

Grain:
    One row per customer_id.

Metrics:
    - Total applications
    - Applications with known default status
    - Defaulted applications
    - Default rate (%)
    - Total loan amount
    - Average loan amount
    - Distinct credit profiles
    - Distinct loans


===============================================================================
*/

-- ============================================================================
-- 1. CREATE BORROWER PROFILE REPORT
-- ============================================================================

CREATE VIEW gold_analytics.report_borrower_profile AS

WITH application_metrics AS (
    SELECT
        f.customer_id,

        -- Application volume
        COUNT(*) AS total_applications,

        -- Default performance
        COUNT(*) FILTER (
            WHERE f.is_default IS NOT NULL
        ) AS applications_with_known_status,

        COUNT(*) FILTER (
            WHERE f.is_default = TRUE
        ) AS defaulted_applications,

        -- Loan amount metrics
        SUM(f.loan_amount) AS total_loan_amount,

        ROUND(
            AVG(f.loan_amount),
            2
        ) AS avg_loan_amount,

        -- Profile and loan diversity
        COUNT(DISTINCT f.credit_profile_id)
            AS distinct_credit_profiles,

        COUNT(DISTINCT f.loan_id)
            AS distinct_loans

    FROM gold_analytics.fact_loan_application AS f

    GROUP BY
        f.customer_id
)

SELECT
    am.customer_id,

    -- Borrower profile attributes
    c.gender,
    c.age,
    c.co_applicant_credit_type,
    c.income_segment,

    -- Application metrics
    am.total_applications,
    am.applications_with_known_status,
    am.defaulted_applications,

    -- Default rate (%)
    ROUND(
        100.0 * am.defaulted_applications
        / NULLIF(am.applications_with_known_status, 0),
        2
    ) AS default_rate_pct,

    -- Loan amount metrics
    am.total_loan_amount,
    am.avg_loan_amount,

    -- Profile and loan diversity
    am.distinct_credit_profiles,
    am.distinct_loans

FROM application_metrics AS am

LEFT JOIN gold_analytics.dim_customer AS c
    ON am.customer_id = c.customer_id;


-- ============================================================================
-- 2. DISPLAY THE REPORT
-- ============================================================================

SELECT *
FROM gold_analytics.report_borrower_profile
ORDER BY total_applications DESC;



