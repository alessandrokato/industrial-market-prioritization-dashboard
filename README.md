# Industrial Additive Manufacturing Market Prioritization Dashboard

> Synthetic data note: this project uses dummy data created for portfolio purposes. The rankings are illustrative and should not be interpreted as real market recommendations or proprietary company analysis.

## Project overview

This project builds a small decision-support workflow for comparing industrial additive manufacturing market segments.

The goal is to take several commercial and operational signals, turn them into a transparent prioritization score, and visualize the output in Power BI.

![Dashboard overview](screenshots/dashboard_overview.png)

## Business problem

Industrial additive manufacturing companies can pursue many possible markets, including aerospace, defence, mining, energy, maritime, and industrial machinery.

The challenge is not only finding attractive markets, but comparing them consistently. A segment may look attractive because of market size, but still be difficult to enter because of regulation, procurement complexity, low accessibility, or limited commercial evidence.

This project asks:

**Which market segments should receive commercial focus first?**

## Tools used

- SQL
- Power BI
- GitHub
- CSV-based synthetic data
- Weighted scoring model

## What I focused on

- Structuring a market prioritization problem into clear scoring criteria
- Joining multiple input tables into a final scored output
- Using SQL to calculate rankings and run additional business checks
- Building a Power BI dashboard that supports commercial decision-making
- Documenting the workflow clearly enough for someone else to inspect it

## Data structure

The project uses four synthetic input datasets:

| File | Purpose |
|---|---|
| `segments.csv` | Defines the market segments and industry groups |
| `market_indicators.csv` | Contains market size, growth, margin, competition, and regulatory scores |
| `scoring_inputs.csv` | Contains strategic fit, customer pain, sales accessibility, case evidence, and feasibility scores |
| `opportunities.csv` | Contains dummy commercial pipeline opportunities by segment |

## Scoring model

The SQL model combines market and commercial criteria into one attractiveness score.

The score includes:

- Market size
- Growth potential
- Margin potential
- Competitive intensity
- Regulatory barriers
- Strategic fit
- Customer pain
- Sales accessibility
- Case evidence
- Implementation feasibility
- Expected pipeline value

The final output ranks segments from highest to lowest priority.

## Key observations from the dummy scenario

In this synthetic scenario, the highest-ranked segments are:

1. Aerospace MRO
2. Mining Equipment
3. Defence Sustainment

These segments rank highest because they combine strong strategic fit, visible customer pain, and attractive expected pipeline value.

The model should not be read as a final answer. It is a structured way to compare options, surface trade-offs, and support commercial prioritization discussions.

## Repository structure

```text
industrial-market-prioritization-dashboard/
+-- data/
¦   +-- raw/
¦   +-- processed/
+-- powerbi/
+-- screenshots/
+-- sql/
+-- .gitignore
+-- README.md
```

## Files

| Path | Description |
|---|---|
| `sql/01_market_scoring_model.sql` | SQL model used to calculate the segment attractiveness ranking |
| `sql/02_business_analysis_queries.sql` | Additional SQL queries answering business questions from the scored output |
| `sql/03_data_quality_checks.sql` | SQL checks for duplicates, missing values, invalid scores, orphan records, and output completeness |
| `data/processed/market_prioritization_scores.csv` | Final processed output used in Power BI |
| `powerbi/market_prioritization_dashboard.pbix` | Power BI dashboard file |
| `screenshots/dashboard_overview.png` | Dashboard screenshot |

## Limitations

This is a non-confidential portfolio project using synthetic data.

The scoring logic is simplified and designed to demonstrate the workflow, not to produce real market recommendations. In a real setting, the model would need stronger source validation, stakeholder weighting, sensitivity testing, and external market evidence.
