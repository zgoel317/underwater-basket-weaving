-- Additional performance indexes for Underwater Basket Weaving Dating App

-- Composite indexes for common queries
CREATE INDEX idx_profiles_location_experience ON profiles USING GIST(location) WHERE experience_level IS NOT NULL;
CREATE INDEX idx_profiles_active_users ON profiles(user_id) WHERE user_id IN (SELECT id FROM users WHERE status = 'active');

-- Matching algorithm optimization
CREATE INDEX idx_matches_pending_user1 ON matches(user1_id) WHERE status = 'pending';
CREATE INDEX idx_matches_pending_user2 ON matches(user2_id) WHERE status = 'pending';
CREATE INDEX idx_matches_matched ON matches(matched_at DESC) WHERE status = 'matched';

-- Message retrieval optimization
CREATE INDEX idx_messages_conversation_recent ON messages(conversation_id, created_at DESC) WHERE created_at > CURRENT_TIMESTAMP - INTERVAL '30 days';
CREATE INDEX idx_messages_unread_user ON messages(conversation_id) WHERE is_read = false;

-- Event discovery
CREATE INDEX idx_events_upcoming ON events(start_datetime) WHERE status = 'scheduled' AND start_datetime > CURRENT_TIMESTAMP;
CREATE INDEX idx_events_location_upcoming ON events USING GIST(location) WHERE status = 'scheduled' AND start_datetime > CURRENT_TIMESTAMP;

-- Dive site search
CREATE INDEX idx_dive_sites_location_difficulty ON dive_sites USING GIST(location) WHERE difficulty_level IS NOT NULL;
CREATE INDEX idx_dive_sites_high_rated ON dive_sites(average_rating DESC, review_count DESC) WHERE average_rating >= 4.0;

-- Forum activity
CREATE INDEX idx_forum_posts_recent ON forum_posts(created_at DESC) WHERE created_at > CURRENT_TIMESTAMP - INTERVAL '90 days';
CREATE INDEX idx_forum_posts_popular ON forum_posts(likes_count DESC, replies_count DESC);

-- Marketplace search
CREATE INDEX idx_marketplace_active_category ON marketplace_listings(category, price) WHERE status = 'active';
CREATE INDEX idx_marketplace_active_location ON marketplace_listings USING GIST(location) WHERE status = 'active';

-- Notification delivery
CREATE INDEX idx_notifications_unread ON notifications(user_id, created_at DESC) WHERE is_read = false;

-- Subscription management
CREATE INDEX idx_subscriptions_expiring ON subscriptions(end_date) WHERE status = 'active' AND end_date < CURRENT_TIMESTAMP + INTERVAL '7 days';

-- Safety and verification
CREATE INDEX idx_dive_buddy_verifications_recent ON dive_buddy_verifications(verified_user_id, dive_date DESC) WHERE dive_date > CURRENT_TIMESTAMP - INTERVAL '1 year';
CREATE INDEX idx_safety_certs_valid ON safety_certifications(profile_id, certification_type) WHERE expiry_date > CURRENT_TIMESTAMP OR expiry_date IS NULL;

-- Partial indexes for frequently filtered data
CREATE INDEX idx_users_active ON users(id) WHERE status = 'active';
CREATE INDEX idx_profiles_equipment_sharers ON profiles(id, location) WHERE equipment_sharing = true;
CREATE INDEX idx_events_with_space ON events(id, start_datetime) WHERE current_participants < max_participants AND status = 'scheduled';
