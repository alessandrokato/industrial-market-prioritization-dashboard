-- Data quality checks for the source tables and final scored output.
-- Most checks should return no rows. The two summary checks should return PASS.

-- 1. Duplicate segment IDs

SELECT
    segment_id,
    COUNT(*) AS duplicate_count
FROM segments
GROUP BY segment_id
HAVING COUNT(*) > 1;


-- 2. Segments missing market indicator records

SELECT
    s.segment_id,
    s.segment_name
FROM segments s
LEFT JOIN market_indicators mi
    ON s.segment_id = mi.segment_id
WHERE mi.segment_id IS NULL;


-- 3. Segments missing scoring input records

SELECT
    s.segment_id,
    s.segment_name
FROM segments s
LEFT JOIN scoring_inputs si
    ON s.segment_id = si.segment_id
WHERE si.segment_id IS NULL;


-- 4. Opportunities linked to unknown segments

SELECT
    o.opportunity_id,
    o.segment_id,
    o.company_type,
    o.region
FROM opportunities o
LEFT JOIN segments s
    ON o.segment_id = s.segment_id
WHERE s.segment_id IS NULL;


-- 5. Missing scoring values

SELECT
    s.segment_id,
    s.segment_name,
    mi.market_size_score,
    mi.growth_score,
    mi.margin_score,
    mi.competitive_intensity_score,
    mi.regulatory_barrier_score,
    si.strategic_fit_score,
    si.customer_pain_score,
    si.sales_accessibility_score,
    si.case_evidence_score,
    si.implementation_feasibility_score
FROM segments s
LEFT JOIN market_indicators mi
    ON s.segment_id = mi.segment_id
LEFT JOIN scoring_inputs si
    ON s.segment_id = si.segment_id
WHERE
    mi.market_size_score IS NULL OR
    mi.growth_score IS NULL OR
    mi.margin_score IS NULL OR
    mi.competitive_intensity_score IS NULL OR
    mi.regulatory_barrier_score IS NULL OR
    si.strategic_fit_score IS NULL OR
    si.customer_pain_score IS NULL OR
    si.sales_accessibility_score IS NULL OR
    si.case_evidence_score IS NULL OR
    si.implementation_feasibility_score IS NULL;


-- 6. Scores outside the expected 1 to 10 range

SELECT
    s.segment_id,
    s.segment_name,
    'market_size_score' AS field_name,
    mi.market_size_score AS score_value
FROM segments s
JOIN market_indicators mi
    ON s.segment_id = mi.segment_id
WHERE mi.market_size_score NOT BETWEEN 1 AND 10

UNION ALL

SELECT
    s.segment_id,
    s.segment_name,
    'growth_score' AS field_name,
    mi.growth_score AS score_value
FROM segments s
JOIN market_indicators mi
    ON s.segment_id = mi.segment_id
WHERE mi.growth_score NOT BETWEEN 1 AND 10

UNION ALL

SELECT
    s.segment_id,
    s.segment_name,
    'margin_score' AS field_name,
    mi.margin_score AS score_value
FROM segments s
JOIN market_indicators mi
    ON s.segment_id = mi.segment_id
WHERE mi.margin_score NOT BETWEEN 1 AND 10

UNION ALL

SELECT
    s.segment_id,
    s.segment_name,
    'competitive_intensity_score' AS field_name,
    mi.competitive_intensity_score AS score_value
FROM segments s
JOIN market_indicators mi
    ON s.segment_id = mi.segment_id
WHERE mi.competitive_intensity_score NOT BETWEEN 1 AND 10

UNION ALL

SELECT
    s.segment_id,
    s.segment_name,
    'regulatory_barrier_score' AS field_name,
    mi.regulatory_barrier_score AS score_value
FROM segments s
JOIN market_indicators mi
    ON s.segment_id = mi.segment_id
WHERE mi.regulatory_barrier_score NOT BETWEEN 1 AND 10

UNION ALL

SELECT
    s.segment_id,
    s.segment_name,
    'strategic_fit_score' AS field_name,
    si.strategic_fit_score AS score_value
FROM segments s
JOIN scoring_inputs si
    ON s.segment_id = si.segment_id
WHERE si.strategic_fit_score NOT BETWEEN 1 AND 10

UNION ALL

SELECT
    s.segment_id,
    s.segment_name,
    'customer_pain_score' AS field_name,
    si.customer_pain_score AS score_value
FROM segments s
JOIN scoring_inputs si
    ON s.segment_id = si.segment_id
WHERE si.customer_pain_score NOT BETWEEN 1 AND 10

UNION ALL

SELECT
    s.segment_id,
    s.segment_name,
    'sales_accessibility_score' AS field_name,
    si.sales_accessibility_score AS score_value
FROM segments s
JOIN scoring_inputs si
    ON s.segment_id = si.segment_id
WHERE si.sales_accessibility_score NOT BETWEEN 1 AND 10

UNION ALL

SELECT
    s.segment_id,
    s.segment_name,
    'case_evidence_score' AS field_name,
    si.case_evidence_score AS score_value
FROM segments s
JOIN scoring_inputs si
    ON s.segment_id = si.segment_id
WHERE si.case_evidence_score NOT BETWEEN 1 AND 10

UNION ALL

SELECT
    s.segment_id,
    s.segment_name,
    'implementation_feasibility_score' AS field_name,
    si.implementation_feasibility_score AS score_value
FROM segments s
JOIN scoring_inputs si
    ON s.segment_id = si.segment_id
WHERE si.implementation_feasibility_score NOT BETWEEN 1 AND 10;


-- 7. Invalid opportunity values

SELECT
    opportunity_id,
    segment_id,
    company_type,
    estimated_deal_value_eur,
    probability_percent
FROM opportunities
WHERE
    estimated_deal_value_eur IS NULL OR
    estimated_deal_value_eur < 0 OR
    probability_percent IS NULL OR
    probability_percent < 0 OR
    probability_percent > 100;


-- 8. Source segments missing from final scoring output

SELECT
    s.segment_id,
    s.segment_name
FROM segments s
LEFT JOIN market_prioritization_scores mps
    ON s.segment_name = mps.segment_name
WHERE mps.segment_name IS NULL;


-- 9. Source count versus scored output count

SELECT
    (SELECT COUNT(*) FROM segments) AS source_segment_count,
    (SELECT COUNT(*) FROM market_prioritization_scores) AS scored_segment_count,
    CASE
        WHEN (SELECT COUNT(*) FROM segments) =
             (SELECT COUNT(*) FROM market_prioritization_scores)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS segment_count_check;


-- 10. Final attractiveness score range

SELECT
    MIN(attractiveness_score) AS min_attractiveness_score,
    MAX(attractiveness_score) AS max_attractiveness_score,
    CASE
        WHEN MIN(attractiveness_score) >= 1
         AND MAX(attractiveness_score) <= 10
        THEN 'PASS'
        ELSE 'FAIL'
    END AS attractiveness_score_range_check
FROM market_prioritization_scores;
