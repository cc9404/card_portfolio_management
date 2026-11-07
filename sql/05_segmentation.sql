-- 05 Customer segmentation for portfolio strategy
-- Rule-based segments, assigned in priority order so each account falls into exactly one segment:
--   1. Fading:           3+ inactive months OR Q1 spend below 0.5x Q4
--   2. Under-using:      utilization under 10%
--   3. Engaged multi:    4+ products held
--   4. Core low-product: 1-3 products held, active and using the card
-- Attrition is measured on all accounts in the segment (attrited and existing).

WITH seg AS (
    SELECT *,
        CASE
            WHEN Months_Inactive_12_mon >= 3 OR Total_Amt_Chng_Q4_Q1 < 0.5 THEN '1. Fading'
            WHEN Avg_Utilization_Ratio < 0.10 THEN '2. Under-using'
            WHEN Total_Relationship_Count >= 4 THEN '3. Engaged multi-product'
            ELSE '4. Core low-product'
        END AS segment
    FROM bankchurners
)
SELECT
    segment,
    COUNT(*) AS accounts,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM bankchurners), 1) AS pct_of_accounts,
    ROUND(100.0 * AVG(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1.0 ELSE 0.0 END), 1) AS attrition_rate_pct,
    ROUND(AVG(Total_Trans_Amt), 0) AS avg_spend_12m,
    ROUND(AVG(Credit_Limit), 0) AS avg_credit_limit,
    ROUND(AVG(Avg_Utilization_Ratio), 3) AS avg_utilization,
    ROUND(AVG(Total_Relationship_Count), 2) AS avg_products_held,
    SUM(CASE WHEN Card_Category = 'Blue' THEN 1 ELSE 0 END) AS blue_accounts
FROM seg
GROUP BY segment
ORDER BY segment;
