/*
====================================================
RANKING ANALYSIS
====================================================

Purpose:
This analysis identifies the highest-performing,
highest-volume, and highest-risk segments within
the loan portfolio using ranking techniques and
window functions.

It compares customer, regional, credit, and product
segments based on:

- Loan volume
- Portfolio exposure
- Credit risk indicators
- Debt burden levels
- Loan term structure
- Income distribution

The goal is to highlight relative performance
differences across segments and support data-driven
portfolio monitoring and segmentation analysis.

====================================================
*/
/*
Business Question:
Which credit score and debt burden segments are associated with higher average loan amounts?

Business Insight:
This analysis compares average loan amounts across credit and debt burden segments.
It helps identify whether certain risk groups are associated with higher lending exposure.

Result Findings:
The results show variation in average loan amounts across segments.
Lower credit score segments tend to have slightly different exposure levels compared to higher credit score groups.
Debt burden segments also show clustering around similar average loan amounts, indicating limited variation across groups.
*/
SELECT 
    cp.credit_score_segment,
    f.debt_burden_segment,
    COUNT(f.fact_loan_id) AS total_loans,
    ROUND(AVG(f.loan_amount), 2) AS avg_loan_amount,
    DENSE_RANK() OVER (ORDER BY AVG(f.loan_amount) DESC) as exposure_rank
FROM gold_analytics.fact_loan_application f
JOIN gold_analytics.dim_credit_profile cp ON f.credit_profile_id = cp.credit_profile_id
GROUP BY cp.credit_score_segment, f.debt_burden_segment
LIMIT 5;

/*
Business Question:
Which customer profile groups contribute the highest total loan portfolio volume?

Business Insight:
This helps identify which combinations of age, income segment, and region contribute most to total lending activity.

Result Findings:
The results indicate that middle_income segments appear frequently among the highest volume profiles.
Certain age groups (especially middle-aged borrowers) are more represented in high-volume segments.
Regional concentration is also visible across a small number of dominant regions.
*/
WITH ProfileVolume AS (
    SELECT 
        c.age,
        c.income_segment,
        p.region,
        SUM(f.loan_amount) AS total_portfolio_amount,
        RANK() OVER (ORDER BY SUM(f.loan_amount) DESC) as volume_rank
    FROM gold_analytics.fact_loan_application f
    LEFT JOIN gold_analytics.dim_customer c ON f.customer_id = c.customer_id
    LEFT JOIN gold_analytics.dim_property p ON f.property_id = p.property_id
    GROUP BY c.age, c.income_segment, p.region
)
SELECT * FROM ProfileVolume WHERE volume_rank <= 5;

/*
Business Question:
How is total loan volume distributed across geographic regions?

Business Insight:
This provides a view of geographic concentration in lending activity and helps assess regional portfolio balance.

Result Findings:
The analysis shows that loan volume is not evenly distributed across regions.
A small number of regions account for a large share of total loan amounts,
while average loan sizes remain relatively stable across regions.
*/
WITH RegionalVolume AS (
    SELECT 
        p.region,
        COUNT(f.fact_loan_id) AS total_applications,                 -- Bölgedeki operasyonel yoğunluk
        SUM(f.loan_amount) AS total_loan_amount,                      -- Bölgenin toplam finansal büyüklüğü
        ROUND(AVG(f.loan_amount), 2) AS avg_loan_amount,              -- Bölge başı ortalama kredi büyüklüğü
        DENSE_RANK() OVER (ORDER BY SUM(f.loan_amount) DESC) as market_share_rank -- Hacim liderliği sıralaması
    FROM gold_analytics.fact_loan_application f
    LEFT JOIN gold_analytics.dim_property p ON f.property_id = p.property_id
    GROUP BY p.region
)
SELECT * FROM RegionalVolume;

/*
Business Question:
How do loan volumes and credit scores vary across credit score segments?

Business Insight:
This analysis helps understand how lending activity is distributed across different risk segments.

Result Findings:
Lower credit score segments show lower average credit scores as expected.
Loan volumes are concentrated more heavily in higher credit score segments,
indicating a more conservative lending distribution toward lower-risk borrowers.
*/
SELECT 
    cp.credit_score_segment,
    COUNT(f.fact_loan_id) AS total_applications,                 -- Risk grubundaki başvuru yoğunluğu
    SUM(f.loan_amount) AS total_loan_amount,                      -- Riske maruz kalan toplam anapara (Exposure)
    ROUND(AVG(f.credit_score), 2) AS avg_credit_score,            -- Segmentin ortalama kredi skoru doğrulaması
    DENSE_RANK() OVER (ORDER BY AVG(f.credit_score) ASC) as risk_severity_rank -- En düşük skordan (en riskli) başlayarak sırala
