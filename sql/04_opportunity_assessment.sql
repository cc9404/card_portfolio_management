-- 04 Opportunity assessment
-- Question: Which issuer actions are worth the most, and how large is each one?
-- Method: for each segment, compare its attrition rate with the portfolio baseline.
--   excess_attrited_accounts = segment_accounts x (segment_attrition - baseline_attrition)
--   est_spend_at_risk        = excess_attrited_accounts x segment_avg_12m_spend
-- Segments overlap, so the three estimates must NOT be added together.
-- All figures are directional estimates from observed rates, not forecasts.

WITH baseline AS (
    SELECT AVG(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1.0 ELSE 0.0 END) AS base_rate
    FROM bankchurners
),
segments AS (
    SELECT
        'A. Activation: inactive 3+ months' AS opportunity,
        Attrition_Flag, Total_Trans_Amt
    FROM bankchurners
    WHERE Months_Inactive_12_mon >= 3
    UNION ALL
    SELECT 'B. Spend stimulation: utilization under 10%', Attrition_Flag, Total_Trans_Amt
    FROM bankchurners
    WHERE Avg_Utilization_Ratio < 0.10
    UNION ALL
    SELECT 'C. Retention: 12m spend dropped below 0.5x in Q1', Attrition_Flag, Total_Trans_Amt
    FROM bankchurners
    WHERE Total_Amt_Chng_Q4_Q1 < 0.5
),
seg_stats AS (
    SELECT
        opportunity,
        COUNT(*) AS accounts,
        AVG(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1.0 ELSE 0.0 END) AS seg_rate,
        AVG(Total_Trans_Amt) AS avg_spend
    FROM segments
    GROUP BY opportunity
)
SELECT
    s.opportunity,
    s.accounts,
    ROUND(100.0 * s.seg_rate, 1)  AS attrition_rate_pct,
    ROUND(100.0 * b.base_rate, 1) AS baseline_attrition_pct,
    ROUND(s.avg_spend, 0)         AS avg_spend_12m,
    ROUND(s.accounts * (s.seg_rate - b.base_rate), 0)                         AS excess_attrited_accounts,
    ROUND(s.accounts * (s.seg_rate - b.base_rate) * s.avg_spend, 0)           AS est_spend_at_risk
FROM seg_stats s CROSS JOIN baseline b
ORDER BY est_spend_at_risk DESC;
