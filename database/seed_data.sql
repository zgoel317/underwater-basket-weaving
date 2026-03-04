-- Seed data for development and testing

BEGIN;

-- Clear existing data
TRUNCATE TABLE post_comments, community_posts, event_participants, events, dive_site_reviews, dive_sites, messages, conversations, matches, profile_photos, safety_certifications, profiles, users CASCADE;

-- Insert sample users
INSERT INTO users (id, email, password_hash, is_active) VALUES 
('11111111-1111-1111-1111-111111111111', 'alice@underwaterweaving.com', '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', true),
('22222222-2222-2222-2222-222222222222', 'bob@deepbaskets.com', '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', true),
('33333333-3333-3333-3333-333333333333', 'carol@aquaticcraft.org', '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', true),
('44444444-4444-4444-4444-444444444444', 'david@marineart.net', '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', true);

-- Insert profiles
INSERT INTO profiles (id, user_id, display_name, bio, age, location_lat, location_lng, location_name, travel_radius_km, experience_level, preferred_depth_min, preferred_depth_max, diving_schedule, basket_specialties, equipment_sharing, profile_image_url) VALUES 
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Alice Deep', 'Master weaver with 15 years underwater experience. Love creating intricate patterns in kelp forests.', 32, 37.7749, -122.4194, 'San Francisco, CA', 100, 'Master Weaver', 10, 40, 'Weekends, early mornings', ARRAY['kelp reed', 'spiral patterns', 'deep water techniques'], true, 'https://images.example.com/alice.jpg'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', 'Bob Aquaweave', 'Intermediate weaver looking to learn from experienced divers. Passionate about sustainable materials.', 28, 37.8044, -122.2711, 'Oakland, CA', 75, 'Intermediate', 5, 25, 'Evenings, weekends', ARRAY['reed basics', 'underwater tools'], true, 'https://images.example.com/bob.jpg'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', '33333333-3333-3333-3333-333333333333', 'Carol Deepcraft', 'Advanced weaver specializing in competition pieces. Active in local diving community.', 35, 36.9741, -122.0308, 'Santa Cruz, CA', 120, 'Advanced', 15, 50, 'Flexible schedule', ARRAY['competition weaving', 'artistic patterns', 'teaching'], false, 'https://images.example.com/carol.jpg'),
('dddddddd-dddd-dddd-dddd-dddddddddddd', '44444444-4444-4444-4444-444444444444', 'David Tidewoven', 'Beginner eager to learn! Recently got certified and excited about this unique art form.', 24, 36.6177, -121.9166, 'Monterey, CA', 50, 'Beginner', 3, 15, 'Weekends only', ARRAY['basic patterns'], false, 'https://images.example.com/david.jpg');

-- Insert safety certifications
INSERT INTO safety_certifications (profile_id, certification_type, certification_level, issuing_organization, issue_date, expiry_date, verification_status) VALUES 
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Open Water Diver', 'Advanced', 'PADI', '2020-03-15', '2025-03-15', 'verified'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Rescue Diver', 'Certified', 'PADI', '2021-07-20', '2026-07-20', 'verified'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Open Water Diver', 'Basic', 'SSI', '2023-01-10', '2028-01-10', 'verified'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Advanced Open Water', 'Advanced', 'NAUI', '2019-05-12', '2024-05-12', 'verified'),
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Open Water Diver', 'Basic', 'PADI', '2024-01-05', '2029-01-05', 'verified');

-- Insert dive sites
INSERT INTO dive_sites (id, name, description, location_lat, location_lng, max_depth, difficulty_level, water_conditions, best_seasons, facilities, safety_notes, created_by_profile_id) VALUES 
('site1111-1111-1111-1111-111111111111', 'Monterey Bay Kelp Forest', 'Perfect kelp forest for intermediate basket weaving with abundant reed materials', 36.6177, -121.9166, 30, 'Intermediate', 'Generally calm, good visibility', ARRAY['spring', 'summer', 'fall'], ARRAY['parking', 'restrooms', 'equipment rental'], 'Watch for sea otters, current can change quickly', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
('site2222-2222-2222-2222-222222222222', 'Point Lobos Reserve', 'Protected cove ideal for beginners learning underwater weaving basics', 36.5225, -121.9552, 20, 'Beginner', 'Sheltered, minimal current', ARRAY['year-round'], ARRAY['visitor center', 'guided tours', 'parking'], 'Marine protected area - follow all regulations', 'cccccccc-cccc-cccc-cccc-cccccccccccc'),
('site3333-3333-3333-3333-333333333333', 'Carmel Bay Deep', 'Advanced site with unique deep-water reeds and challenging conditions', 36.5567, -121.9233, 60, 'Advanced', 'Strong currents, variable visibility', ARRAY['summer'], ARRAY['boat launch', 'technical diving support'], 'Deep site - advanced certification required', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

-- Insert events
INSERT INTO events (id, title, description, event_type, dive_site_id, organizer_profile_id, start_datetime, end_datetime, max_participants, skill_level_required, equipment_provided, cost, registration_deadline) VALUES 
('evt11111-1111-1111-1111-111111111111', 'Beginner Basket Weaving Workshop', 'Learn the basics of underwater basket weaving in a safe, shallow environment', 'workshop', 'site2222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '2024-02-15 09:00:00', '2024-02-15 15:00:00', 8, 'Beginner', true, 150.00, '2024-02-10 23:59:59'),
('evt22222-2222-2222-2222-222222222222', 'Monthly Group Dive - Kelp Forest', 'Regular community dive for all skill levels in the famous Monterey kelp forest', 'dive', 'site1111-1111-1111-1111-111111111111', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '2024-02-20 08:00:00', '2024-02-20 12:00:00', 15, 'Intermediate', false, 0, '2024-02-18 23:59:59'),
('evt33333-3333-3333-3333-333333333333', 'Advanced Competition Prep', 'Intensive training for upcoming regional underwater basket weaving championship', 'competition', 'site3333-3333-3333-3333-333333333333', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '2024-03-01 07:00:00', '2024-03-01 17:00:00', 6, 'Advanced', true, 300.00, '2024-02-25 23:59:59');

-- Insert event participants
INSERT INTO event_participants (event_id, profile_id, registration_status, notes) VALUES 
('evt11111-1111-1111-1111-111111111111', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'confirmed', 'First workshop - very excited!'),
('evt11111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'confirmed', 'Happy to help mentor beginners'),
('evt22222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'confirmed', NULL),
('evt22222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'confirmed', NULL),
('evt22222-2222-2222-2222-222222222222', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'registered', 'Need to confirm diving insurance'),
('evt33333-3333-3333-3333-333333333333', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'confirmed', 'Defending champion'),
('evt33333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'confirmed', 'Ready for competition season');

-- Insert matches
INSERT INTO matches (profile1_id, profile2_id, match_status, matched_at) VALUES 
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'matched', '2024-01-15 14:30:00'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'matched', '2024-01-18 10:15:00'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'pending', NULL);

COMMIT;