-- Matching system queries

-- Create or update match
INSERT INTO matches (profile1_id, profile2_id, match_status, matched_at)
VALUES ($1, $2, $3, CASE WHEN $3 = 'matched' THEN CURRENT_TIMESTAMP ELSE NULL END)
ON CONFLICT (profile1_id, profile2_id) 
DO UPDATE SET 
    match_status = $3,
    matched_at = CASE WHEN $3 = 'matched' THEN CURRENT_TIMESTAMP ELSE matches.matched_at END;

-- Get match compatibility score
WITH profile1 AS (
    SELECT * FROM profiles WHERE id = $1
),
profile2 AS (
    SELECT * FROM profiles WHERE id = $2
),
scores AS (
    SELECT 
        -- Experience level compatibility (0-25 points)
        CASE 
            WHEN p1.experience_level = p2.experience_level THEN 25
            WHEN ABS(
                CASE p1.experience_level 
                    WHEN 'Beginner' THEN 1
                    WHEN 'Intermediate' THEN 2 
                    WHEN 'Advanced' THEN 3
                    WHEN 'Master Weaver' THEN 4
                END - 
                CASE p2.experience_level 
                    WHEN 'Beginner' THEN 1
                    WHEN 'Intermediate' THEN 2
                    WHEN 'Advanced' THEN 3 
                    WHEN 'Master Weaver' THEN 4
                END
            ) = 1 THEN 15
            ELSE 5
        END as experience_score,
        
        -- Depth compatibility (0-25 points)
        CASE 
            WHEN p1.preferred_depth_min IS NULL OR p2.preferred_depth_min IS NULL THEN 10
            WHEN p1.preferred_depth_max >= p2.preferred_depth_min 
                AND p2.preferred_depth_max >= p1.preferred_depth_min THEN 25
            ELSE 0
        END as depth_score,
        
        -- Distance score (0-25 points)
        GREATEST(0, 25 - (ST_Distance_Sphere(
            ST_MakePoint(p1.location_lng, p1.location_lat),
            ST_MakePoint(p2.location_lng, p2.location_lat)
        ) / 1000 / 5)) as distance_score,
        
        -- Equipment sharing bonus (0-25 points)
        CASE 
            WHEN p1.equipment_sharing AND p2.equipment_sharing THEN 25
            WHEN p1.equipment_sharing OR p2.equipment_sharing THEN 15
            ELSE 10
        END as equipment_score
    FROM profile1 p1, profile2 p2
)
SELECT 
    experience_score + depth_score + distance_score + equipment_score as total_score,
    experience_score,
    depth_score, 
    distance_score,
    equipment_score
FROM scores;

-- Find dive buddy candidates for upcoming events
SELECT DISTINCT
    p.id,
    p.display_name,
    p.experience_level,
    p.profile_image_url,
    e.title as event_name,
    e.start_datetime
FROM profiles p
JOIN event_participants ep ON p.id = ep.profile_id
JOIN events e ON ep.event_id = e.id
WHERE e.start_datetime > CURRENT_TIMESTAMP
    AND e.start_datetime < CURRENT_TIMESTAMP + INTERVAL '30 days'
    AND ep.registration_status = 'confirmed'
    AND p.id != $1
    AND NOT EXISTS (
        SELECT 1 FROM matches m
        WHERE (m.profile1_id = $1 AND m.profile2_id = p.id)
           OR (m.profile1_id = p.id AND m.profile2_id = $1)
        AND m.match_status IN ('matched', 'blocked')
    )
ORDER BY e.start_datetime;