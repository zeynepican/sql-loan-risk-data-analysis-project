/*
====================================================
PORTFOLIO CUMULATIVE ANALYSIS
====================================================

Purpose:
This analysis evaluates how loan volume is distributed
across key business segments using cumulative totals.

Segments are ordered by total loan amount to observe
how the portfolio accumulates across groups.

This helps identify:
- Which segments contribute most to total volume
- How quickly total portfolio accumulates
- Whether distribution is balanced or concentrated

====================================================
*/


/*
Business Question:
How does loan volume accumulate across income segments?

Business Insight:
This analysis shows how total loan volume is distributed
across income groups and how much each group contributes
to the overall portfolio when ordered by size.

Result Findings:
The middle_income segment contributes the largest share
of total loan volume (~4.59B). When combined with the
low_income segment, cumulative volume reaches almost
the entire portfolio (~99%+). The high_income segment
has a much smaller total contribution compared to the other groups.
*/

SELECT 
    c.income_segment,
    SUM(f.loan_amount) AS segment_loan,
    SUM(SUM(f.loan_amount)) OVER (ORDER BY SUM(f.loan_amount) DESC) AS cumulative_loan
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY c.income_segment;


/*
Business Question:
How does credit exposure accumulate across risk segments?

Business Insight:
This analysis evaluates how loan exposure is distributed
across credit risk categories.

Result Findings:
The low_risk segment represents the largest portion of
total exposure (~1.86B). When combined with medium_risk,
the cumulative share reaches around 75% of the portfolio.
The high_risk segment contributes the remaining portion
at a lower scale compared to the other segments.
*/

SELECT 
    cp.credit_score_segment,
    SUM(f.loan_amount) AS exposure,
    SUM(SUM(f.loan_amount)) OVER (ORDER BY SUM(f.loan_amount) DESC) AS cumulative_exposure
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_credit_profile cp
    ON f.credit_profile_id = cp.credit_profile_id
GROUP BY cp.credit_score_segment;


/*
Business Question:
How is loan volume distributed across geographic regions?

Business Insight:
This analysis shows how loan activity is distributed
across regions and how cumulative volume builds up.

Result Findings:
The north region has the highest total loan volume
(~2.46B), followed by the south region (~2.13B).
Together, these two regions represent the majority
of the total portfolio volume.
*/

SELECT 
    p.region,
    SUM(f.loan_amount) AS region_volume,
    SUM(SUM(f.loan_amount)) OVER (ORDER BY SUM(f.loan_amount) DESC) AS cumulative_volume
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_property p
    ON f.property_id = p.property_id
GROUP BY p.region;


/*
Business Question:
How is loan volume distributed across loan types?

Business Insight:
This analysis evaluates how different loan products
contribute to the overall portfolio size.

Result Findings:
The type1 loan product accounts for the largest share
(~3.88B), representing most of the total portfolio.
Type2 follows with a smaller but still significant share,
while type3 contributes the least volume.
*/

SELECT 
    l.loan_type,
    SUM(f.loan_amount) AS type_volume,
    SUM(SUM(f.loan_amount)) OVER (ORDER BY SUM(f.loan_amount) DESC) AS cumulative_volume
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_loan l
    ON f.loan_id = l.loan_id
GROUP BY l.loan_type;
