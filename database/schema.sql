-- Underwater Basket Weaving Dating App Database Schema

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'deleted')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);

-- Profiles table
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    display_name VARCHAR(100) NOT NULL,
    bio TEXT,
    date_of_birth DATE,
    gender VARCHAR(50),
    location GEOGRAPHY(POINT, 4326),
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50),
    travel_radius_km INTEGER DEFAULT 50,
    experience_level VARCHAR(20) NOT NULL CHECK (experience_level IN ('Beginner', 'Intermediate', 'Advanced', 'Master Weaver')),
    preferred_depths VARCHAR(50),
    weaving_specialties TEXT[],
    equipment_sharing BOOLEAN DEFAULT false,
    profile_photo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_profiles_location ON profiles USING GIST(location);
CREATE INDEX idx_profiles_experience ON profiles(experience_level);

-- Profile photos gallery
CREATE TABLE profile_photos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    photo_url TEXT NOT NULL,
    photo_type VARCHAR(20) CHECK (photo_type IN ('underwater', 'surface', 'basket')),
    is_primary BOOLEAN DEFAULT false,
    display_order INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_profile_photos_profile ON profile_photos(profile_id);
CREATE INDEX idx_profile_photos_primary ON profile_photos(profile_id, is_primary);

-- Diving certifications
CREATE TABLE diving_certifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    certification_name VARCHAR(100) NOT NULL,
    certification_level VARCHAR(50),
    issuing_organization VARCHAR(100),
    issue_date DATE,
    expiry_date DATE,
    certification_number VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_diving_certs_profile ON diving_certifications(profile_id);
CREATE INDEX idx_diving_certs_expiry ON diving_certifications(expiry_date);

-- Safety certifications (First Aid, CPR, etc.)
CREATE TABLE safety_certifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    certification_type VARCHAR(50) NOT NULL CHECK (certification_type IN ('First Aid', 'CPR', 'Rescue Diver', 'Emergency Oxygen', 'Other')),
    certification_name VARCHAR(100),
    issue_date DATE,
    expiry_date DATE,
    verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_safety_certs_profile ON safety_certifications(profile_id);
CREATE INDEX idx_safety_certs_verified ON safety_certifications(profile_id, verified);

-- User preferences for matching
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    min_age INTEGER,
    max_age INTEGER,
    preferred_experience_levels VARCHAR(20)[],
    preferred_genders VARCHAR(50)[],
    max_distance_km INTEGER DEFAULT 50,
    show_equipment_sharers_only BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_prefs_user ON user_preferences(user_id);

-- Matches table
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'matched', 'rejected', 'expired')),
    initiated_by UUID NOT NULL REFERENCES users(id),
    matched_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_match UNIQUE (user1_id, user2_id),
    CONSTRAINT no_self_match CHECK (user1_id != user2_id)
);

CREATE INDEX idx_matches_user1 ON matches(user1_id, status);
CREATE INDEX idx_matches_user2 ON matches(user2_id, status);
CREATE INDEX idx_matches_status ON matches(status);

-- Conversations
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID UNIQUE NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    is_group BOOLEAN DEFAULT false,
    group_name VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_conversations_match ON conversations(match_id);

-- Conversation participants (for group chats)
CREATE TABLE conversation_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_read_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT unique_participant UNIQUE (conversation_id, user_id)
);

CREATE INDEX idx_conv_participants_conversation ON conversation_participants(conversation_id);
CREATE INDEX idx_conv_participants_user ON conversation_participants(user_id);

-- Messages
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'photo', 'voice', 'video_call', 'system')),
    content TEXT,
    media_url TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_unread ON messages(conversation_id, is_read);

-- Dive sites
CREATE TABLE dive_sites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50),
    max_depth_meters DECIMAL(6,2),
    difficulty_level VARCHAR(20) CHECK (difficulty_level IN ('Beginner', 'Intermediate', 'Advanced', 'Expert')),
    features TEXT[],
    facilities TEXT[],
    access_type VARCHAR(50),
    entry_fee DECIMAL(10,2),
    average_rating DECIMAL(3,2),
    review_count INTEGER DEFAULT 0,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dive_sites_location ON dive_sites USING GIST(location);
