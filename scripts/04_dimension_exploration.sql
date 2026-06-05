/*
====================================================
DIMENSIONS EXPLORATION
====================================================

Purpose:
This script explores categorical and low-cardinality
features across the analytics layer.

It also documents business definitions of encoded
values to ensure correct interpretation during analysis.

====================================================
*/


-- ============================================
-- CUSTOMER DIMENSION EXPLORATION
-- ============================================

-- Age distribution (customer demographic segmentation)
SELECT DISTINCT age
FROM gold_analytics.dim_customer
ORDER BY age;

-- Gender classification
-- NOTE:
-- gender represents joint application status:
-- 'joint' = two applicants (co-borrower present)
-- 'single' = single applicant
SELECT DISTINCT gender
FROM gold_analytics.dim_customer
ORDER BY gender;

-- Co-applicant credit type segmentation
SELECT DISTINCT co_applicant_credit_type
FROM gold_analytics.dim_customer
ORDER BY co_applicant_credit_type;

-- Income segmentation
-- NOTE:
-- Derived feature based on income ranges:
-- low_income    : income < 3000
-- middle_income : 3000 <= income <= 70000
-- high_income   : income > 70000
SELECT DISTINCT income_segment
FROM gold_analytics.dim_customer
ORDER BY income_segment;


-- ============================================
-- LOAN DIMENSION EXPLORATION
-- ============================================

-- Loan limit categories
SELECT DISTINCT loan_limit
FROM gold_analytics.dim_loan
ORDER BY loan_limit;

-- Loan type classification
SELECT DISTINCT loan_type
FROM gold_analytics.dim_loan
ORDER BY loan_type;

-- Loan purpose segmentation
SELECT DISTINCT loan_purpose
FROM gold_analytics.dim_loan
ORDER BY loan_purpose;

-- Business vs commercial classification
SELECT DISTINCT business_or_commercial
FROM gold_analytics.dim_loan
ORDER BY business_or_commercial;

-- Credit worthiness classification
SELECT DISTINCT credit_worthiness
FROM gold_analytics.dim_loan
ORDER BY credit_worthiness;

-- Open credit indicator
SELECT DISTINCT open_credit
FROM gold_analytics.dim_loan
ORDER BY open_credit;

-- Security type classification
SELECT DISTINCT security_type
FROM gold_analytics.dim_loan
ORDER BY security_type;


-- ============================================
-- PROPERTY DIMENSION EXPLORATION
-- ============================================

-- Construction type categories
SELECT DISTINCT construction_type
FROM gold_analytics.dim_property
ORDER BY construction_type;

-- Occupancy type segmentation
SELECT DISTINCT occupancy_type
FROM gold_analytics.dim_property
ORDER BY occupancy_type;

-- Secured by classification
SELECT DISTINCT secured_by
FROM gold_analytics.dim_property
ORDER BY secured_by;

-- Total unit categories
SELECT DISTINCT total_units
FROM gold_analytics.dim_property
ORDER BY total_units;

-- Geographic region segmentation
SELECT DISTINCT region
FROM gold_analytics.dim_property
ORDER BY region;


-- ============================================
-- CREDIT PROFILE DIMENSION EXPLORATION
-- ============================================

-- Credit type classification
SELECT DISTINCT credit_type
FROM gold_analytics.dim_credit_profile
ORDER BY credit_type;

-- Approval in advance indicator
SELECT DISTINCT approval_in_advance
FROM gold_analytics.dim_credit_profile
ORDER BY approval_in_advance;

-- Application submission type
SELECT DISTINCT submission_of_application
FROM gold_analytics.dim_credit_profile
ORDER BY submission_of_application;


-- ============================================
-- APPLICATION DIMENSION EXPLORATION
-- ============================================

-- Negative amortization indicator
-- NOTE:
-- TRUE  = risky financial structure
-- FALSE = normal amortization structure
SELECT DISTINCT neg_amortization
FROM gold_analytics.dim_application
ORDER BY neg_amortization;

-- Interest-only loan indicator
-- NOTE:
-- TRUE  = interest-only loan (higher risk)
-- FALSE = standard amortized loan
SELECT DISTINCT is_interest_only
FROM gold_analytics.dim_application
ORDER BY is_interest_only;

-- Lump sum payment indicator
-- NOTE:
-- TRUE  = lump sum repayment structure
-- FALSE = regular installment-based repayment
SELECT DISTINCT is_lump_sum_payment
FROM gold_analytics.dim_application
ORDER BY is_lump_sum_payment;


-- ============================================
-- FACT TABLE EXPLORATION (LOW CARDINALITY)
-- ============================================

-- Debt burden segmentation
SELECT DISTINCT debt_burden_segment
FROM gold_analytics.fact_loan_application
ORDER BY debt_burden_segment;

-- Target variable (loan default status)
-- NOTE:
-- TRUE  = loan defaulted (bad outcome)
-- FALSE = loan fully performing (good outcome)
SELECT DISTINCT is_default
FROM gold_analytics.fact_loan_application
ORDER BY is_default;


