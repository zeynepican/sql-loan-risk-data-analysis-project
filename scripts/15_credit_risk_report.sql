/*
===============================================================================
REPORT: CREDIT RISK SUMMARY REPORT
===============================================================================

Purpose:
    Summarizes credit risk indicators and default performance by credit
    score segment and credit type.


Metrics:
    - Total applications
    - Applications with known default status
    - Defaulted applications
    - Default rate (%)
    - Average credit score segment distribution is not calculated because
      credit_score_segment is categorical.
    - Application share (%)
    - Average loan amount

Dimensions:
    - Credit score segment
    - Credit type
    - Approval in advance
    - Submission of application

Notes:
    Default rate is calculated only from applications with a known
    default status.

===============================================================================
*/

-- ============================================================================
-- 1. CREATE CREDIT RISK SUMMARY REPORT
-- ============================================================================

DROP VIEW IF EXISTS gold_analytics.report_credit_risk_summary;

CREATE VIEW gold_analytics.report_credit_risk_summary AS

WITH risk_metrics AS (
    SELECT
        cp.credit_score_segment,
        cp.credit_type,
        cp.approval_in_advance,
        cp.submission_of_application,

        COUNT(*) AS total_applications,

        COUNT(*) FILTER (
            WHERE f.is_default IS NOT NULL
        ) AS applications_with_known_status,

        COUNT(*) FILTER (
            WHERE f.is_default = TRUE
        ) AS defaulted_applications,

        ROUND(
            AVG(f.loan_amount),
            2
        ) AS avg_loan_amount

    FROM gold_analytics.fact_loan_application AS f

    LEFT JOIN gold_analytics.dim_credit_profile AS cp
        ON f.credit_profile_id = cp.credit_profile_id

    GROUP BY
        cp.credit_score_segment,
        cp.credit_type,
        cp.approval_in_advance,
        cp.submission_of_application
)

SELECT
    credit_score_segment,
    credit_type,
    approval_in_advance,
    submission_of_application,

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

    avg_loan_amount

FROM risk_metrics;


-- ============================================================================
-- 2. DISPLAY THE REPORT
-- ============================================================================

SELECT *
FROM gold_analytics.report_credit_risk_summary
ORDER BY
    credit_score_segment,
    total_applications DESC;







