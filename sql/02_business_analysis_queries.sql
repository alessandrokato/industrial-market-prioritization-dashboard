-- Business analysis queries based on the scored output.
-- Run after 01_market_scoring_model.sql has created market_prioritization_scores.

-- 1. Industry groups ranked by expected pipeline value

SELECT
    industry_group,
    COUNT(*) AS segment_count,
    ROUND(AVG(attractiveness_score), 2) AS avg_attractiveness_score,
    SUM(opportunity_count) AS total_opportunities,
    SUM(expected_pipeline_value_eur) AS total_expected_pipeline_value_eur
FROM market_prioritization_scores
GROUP BY industry_group
ORDER BY total_expected_pipeline_value_eur DESC;


-- 2. Attractive segments with limited current pipeline coverage

SELECT
    priority_rank,
    segment_name,
    industry_group,
    attractiveness_score,
    priority_tier,
    opportunity_count,
    expected_pipeline_value_eur
FROM market_prioritization_scores
WHERE attractiveness_score >= 7.00
  AND opportunity_count <= 1
ORDER BY attractiveness_score DESC;


-- 3. Segments with the highest adoption barriers

SELECT
    s.segment_name,
    s.industry_group,
    mi.regulatory_barrier_score,
    mi.competitive_intensity_score,
    si.implementation_feasibility_score,
    ROUND(
        mi.regulatory_barrier_score * 0.40 +
        mi.competitive_intensity_score * 0.30 +
        (11 - si.implementation_feasibility_score) * 0.30
    , 2) AS adoption_barrier_score
FROM segments s
LEFT JOIN market_indicators mi
    ON s.segment_id = mi.segment_id
LEFT JOIN scoring_inputs si
    ON s.segment_id = si.segment_id
ORDER BY adoption_barrier_score DESC;


-- 4. Opportunities ranked by expected value

SELECT
    o.opportunity_id,
    s.segment_name,
    s.industry_group,
    o.company_type,
    o.region,
    o.sales_stage,
    o.estimated_deal_value_eur,
    o.probability_percent,
    ROUND(o.estimated_deal_value_eur * o.probability_percent / 100.0, 0) AS expected_value_eur
FROM opportunities o
LEFT JOIN segments s
    ON o.segment_id = s.segment_id
ORDER BY expected_value_eur DESC;
