-- Seed data for Underwater Basket Weaving Dating App
-- This provides sample data for development and testing

-- Insert sample users
INSERT INTO users (id, email, password_hash, status) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'alice@example.com', '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', 'active'),
('550e8400-e29b-41d4-a716-446655440002', 'bob@example.com', '$2b$10$abcdefghijklmnopqrstuvwxyz1234567891', 'active'),
('550e8400-e29b-41d4-a716-446655440003', 'charlie@example.com', '$2b$10$abcdefghijklmnopqrstuvwxyz1234567892', 'active'),
('550e8400-e29b-41d4-a716-446655440004', 'diana@example.com', '$2b$10$abcdefghijklmnopqrstuvwxyz1234567893', 'active'),
('550e8400-e29b-41d4-a716-446655440005', 'evan@example.com', '$2b$10$abcdefghijklmnopqrstuvwxyz1234567894', 'active');

-- Insert sample profiles
INSERT INTO profiles (user_id, display_name, bio, experience_level, location, city, state, country, travel_radius_km, weaving_specialties) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Alice Waters', 'Passionate about reed weaving at 30ft depths. Love exploring new techniques!', 'Advanced', ST_SetSRID(ST_MakePoint(-122.4194, 37.7749), 4326), 'San Francisco', 'CA', 'USA', 50, ARRAY['reed', 'willow', 'spiral_weave']),
('550e8400-e29b-41d4-a716-446655440002', 'Bob Builder', 'Master Weaver with 15 years experience. Specializing in deep water techniques.', 'Master Weaver', ST_SetSRID(ST_MakePoint(-118.2437, 34.0522), 4326), 'Los Angeles', 'CA', 'USA', 100, ARRAY['bamboo', 'complex_patterns', 'underwater_finishing']),
('550e8400-e29b-41d4-a716-446655440003', 'Charlie Diver', 'New to underwater basket weaving but eager to learn! Looking for dive buddies.', 'Beginner', ST_SetSRID(ST_MakePoint(-87.6298, 41.8781), 4326), 'Chicago', 'IL', 'USA', 30, ARRAY['basic_weave']),
('550e8400-e29b-41d4-a716-446655440004', 'Diana Deep', 'Intermediate weaver focusing on artistic patterns. Equipment sharer!', 'Intermediate', ST_SetSRID(ST_MakePoint(-74.0060, 40.7128), 4326), 'New York', 'NY', 'USA', 75, ARRAY['artistic_patterns', 'color_weaving']),
('550e8400-e29b-41d4-a716-446655440005', 'Evan Explorer', 'Love combining diving adventures with basket weaving!', 'Intermediate', ST_SetSRID(ST_MakePoint(-122.3321, 47.6062), 4326), 'Seattle', 'WA', 'USA', 60, ARRAY['travel_weaving', 'reed', 'quick_techniques']);

-- Insert diving certifications
INSERT INTO diving_certifications (profile_id, certification_name, certification_level, issuing_organization, issue_date) VALUES
((SELECT id FROM profiles WHERE user_id = '550e8400-e29b-41d4-a716-446655440001'), 'Open Water Diver', 'Advanced', 'PADI', '2020-05-15'),
((SELECT id FROM profiles WHERE user_id = '550e8400-e29b-41d4-a716-446655440002'), 'Dive Master', 'Professional', 'PADI', '2015-03-20'),
((SELECT id FROM profiles WHERE user_id = '550e8400-e29b-41d4-a716-446655440003'), 'Open Water Diver', 'Basic', 'SSI', '2023-01-10');

-- Insert safety certifications
INSERT INTO safety_certifications (profile_id, certification_type, issue_date, expiry_date, verified) VALUES
((SELECT id FROM profiles WHERE user_id = '550e8400-e29b-41d4-a716-446655440001'), 'First Aid', '2023-06-01', '2025-06-01', true),
((SELECT id FROM profiles WHERE user_id = '550e8400-e29b-41d4-a716-446655440002'), 'CPR', '2023-01-15', '2025-01-15', true),
((SELECT id FROM profiles WHERE user_id = '550e8400-e29b-41d4-a716-446655440002'), 'Rescue Diver', '2022-08-20', '2026-08-20', true);

-- Insert dive sites
INSERT INTO dive_sites (id, name, description, location, city, state, country, max_depth_meters, difficulty_level, features) VALUES
('660e8400-e29b-41d4-a716-446655440001', 'Crystal Cove', 'Beautiful shallow waters perfect for beginners. Calm conditions year-round.', ST_SetSRID(ST_MakePoint(-122.4500, 37.8000), 4326), 'San Francisco', 'CA', 'USA', 15.0, 'Beginner', ARRAY['clear_water', 'parking', 'easy_access']),
('660e8400-e29b-41d4-a716-446655440002', 'Deep Blue Canyon', 'Advanced site with strong currents. Incredible visibility and diverse weaving spots.', ST_SetSRID(ST_MakePoint(-118.5000, 34.0000), 4326), 'Malibu', 'CA', 'USA', 45.0, 'Advanced', ARRAY['strong_currents', 'deep_water', 'experienced_only']),
('660e8400-e29b-41d4-a716-446655440003', 'Lake Michigan Weaving Ground', 'Freshwater site ideal for practice. Multiple depth zones.', ST_SetSRID(ST_MakePoint(-87.6000, 41.9000), 4326), 'Chicago', 'IL', 'USA', 25.0, 'Intermediate', ARRAY['freshwater', 'multiple_depths', 'sheltered']);