FROM gold_analytics.fact_loan_application f
LEFT JOIN gold_analytics.dim_credit_profile cp ON f.credit_profile_id = cp.credit_profile_id
WHERE cp.credit_score_segment IS NOT NULL
GROUP BY cp.credit_score_segment;

/*
Business Question:
Which loan product combinations have the longest average repayment terms?

Business Insight:
This helps analyze how long capital is committed across different product categories.

Result Findings:
Some loan type combinations show longer average repayment terms compared to others.
A small number of product groups also account for a significant share of total loan volume,
indicating concentration in specific long-term products.
*/
WITH ProductTerms AS (
    SELECT 
        l.business_or_commercial,
        l.loan_type,
        COUNT(f.fact_loan_id) AS total_applications,
        SUM(f.loan_amount) AS total_loan_amount,                      -- Ürünün toplam portföy büyüklüğü
        ROUND(AVG(f.term), 1) AS avg_term_months,                     -- Ürünün ortalama vadesi (Ay)
        -- En uzun vadeden başlayarak ürün kombinasyonlarını sıralıyoruz
        DENSE_RANK() OVER (ORDER BY AVG(f.term) DESC) as term_length_rank
    FROM gold_analytics.fact_loan_application f
    LEFT JOIN gold_analytics.dim_loan l ON f.loan_id = l.loan_id
    GROUP BY l.business_or_commercial, l.loan_type
)
SELECT * FROM ProductTerms;

/*
Business Question:
Which customer profiles have the highest average debt-to-income ratio within each region?

Business Insight:
This helps identify potential high financial pressure segments across different geographic areas.

Result Findings:
Higher DTI values are observed in certain income segments within each region.
The distribution suggests that debt pressure is not uniform across all customer profiles.
Some age groups appear more frequently in higher DTI segments within specific regions.
*/
WITH RankedProfiles AS (
    SELECT 
        p.region,
        c.age,
        c.income_segment,
        COUNT(f.fact_loan_id) AS total_applications,
        ROUND(AVG(f.debt_to_income_ratio), 2) AS avg_dti,
        -- Her bölgeyi kendi içinde bölüp, DTI oranına göre zirvedekileri sıralıyoruz
        DENSE_RANK() OVER (PARTITION BY p.region ORDER BY AVG(f.debt_to_income_ratio) DESC) AS dti_rank
    FROM gold_analytics.fact_loan_application f
    LEFT JOIN gold_analytics.dim_property p ON f.property_id = p.property_id
    LEFT JOIN gold_analytics.dim_customer c ON f.customer_id = c.customer_id
    WHERE p.region IS NOT NULL AND c.age IS NOT NULL AND c.income_segment IS NOT NULL
    GROUP BY p.region, c.age, c.income_segment
)
SELECT * FROM RankedProfiles 
WHERE dti_rank <= 3; -- Her bölgenin DTI şampiyonu ilk 3 profilini getir (Gerçek Top-N)

/*
Business Question:
What is the distribution of total loan volume across income segments?

Business Insight:
This shows how the loan portfolio is distributed across different income groups and highlights concentration levels.

Result Findings:
Middle income segments account for the largest share of total loan volume.
High income segments show higher average loan sizes per application but lower total volume contribution.
Overall, portfolio distribution is concentrated in the middle income group.
*/
WITH IncomeMarketShare AS (
    SELECT 
        c.income_segment,
        COUNT(f.fact_loan_id) AS total_applications,
        SUM(f.loan_amount) AS total_loan_amount,
        ROUND(AVG(f.loan_amount), 2) AS avg_loan_amount,
        -- Tüm portföyün toplamına oranla pazar payı yüzdesi hesaplama (Window Function)
        ROUND((SUM(f.loan_amount) / SUM(SUM(f.loan_amount)) OVER()) * 100, 2) AS portfolio_share_percent
    FROM gold_analytics.fact_loan_application f
    LEFT JOIN gold_analytics.dim_customer c ON f.customer_id = c.customer_id
    GROUP BY c.income_segment
)
SELECT 
    income_segment,
    total_applications,
    total_loan_amount,
    avg_loan_amount,
    portfolio_share_percent,
    DENSE_RANK() OVER (ORDER BY total_loan_amount DESC) as volume_rank
FROM IncomeMarketShare;