CREATE INDEX idx_dive_sites_difficulty ON dive_sites(difficulty_level);
CREATE INDEX idx_dive_sites_rating ON dive_sites(average_rating DESC);

-- Dive site reviews
CREATE TABLE dive_site_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dive_site_id UUID NOT NULL REFERENCES dive_sites(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    visit_date DATE,
    conditions TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_site_review UNIQUE (dive_site_id, user_id)
);

CREATE INDEX idx_dive_reviews_site ON dive_site_reviews(dive_site_id, created_at DESC);
CREATE INDEX idx_dive_reviews_user ON dive_site_reviews(user_id);

-- Events (group weaves, dive expeditions)
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    event_type VARCHAR(50) CHECK (event_type IN ('group_weave', 'dive_expedition', 'workshop', 'meetup', 'competition', 'other')),
    organizer_id UUID NOT NULL REFERENCES users(id),
    dive_site_id UUID REFERENCES dive_sites(id),
    location GEOGRAPHY(POINT, 4326),
    address TEXT,
    start_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    end_datetime TIMESTAMP WITH TIME ZONE,
    max_participants INTEGER,
    current_participants INTEGER DEFAULT 0,
    skill_level_required VARCHAR(20),
    equipment_requirements TEXT[],
    cost DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'cancelled', 'completed', 'postponed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_events_organizer ON events(organizer_id);
CREATE INDEX idx_events_datetime ON events(start_datetime);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_location ON events USING GIST(location);

-- Event participants
CREATE TABLE event_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'registered' CHECK (status IN ('registered', 'confirmed', 'cancelled', 'attended')),
    dive_buddy_preference UUID REFERENCES users(id),
    registered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_event_participant UNIQUE (event_id, user_id)
);

CREATE INDEX idx_event_participants_event ON event_participants(event_id, status);
CREATE INDEX idx_event_participants_user ON event_participants(user_id);

-- Community groups (local weaving groups)
CREATE TABLE community_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    group_type VARCHAR(50) CHECK (group_type IN ('local', 'skill_based', 'interest', 'dive_site')),
    location GEOGRAPHY(POINT, 4326),
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50),
    is_private BOOLEAN DEFAULT false,
    member_count INTEGER DEFAULT 0,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_community_groups_location ON community_groups USING GIST(location);
CREATE INDEX idx_community_groups_type ON community_groups(group_type);

-- Group members
CREATE TABLE group_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES community_groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('admin', 'moderator', 'member')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_group_member UNIQUE (group_id, user_id)
);

CREATE INDEX idx_group_members_group ON group_members(group_id);
CREATE INDEX idx_group_members_user ON group_members(user_id);

-- Forum posts (technique sharing)
CREATE TABLE forum_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID REFERENCES community_groups(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(300),
    content TEXT NOT NULL,
    post_type VARCHAR(20) DEFAULT 'discussion' CHECK (post_type IN ('discussion', 'question', 'technique', 'showcase', 'announcement')),
    media_urls TEXT[],
    tags TEXT[],
    likes_count INTEGER DEFAULT 0,
    replies_count INTEGER DEFAULT 0,
    is_pinned BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_forum_posts_group ON forum_posts(group_id, created_at DESC);
CREATE INDEX idx_forum_posts_author ON forum_posts(author_id);
CREATE INDEX idx_forum_posts_type ON forum_posts(post_type);

-- Forum replies
CREATE TABLE forum_replies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES forum_posts(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    media_urls TEXT[],
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_forum_replies_post ON forum_replies(post_id, created_at);
CREATE INDEX idx_forum_replies_author ON forum_replies(author_id);

-- Marketplace listings (specialized equipment)
CREATE TABLE marketplace_listings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(50) CHECK (category IN ('reeds', 'tools', 'diving_gear', 'baskets', 'patterns', 'other')),
    condition VARCHAR(20) CHECK (condition IN ('new', 'like_new', 'good', 'fair', 'poor')),
    price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    location GEOGRAPHY(POINT, 4326),
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50),
    shipping_available BOOLEAN DEFAULT false,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'pending', 'sold', 'removed')),
    images TEXT[],
    views_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_marketplace_seller ON marketplace_listings(seller_id);
