-- Common user and profile queries

-- Get full user profile with certifications
SELECT 
    u.id as user_id,
    u.email,
    p.*,
    COALESCE(json_agg(sc.*) FILTER (WHERE sc.id IS NOT NULL), '[]'::json) as certifications,
    COALESCE(json_agg(pp.*) FILTER (WHERE pp.id IS NOT NULL), '[]'::json) as photos
FROM users u
JOIN profiles p ON u.id = p.user_id
LEFT JOIN safety_certifications sc ON p.id = sc.profile_id
LEFT JOIN profile_photos pp ON p.id = pp.profile_id
WHERE u.id = $1
GROUP BY u.id, p.id;

-- Find potential matches by location and experience
SELECT 
    p2.*,
    ST_Distance_Sphere(
        ST_MakePoint(p1.location_lng, p1.location_lat),
        ST_MakePoint(p2.location_lng, p2.location_lat)
    ) / 1000 as distance_km
FROM profiles p1
CROSS JOIN profiles p2
WHERE p1.id = $1 
    AND p2.id != p1.id
    AND p2.location_lat IS NOT NULL
    AND p2.location_lng IS NOT NULL
    AND ST_Distance_Sphere(
        ST_MakePoint(p1.location_lng, p1.location_lat),
        ST_MakePoint(p2.location_lng, p2.location_lat)
    ) / 1000 <= p1.travel_radius_km
    AND NOT EXISTS (
        SELECT 1 FROM matches m 
        WHERE (m.profile1_id = p1.id AND m.profile2_id = p2.id)
           OR (m.profile1_id = p2.id AND m.profile2_id = p1.id)
    )
ORDER BY distance_km;

-- Get user's conversations with latest messages
SELECT 
    c.id as conversation_id,
    m_other.profile_id as other_profile_id,
    p_other.display_name as other_profile_name,
    p_other.profile_image_url as other_profile_image,
    latest_msg.content as last_message,
    latest_msg.sent_at as last_message_at,
    latest_msg.message_type as last_message_type
FROM conversations c
JOIN matches m ON c.match_id = m.id
JOIN LATERAL (
    SELECT CASE 
        WHEN m.profile1_id = $1 THEN m.profile2_id 
        ELSE m.profile1_id 
    END as profile_id
) m_other ON true
JOIN profiles p_other ON m_other.profile_id = p_other.id
LEFT JOIN LATERAL (
    SELECT content, sent_at, message_type
    FROM messages msg
    WHERE msg.conversation_id = c.id
        AND msg.is_deleted = false
    ORDER BY msg.sent_at DESC
    LIMIT 1
) latest_msg ON true
WHERE (m.profile1_id = $1 OR m.profile2_id = $1)
    AND m.match_status = 'matched'
    AND c.is_active = true
ORDER BY latest_msg.sent_at DESC;