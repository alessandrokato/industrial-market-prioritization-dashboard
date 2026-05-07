-- Market prioritization scoring model
-- Purpose: rank industrial additive manufacturing market segments
-- based on market attractiveness, strategic fit, adoption barriers,
-- and visible commercial pipeline potential.

WITH pipeline_by_segment AS (
    SELECT
        segment_id,
        COUNT(*) AS opportunity_count,
        SUM(estimated_deal_value_eur) AS total_pipeline_value_eur,
        ROUND(SUM(estimated_deal_value_eur * probability_percent / 100.0), 0) AS expected_pipeline_value_eur
    FROM opportunities
    GROUP BY segment_id
),

scored_segments AS (
    SELECT
        s.segment_id,
        s.segment_name,
        s.industry_group,
        mi.market_size_score,
        mi.growth_score,
        mi.margin_score,
        mi.competitive_intensity_score,
        mi.regulatory_barrier_score,
        si.strategic_fit_score,
        si.customer_pain_score,
        si.sales_accessibility_score,
        si.case_evidence_score,
        si.implementation_feasibility_score,
        COALESCE(p.opportunity_count, 0) AS opportunity_count,
        COALESCE(p.total_pipeline_value_eur, 0) AS total_pipeline_value_eur,
        COALESCE(p.expected_pipeline_value_eur, 0) AS expected_pipeline_value_eur,

        ROUND(
            mi.market_size_score * 0.12 +
            mi.growth_score * 0.10 +
            mi.margin_score * 0.10 +
            (11 - mi.competitive_intensity_score) * 0.05 +
            (11 - mi.regulatory_barrier_score) * 0.05 +
            si.strategic_fit_score * 0.16 +
            si.customer_pain_score * 0.16 +
            si.sales_accessibility_score * 0.10 +
            si.case_evidence_score * 0.08 +
            si.implementation_feasibility_score * 0.08
        , 2) AS attractiveness_score

    FROM segments s
    LEFT JOIN market_indicators mi
        ON s.segment_id = mi.segment_id
    LEFT JOIN scoring_inputs si
        ON s.segment_id = si.segment_id
    LEFT JOIN pipeline_by_segment p
        ON s.segment_id = p.segment_id
)

SELECT
    DENSE_RANK() OVER (
        ORDER BY attractiveness_score DESC, expected_pipeline_value_eur DESC
    ) AS priority_rank,
    segment_name,
    industry_group,
    attractiveness_score,
    CASE
        WHEN attractiveness_score >= 7.50 THEN 'High priority'
        WHEN attractiveness_score >= 6.75 THEN 'Medium-high priority'
        WHEN attractiveness_score >= 6.00 THEN 'Medium priority'
        ELSE 'Low priority'
    END AS priority_tier,
    opportunity_count,
    total_pipeline_value_eur,
    expected_pipeline_value_eur,
    market_size_score,
    growth_score,
    margin_score,
    strategic_fit_score,
    customer_pain_score,
    sales_accessibility_score,
    case_evidence_score,
    implementation_feasibility_score,
    competitive_intensity_score,
    regulatory_barrier_score
FROM scored_segments
ORDER BY priority_rank;
