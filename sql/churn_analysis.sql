-- ================================================
-- Q1: DATA VALIDATION
-- SaaS Churn Signal System
-- ================================================

-- 1A: Total row count (expect 7043)
SELECT COUNT(*) AS total_customers
FROM telco_churn;

-- 1B: Check nulls in critical columns
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE customerID IS NULL)       AS null_customerID,
    COUNT(*) FILTER (WHERE tenure IS NULL)           AS null_tenure,
    COUNT(*) FILTER (WHERE MonthlyCharges IS NULL)   AS null_monthly_charges,
    COUNT(*) FILTER (WHERE TotalCharges IS NULL)     AS null_total_charges,
    COUNT(*) FILTER (WHERE Churn IS NULL)            AS null_churn
FROM telco_churn;

-- 1C: Preview first 5 rows
SELECT * FROM telco_churn LIMIT 5;

-- ================================================
-- Q2: OVERALL CHURN RATE
-- ================================================

SELECT
    COUNT(*)                                        AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    SUM(CASE WHEN Churn = 'No'  THEN 1 ELSE 0 END) AS active_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2
    )                                               AS churn_rate_pct
FROM telco_churn;

-- ================================================
-- Q3: CHURN BY CONTRACT TYPE
-- ================================================

SELECT
    Contract,
    COUNT(*)                                            AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)     AS churned,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2
    )                                                   AS churn_rate_pct
FROM telco_churn
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- ================================================
-- Q4: REVENUE AT RISK — CHURNED MRR
-- ================================================

SELECT
    SUM(CASE WHEN Churn = 'No'  THEN MonthlyCharges ELSE 0 END)    AS active_mrr,
    SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges ELSE 0 END)     AS churned_mrr,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges ELSE 0 END)
        * 100.0 / SUM(MonthlyCharges), 2
    )                                                               AS pct_mrr_lost
FROM telco_churn;

-- ================================================
-- Q5: CHURN BY TENURE BUCKET
-- ================================================

SELECT
    CASE
        WHEN tenure BETWEEN 0  AND 12 THEN '0-12 months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 months'
        WHEN tenure BETWEEN 49 AND 72 THEN '49-72 months'
    END                                                         AS tenure_bucket,
    COUNT(*)                                                    AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)             AS churned,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2
    )                                                           AS churn_rate_pct
FROM telco_churn
GROUP BY tenure_bucket
ORDER BY churn_rate_pct DESC;

-- ================================================
-- Q6: CHURN BY PAYMENT METHOD
-- ================================================

SELECT
    PaymentMethod,
    COUNT(*)                                            AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)     AS churned,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2
    )                                                   AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2)                       AS avg_monthly_charges
FROM telco_churn
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;