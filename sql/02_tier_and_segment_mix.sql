-- 02 Tier and segment mix
-- Question: Where is the portfolio concentrated, and which segments hold unused credit?

-- 2a. Tenure band x utilization band, existing accounts only
WITH base AS (
    SELECT
        CASE
            WHEN Months_on_book <= 24 THEN '01: 0-24 months'
            WHEN Months_on_book <= 36 THEN '02: 25-36 months'
            WHEN Months_on_book <= 48 THEN '03: 37-48 months'
            ELSE '04: 49+ months'
        END AS tenure_band,
        CASE
            WHEN Avg_Utilization_Ratio < 0.10 THEN 'a. under 10%'
            WHEN Avg_Utilization_Ratio < 0.50 THEN 'b. 10-50%'
            ELSE 'c. 50%+'
        END AS utilization_band,
        Total_Trans_Amt, Attrition_Flag
    FROM bankchurners
)
SELECT
    tenure_band,
    utilization_band,
    COUNT(*) AS accounts,
    ROUND(100.0 * SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_rate_pct,
    ROUND(AVG(Total_Trans_Amt), 0) AS avg_spend_12m
FROM base
GROUP BY tenure_band, utilization_band
ORDER BY tenure_band, utilization_band;

-- 2b. Unused credit: top-quartile credit limit with under-10% utilization
WITH limits AS (
    SELECT *, NTILE(4) OVER (ORDER BY Credit_Limit) AS limit_quartile
    FROM bankchurners
)
SELECT
    Card_Category,
    COUNT(*) AS accounts,
    ROUND(AVG(Credit_Limit), 0) AS avg_credit_limit,
    ROUND(AVG(Avg_Utilization_Ratio), 3) AS avg_utilization,
    ROUND(AVG(Total_Trans_Amt), 0) AS avg_spend_12m,
    ROUND(100.0 * SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_rate_pct
FROM limits
WHERE limit_quartile = 4 AND Avg_Utilization_Ratio < 0.10
GROUP BY Card_Category
ORDER BY accounts DESC;
