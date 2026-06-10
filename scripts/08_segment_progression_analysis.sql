/*
====================================================
SEGMENT PROGRESSION ANALYSIS
====================================================

Purpose:
This analysis evaluates how key financial metrics
behave across structured business segments such as
credit risk and income groups.

Instead of assuming directional relationships,
the analysis tests whether meaningful variation
exists between segments.

This helps identify:
- Whether risk segmentation is reflected in pricing
- Whether income levels influence borrowing behavior
- Whether segmentation is behaviorally significant

====================================================
*/
/*
Business Question:
Is credit risk segmentation reflected in loan pricing and loan amount behavior?

Business Insight:
This analysis tests whether interest rates and loan amounts vary meaningfully
across credit score segments.

Rather than assuming risk-based pricing exists, we evaluate whether
segmentation has measurable impact on pricing or exposure.

Key Interpretation:
If differences are minimal, it indicates that pricing is not strongly
driven by credit risk segmentation in this dataset.
*/

SELECT 
    cp.credit_score_segment,
    AVG(f.rate_of_interest) AS avg_interest_rate,
    AVG(f.loan_amount) AS avg_loan_amount
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_credit_profile cp 
    ON f.credit_profile_id = cp.credit_profile_id
GROUP BY cp.credit_score_segment
ORDER BY cp.credit_score_segment;
/*
Business Question:
How do borrowing capacity and debt burden vary across income segments?

Business Insight:
This analysis evaluates whether income segmentation is associated with
differences in loan size and financial stress levels.

It helps determine whether income is a strong predictor of borrowing behavior
in this portfolio.

Key Interpretation:
Stronger income gradients would indicate meaningful segmentation effects.
*/

SELECT 
    c.income_segment,
    AVG(f.loan_amount) AS avg_loan_amount,
    AVG(f.debt_to_income_ratio) AS avg_dti_ratio
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_customer c 
    ON f.customer_id = c.customer_id
GROUP BY c.income_segment
ORDER BY c.income_segment;
