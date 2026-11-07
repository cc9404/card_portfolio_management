# Card Portfolio Management: Diagnostic and Opportunity Assessment

A SQL-first portfolio diagnostic for a credit card portfolio: portfolio health by card tier, segment mix, product penetration and attrition, and an opportunity assessment that sizes the issuer actions.

> **Data note.** The analysis uses the public *BankChurners* dataset (Kaggle), a synthetic sample of 10,127 credit card accounts. It is not real issuer data. The dataset has no delinquency, loss, or P&L fields, so this project makes no credit-risk or profitability claims. It works with spend, utilization, tenure, product count, inactivity, and attrition.

---

## Business problem

Card portfolio managers have to keep product lines healthy, decide which segments to grow, and decide where retention spend will pay off. This project asks three questions:

1. **Health:** How do the card tiers compare on accounts, spend, utilization, and inactivity?
2. **Drivers:** Which customer behaviours go with attrition: products held, inactivity, and spend momentum?
3. **Opportunity:** Which issuer actions are worth the most, and how large is each one?

---

## Method

| Module | File | Question | Core SQL |
|---|---|---|---|
| 1 | [`sql/01_portfolio_health_kpis.sql`](sql/01_portfolio_health_kpis.sql) | How healthy is each card tier? | `GROUP BY` tier, conditional aggregation |
| 2 | [`sql/02_tier_and_segment_mix.sql`](sql/02_tier_and_segment_mix.sql) | Where is the portfolio concentrated, and where is credit unused? | `CASE` banding, `NTILE(4)` on credit limit |
| 3 | [`sql/03_penetration_and_attrition.sql`](sql/03_penetration_and_attrition.sql) | Do products held, inactivity, and spend momentum predict attrition? | Banding, rate by group |
| 4 | [`sql/04_opportunity_assessment.sql`](sql/04_opportunity_assessment.sql) | Which actions are worth the most? | CTEs, `UNION ALL`, baseline comparison |

**Sizing method (module 4).** For each segment:

- excess attrited accounts = segment accounts × (segment attrition rate − portfolio attrition rate)
- estimated spend at risk = excess attrited accounts × segment average 12-month spend

These are directional estimates. The segments overlap, so the three figures must not be added together.

---

## Key findings

*All figures are from the output files in [`outputs/`](outputs/).*

**1. Portfolio health (module 1)**
- Blue accounts are 93.2% of the base. Silver, Gold, and Platinum together are 6.8%, and they carry much higher credit limits (about $25K to $30K against $7.4K for Blue).
- Attrition is 16.1% overall. Platinum shows the highest rate (25.0%), but on only 20 accounts.
- 75% to 85% of accounts in every tier carry a revolving balance.

**2. Segment mix (module 2)**
- Accounts with utilization under 10% attrite at 25% to 30% in every tenure band, against roughly 8% to 10% for accounts that use 10% or more of their limit.
- Low utilization, not high limit, is the warning sign. Top-quartile credit limits with under 10% utilization attrite at about 16%, close to the base rate.

**3. Penetration and attrition (module 3)**
- Attrition falls as products held rise: 27.8% with two products, 11.8% with four, and 10.5% with six.
- Inactivity is a strong early signal: 4.5% attrition at one inactive month, 21.5% at three, and 29.9% at four.
- A sharp spend drop in Q1 (below 0.5× the Q4 level) goes with 41.6% attrition, against about 14% in the other bands.

**4. Opportunity assessment (module 4)**

| Opportunity | Accounts | Attrition | Avg 12m spend | Excess attrited accounts | Est. spend at risk |
|---|---|---|---|---|---|
| B. Spend stimulation (utilization under 10%) | 4,030 | 26.5% | $4,511 | 421 | about $1.9M |
| A. Activation (inactive 3+ months) | 4,583 | 22.0% | $4,283 | 271 | about $1.2M |
| C. Retention (spend down below 0.5× in Q1) | 729 | 41.6% | $2,376 | 186 | about $0.4M |

These overlap, so the total is not the sum. The largest single pool is B, low-utilization accounts, and it is the first action to test.

---

## Recommended issuer actions

1. **Utilization stimulation.** Target accounts using under 10% of their limit with category-based offers, and track utilization monthly.
2. **Inactivity early warning.** Trigger a reactivation sequence at two inactive months, before attrition rises steeply at three.
3. **Spend-drop retention.** Flag accounts whose Q1 spend falls below half the Q4 level for a high-touch retention offer.
4. **Product depth.** Test a second-product offer for accounts holding one or two products, where attrition is highest.

Each action should be validated with a holdout test before it is scaled.

---

## Limitations

- Public synthetic data, not a real issuer portfolio.
- No delinquency, loss, or margin data, so no profitability or credit-risk claims.
- Observational associations, not causal effects. Low utilization and attrition may share a cause.
- Sizing assumes the segment would match the base attrition rate after an intervention, which is a simplification.

---

## Repository structure

```
card_portfolio_management/
├── README.md
├── data/
│   └── BankChurners.csv            # public dataset (Kaggle)
├── sql/
│   ├── 01_portfolio_health_kpis.sql
│   ├── 02_tier_and_segment_mix.sql
│   ├── 03_penetration_and_attrition.sql
│   └── 04_opportunity_assessment.sql
└── outputs/
    ├── 01_portfolio_health_kpis.csv
    ├── 02_tier_and_segment_mix_1.csv
    ├── 02_tier_and_segment_mix_2.csv
    ├── 03_penetration_and_attrition_1.csv
    ├── 03_penetration_and_attrition_2.csv
    ├── 03_penetration_and_attrition_3.csv
    └── 04_opportunity_assessment.csv
```

## How to run

1. Import `data/BankChurners.csv` into a table named `bankchurners`. Drop the two `Naive_Bayes_Classifier_*` columns, which are leakage columns in the public file.
2. Run each file in `sql/` in order. The queries use standard SQL (`CASE`, `NTILE`, window functions, CTEs), so they run on MySQL 8.0 or PostgreSQL. They were checked on SQLite.
3. Compare results with the CSVs in [`outputs/`](outputs/).
