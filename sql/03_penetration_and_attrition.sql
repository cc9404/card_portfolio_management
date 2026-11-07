-- 03 Product penetration and attrition
-- Question: Do customers with more products, fewer inactive months, or rising spend stay longer?

-- 3a. Products held vs attrition
SELECT
    Total_Relationship_Count AS products_held,
    COUNT(*) AS accounts,
    ROUND(100.0 * SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_rate_pct,
    ROUND(AVG(Total_Trans_Amt), 0) AS avg_spend_12m
FROM bankchurners
GROUP BY Total_Relationship_Count
ORDER BY Total_Relationship_Count;

-- 3b. Months inactive vs attrition
SELECT
    Months_Inactive_12_mon AS months_inactive,
    COUNT(*) AS accounts,
    ROUND(100.0 * SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_rate_pct,
    ROUND(AVG(Total_Trans_Amt), 0) AS avg_spend_12m
FROM bankchurners
GROUP BY Months_Inactive_12_mon
ORDER BY Months_Inactive_12_mon;

-- 3c. Spend momentum (Q4 to Q1 transaction amount change) vs attrition
SELECT
    CASE
        WHEN Total_Amt_Chng_Q4_Q1 < 0.5 THEN 'a. below 0.5x (sharp drop)'
        WHEN Total_Amt_Chng_Q4_Q1 < 0.75 THEN 'b. 0.5x-0.75x'
        WHEN Total_Amt_Chng_Q4_Q1 < 1.0 THEN 'c. 0.75x-1.0x'
        ELSE 'd. 1.0x and above'
    END AS spend_momentum_band,
    COUNT(*) AS accounts,
    ROUND(100.0 * SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_rate_pct
FROM bankchurners
GROUP BY spend_momentum_band
ORDER BY spend_momentum_band;
