-- Opportunity vs barrier matrix.
-- Creates a segment-level view for comparing market attractiveness,
-- adoption difficulty, and expected pipeline value.

WITH adoption_barriers AS (
    SELECT
        s.segment_id,
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
),

matrix AS (
    SELECT
        mps.priority_rank,
        mps.segment_name,
        mps.industry_group,
        mps.attractiveness_score,
        ab.adoption_barrier_score,
        mps.expected_pipeline_value_eur,
        mps.opportunity_count,
        CASE
            WHEN mps.attractiveness_score >= 6.75
             AND ab.adoption_barrier_score < 6.50
            THEN 'Quick win'

            WHEN mps.attractiveness_score >= 6.75
             AND ab.adoption_barrier_score >= 6.50
            THEN 'Strategic bet'

            WHEN mps.attractiveness_score < 6.75
             AND ab.adoption_barrier_score < 6.50
            THEN 'Selective opportunity'

            ELSE 'Deprioritize'
        END AS opportunity_barrier_quadrant
    FROM market_prioritization_scores mps
    LEFT JOIN adoption_barriers ab
        ON mps.segment_name = ab.segment_name
)

SELECT
    priority_rank,
    segment_name,
    industry_group,
    attractiveness_score,
    adoption_barrier_score,
    expected_pipeline_value_eur,
    opportunity_count,
    opportunity_barrier_quadrant
FROM matrix
ORDER BY attractiveness_score DESC;
