-- 01 Portfolio Health KPIs by card tier
-- Question: How healthy is each card tier on accounts, spend, utilization, and inactivity?
-- Note: the dataset has no delinquency or P&L fields; this module uses spend, utilization and attrition only.

SELECT
    Card_Category,
    COUNT(*)                                                        AS accounts,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM bankchurners), 1) AS pct_of_accounts,
    ROUND(100.0 * SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_rate_pct,
    ROUND(AVG(Total_Trans_Amt), 0)                                  AS avg_spend_12m,
    ROUND(AVG(Total_Trans_Ct), 1)                                   AS avg_transactions_12m,
    ROUND(AVG(Credit_Limit), 0)                                     AS avg_credit_limit,
    ROUND(AVG(Avg_Utilization_Ratio), 3)                            AS avg_utilization,
    ROUND(100.0 * SUM(CASE WHEN Total_Revolving_Bal > 0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_revolving,
    ROUND(100.0 * SUM(CASE WHEN Months_Inactive_12_mon >= 3 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_inactive_3plus_months
FROM bankchurners
GROUP BY Card_Category
ORDER BY accounts DESC;
