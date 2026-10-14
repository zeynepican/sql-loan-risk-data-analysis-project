# SQL Loan Risk Data Analysis Project

## Overview

This project is a continuation of a PostgreSQL data warehouse project focused on loan default risk analysis. It performs SQL-based exploratory data analysis (EDA), advanced analytics, and reporting using the existing Gold-layer data without duplicating the underlying dataset.

The project aims to explore loan portfolio characteristics, identify patterns associated with loan defaults, and transform raw analytical results into structured, business-oriented reports.

## Project Objectives

- Explore the database structure and understand the available data.
- Analyze dimensions, measures, and key business metrics.
- Examine loan applications and default patterns through ranking, magnitude, segmentation, and comparative analyses.
- Investigate relationships between borrower profiles, loan characteristics, property collateral, and default outcomes.
- Create reusable SQL views to support reporting and further analysis.

## Data Source and Environment

- **Database:** PostgreSQL
- **Data source:** Gold-layer tables from the companion loan risk data warehouse project
- **Analytics schema:** `gold_analytics`
- **Approach:** SQL-based analysis using existing warehouse data without duplicating the dataset

## Project Structure

### Exploratory Data Analysis (EDA)

The EDA phase explores the data from different perspectives:

- Database exploration
- Dimension exploration
- Measures exploration
- Magnitude analysis
- Ranking analysis

### Advanced Analytics

The advanced analytics phase focuses on more detailed patterns and comparisons:

- Segment progression analysis
- Cumulative analysis
- Performance analysis
- Part-to-whole analysis
- Data segmentation

### Reporting

The reporting phase consolidates analytical metrics into reusable PostgreSQL views.

| SQL File | Description |
|---|---|
| `13_borrower_profile_report.sql` | Summarizes application volume, default performance, loan amounts, and associated credit profiles by `customer_id`. |
| `14_loan_portfolio_report.sql` | Analyzes application volume, loan amounts, and default performance by loan type. |
| `15_credit_risk_summary_report.sql` | Summarizes default performance by credit score segment, credit type, and application-related categories. |




