
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
Interest rates show minimal variation across credit score segments in this dataset.
The near-zero correlation between credit score and interest rate in the Bronze
and Silver layers suggests that this pattern is already present in the source data.

However, missing interest rates were imputed using averages grouped by loan type
and credit type in the Gold staging layer. Since some groups have very high
missing-value rates, this approach may reduce the observed variability in interest rates.

Therefore, the results do not establish that credit risk has no effect on loan pricing.
They indicate that no meaningful differences in average interest rates were observed
across credit score segments in the analyzed data, and the imputation method should
be considered when interpreting these findings.
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

Metric Note:
The debt-to-income metric in this analysis is a logarithmic transformation
of the loan amount divided by final income, rather than the conventional
debt-to-income ratio.

Therefore, its values should be interpreted as a transformed relative measure
of loan size to income, not as a percentage-based DTI ratio.
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