-- Insert events
INSERT INTO events (id, title, description, event_type, organizer_id, dive_site_id, start_datetime, max_participants, skill_level_required) VALUES
('770e8400-e29b-41d4-a716-446655440001', 'Beginner Weaving Workshop', 'Learn basic underwater basket weaving techniques with experienced instructors.', 'workshop', '550e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440001', CURRENT_TIMESTAMP + INTERVAL '7 days', 10, 'Beginner'),
('770e8400-e29b-41d4-a716-446655440002', 'Advanced Pattern Dive', 'Explore complex weaving patterns in deep water conditions.', 'group_weave', '550e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440002', CURRENT_TIMESTAMP + INTERVAL '14 days', 6, 'Advanced'),
('770e8400-e29b-41d4-a716-446655440003', 'Monthly Meetup - Chicago', 'Casual dive and weave session for all levels.', 'meetup', '550e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440003', CURRENT_TIMESTAMP + INTERVAL '21 days', 15, 'Beginner');

-- Insert community groups
INSERT INTO community_groups (id, name, description, group_type, location, city, state, country, created_by) VALUES
('880e8400-e29b-41d4-a716-446655440001', 'Bay Area Weavers', 'Community of underwater basket weavers in the San Francisco Bay Area', 'local', ST_SetSRID(ST_MakePoint(-122.4194, 37.7749), 4326), 'San Francisco', 'CA', 'USA', '550e8400-e29b-41d4-a716-446655440001'),
('880e8400-e29b-41d4-a716-446655440002', 'Master Weaver Circle', 'Elite group for advanced techniques and mentorship', 'skill_based', NULL, NULL, NULL, 'USA', '550e8400-e29b-41d4-a716-446655440002'),
('880e8400-e29b-41d4-a716-446655440003', 'Chicago Diving Weavers', 'Local Chicago underwater basket weaving community', 'local', ST_SetSRID(ST_MakePoint(-87.6298, 41.8781), 4326), 'Chicago', 'IL', 'USA', '550e8400-e29b-41d4-a716-446655440003');

-- Insert group members
INSERT INTO group_members (group_id, user_id, role) VALUES
('880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'admin'),
('880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'member'),
('880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 'admin'),
('880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'member'),
('880e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 'admin');

-- Insert matches
INSERT INTO matches (id, user1_id, user2_id, status, initiated_by, matched_at) VALUES
('990e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'matched', '550e8400-e29b-41d4-a716-446655440001', CURRENT_TIMESTAMP - INTERVAL '5 days'),
('990e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440004', 'matched', '550e8400-e29b-41d4-a716-446655440003', CURRENT_TIMESTAMP - INTERVAL '2 days'),
('990e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440005', 'pending', '550e8400-e29b-41d4-a716-446655440001', NULL);

-- Insert conversations
INSERT INTO conversations (id, match_id) VALUES
('aa0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440001'),
('aa0e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440002');

-- Insert messages
INSERT INTO messages (conversation_id, sender_id, message_type, content, is_read) VALUES
('aa0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'text', 'Hi Bob! I saw your profile and would love to learn some advanced techniques from you!', true),
('aa0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'text', 'Hey Alice! Would be happy to help. Want to meet at Crystal Cove this weekend?', true),
('aa0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440003', 'text', 'Hey Diana! Are you free for a dive this week?', false);

-- Insert marketplace listings
INSERT INTO marketplace_listings (seller_id, title, description, category, condition, price, location, city, state, country, status) VALUES
('550e8400-e29b-41d4-a716-446655440002', 'Premium Reed Bundle', 'High quality reeds perfect for underwater weaving. Variety pack includes willow, bamboo, and palm.', 'reeds', 'new', 45.99, ST_SetSRID(ST_MakePoint(-118.2437, 34.0522), 4326), 'Los Angeles', 'CA', 'USA', 'active'),
('550e8400-e29b-41d4-a716-446655440001', 'Underwater Weaving Tools Set', 'Complete tool set including scissors, awl, and measuring tape. Waterproof up to 50m.', 'tools', 'like_new', 89.99, ST_SetSRID(ST_MakePoint(-122.4194, 37.7749), 4326), 'San Francisco', 'CA', 'USA', 'active'),
('550e8400-e29b-41d4-a716-446655440004', 'Handwoven Display Basket', 'Beautiful basket made at 20ft depth. Great for showcasing your skills!', 'baskets', 'new', 120.00, ST_SetSRID(ST_MakePoint(-74.0060, 40.7128), 4326), 'New York', 'NY', 'USA', 'active');

-- Insert forum posts
INSERT INTO forum_posts (group_id, author_id, title, content, post_type, tags) VALUES
('880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'Tips for Weaving in Strong Currents', 'I''ve been practicing weaving in stronger currents and found that anchoring your base is crucial. Here are my top 5 tips...', 'technique', ARRAY['currents', 'advanced', 'safety']),
('880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 'New Pattern Discovery', 'Just developed a new spiral pattern that works great at depth. Anyone want to try it out?', 'showcase', ARRAY['patterns', 'innovation']),
('880e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 'Best Dive Sites in Chicago?', 'New to the area and looking for recommendations on good weaving spots. Any suggestions?', 'question', ARRAY['chicago', 'dive_sites', 'beginner']);

-- Insert subscriptions
INSERT INTO subscriptions (user_id, plan_type, status, start_date, end_date) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'premium', 'active', CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP + INTERVAL '335 days'),
('550e8400-e29b-41d4-a716-446655440002', 'master_weaver', 'active', CURRENT_TIMESTAMP - INTERVAL '90 days', CURRENT_TIMESTAMP + INTERVAL '275 days'),
('550e8400-e29b-41d4-a716-446655440003', 'basic', 'active', CURRENT_TIMESTAMP - INTERVAL '10 days', NULL);