CREATE INDEX idx_marketplace_category ON marketplace_listings(category, status);
CREATE INDEX idx_marketplace_status ON marketplace_listings(status);
CREATE INDEX idx_marketplace_location ON marketplace_listings USING GIST(location);

-- Emergency contacts
CREATE TABLE emergency_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    contact_name VARCHAR(100) NOT NULL,
    relationship VARCHAR(50),
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_emergency_contacts_user ON emergency_contacts(user_id);
CREATE INDEX idx_emergency_contacts_primary ON emergency_contacts(user_id, is_primary);

-- Dive buddy verifications
CREATE TABLE dive_buddy_verifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    verifier_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    verified_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    dive_date DATE NOT NULL,
    dive_site_id UUID REFERENCES dive_sites(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comments TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT no_self_verify CHECK (verifier_id != verified_user_id)
);

CREATE INDEX idx_dive_buddy_verifications_verified ON dive_buddy_verifications(verified_user_id);
CREATE INDEX idx_dive_buddy_verifications_verifier ON dive_buddy_verifications(verifier_id);

-- Weather alerts
CREATE TABLE weather_alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dive_site_id UUID NOT NULL REFERENCES dive_sites(id) ON DELETE CASCADE,
    alert_type VARCHAR(50) CHECK (alert_type IN ('high_waves', 'strong_current', 'poor_visibility', 'storm', 'unsafe_conditions')),
    severity VARCHAR(20) CHECK (severity IN ('low', 'medium', 'high', 'extreme')),
    description TEXT,
    valid_from TIMESTAMP WITH TIME ZONE NOT NULL,
    valid_until TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_weather_alerts_site ON weather_alerts(dive_site_id, valid_until);
CREATE INDEX idx_weather_alerts_severity ON weather_alerts(severity, valid_until);

-- Subscriptions (premium features)
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_type VARCHAR(50) NOT NULL CHECK (plan_type IN ('basic', 'premium', 'master_weaver')),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired', 'trial')),
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE,
    auto_renew BOOLEAN DEFAULT true,
    payment_method VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_subscriptions_user ON subscriptions(user_id, status);
CREATE INDEX idx_subscriptions_status ON subscriptions(status, end_date);

-- User activity logs
CREATE TABLE user_activity_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_type VARCHAR(50) NOT NULL,
    activity_data JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_activity_logs_user ON user_activity_logs(user_id, created_at DESC);
CREATE INDEX idx_activity_logs_type ON user_activity_logs(activity_type, created_at DESC);

-- Notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT,
    data JSONB,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications(user_id, is_read, created_at DESC);
CREATE INDEX idx_notifications_type ON notifications(notification_type);

-- Blocked users
CREATE TABLE blocked_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_block UNIQUE (blocker_id, blocked_id),
    CONSTRAINT no_self_block CHECK (blocker_id != blocked_id)
);

CREATE INDEX idx_blocked_users_blocker ON blocked_users(blocker_id);
CREATE INDEX idx_blocked_users_blocked ON blocked_users(blocked_id);

-- Reported content
CREATE TABLE reported_content (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content_type VARCHAR(50) NOT NULL CHECK (content_type IN ('profile', 'message', 'post', 'reply', 'listing', 'event')),
    content_id UUID NOT NULL,
    reason VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewing', 'resolved', 'dismissed')),
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reported_content_status ON reported_content(status, created_at);
CREATE INDEX idx_reported_content_reporter ON reported_content(reporter_id);
CREATE INDEX idx_reported_content_type ON reported_content(content_type, content_id);

-- Update timestamp trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply update timestamp triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON user_preferences FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON matches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_dive_sites_updated_at BEFORE UPDATE ON dive_sites FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_dive_site_reviews_updated_at BEFORE UPDATE ON dive_site_reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_community_groups_updated_at BEFORE UPDATE ON community_groups FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_forum_posts_updated_at BEFORE UPDATE ON forum_posts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_forum_replies_updated_at BEFORE UPDATE ON forum_replies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_marketplace_listings_updated_at BEFORE UPDATE ON marketplace_listings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_emergency_contacts_updated_at BEFORE UPDATE ON emergency_contacts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
