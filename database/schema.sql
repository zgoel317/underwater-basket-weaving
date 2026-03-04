-- Users table - core user authentication
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- User profiles - detailed profile information
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    display_name VARCHAR(100) NOT NULL,
    bio TEXT,
    age INTEGER,
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_name VARCHAR(255),
    travel_radius_km INTEGER DEFAULT 50,
    experience_level VARCHAR(20) CHECK (experience_level IN ('Beginner', 'Intermediate', 'Advanced', 'Master Weaver')),
    preferred_depth_min INTEGER,
    preferred_depth_max INTEGER,
    diving_schedule TEXT,
    basket_specialties TEXT[],
    equipment_sharing BOOLEAN DEFAULT false,
    profile_image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Safety certifications
CREATE TABLE safety_certifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    certification_type VARCHAR(100) NOT NULL,
    certification_level VARCHAR(50),
    issuing_organization VARCHAR(100),
    issue_date DATE,
    expiry_date DATE,
    verification_status VARCHAR(20) DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'expired'))
);

-- Profile photos
CREATE TABLE profile_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    photo_url VARCHAR(500) NOT NULL,
    photo_type VARCHAR(20) CHECK (photo_type IN ('profile', 'basket', 'underwater', 'surface')),
    caption TEXT,
    is_primary BOOLEAN DEFAULT false,
    display_order INTEGER DEFAULT 1,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Matching system
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile1_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    profile2_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    match_status VARCHAR(20) DEFAULT 'pending' CHECK (match_status IN ('pending', 'matched', 'declined', 'blocked')),
    matched_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(profile1_id, profile2_id)
);

-- Conversations
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_message_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Messages
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    sender_profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'voice', 'video')),
    content TEXT,
    media_url VARCHAR(500),
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP,
    is_deleted BOOLEAN DEFAULT false
);

-- Dive sites
CREATE TABLE dive_sites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    location_lat DECIMAL(10, 8) NOT NULL,
    location_lng DECIMAL(11, 8) NOT NULL,
    max_depth INTEGER,
    difficulty_level VARCHAR(20) CHECK (difficulty_level IN ('Beginner', 'Intermediate', 'Advanced', 'Expert')),
    water_conditions TEXT,
    best_seasons TEXT[],
    facilities TEXT[],
    safety_notes TEXT,
    created_by_profile_id UUID REFERENCES profiles(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Dive site reviews
CREATE TABLE dive_site_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dive_site_id UUID REFERENCES dive_sites(id) ON DELETE CASCADE,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    dive_date DATE,
    conditions_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(dive_site_id, profile_id)
);

-- Events/meetups
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    event_type VARCHAR(50) CHECK (event_type IN ('dive', 'workshop', 'competition', 'social', 'exhibition')),
    dive_site_id UUID REFERENCES dive_sites(id),
    organizer_profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    start_datetime TIMESTAMP NOT NULL,
    end_datetime TIMESTAMP,
    max_participants INTEGER,
    skill_level_required VARCHAR(20) CHECK (skill_level_required IN ('Beginner', 'Intermediate', 'Advanced', 'Master Weaver')),
    equipment_provided BOOLEAN DEFAULT false,
    cost DECIMAL(10, 2) DEFAULT 0,
    registration_deadline TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Event participants
CREATE TABLE event_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    registration_status VARCHAR(20) DEFAULT 'registered' CHECK (registration_status IN ('registered', 'confirmed', 'cancelled', 'attended')),
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    UNIQUE(event_id, profile_id)
);

-- Community posts/forum
CREATE TABLE community_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title VARCHAR(300),
    content TEXT NOT NULL,
    post_type VARCHAR(20) DEFAULT 'discussion' CHECK (post_type IN ('discussion', 'technique', 'question', 'showcase', 'marketplace')),
    tags TEXT[],
    image_urls TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Community post comments
CREATE TABLE post_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID REFERENCES community_posts(id) ON DELETE CASCADE,
    author_profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    parent_comment_id UUID REFERENCES post_comments(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_profiles_location ON profiles(location_lat, location_lng);
CREATE INDEX idx_profiles_experience_level ON profiles(experience_level);
CREATE INDEX idx_matches_profile1 ON matches(profile1_id);
CREATE INDEX idx_matches_profile2 ON matches(profile2_id);
CREATE INDEX idx_matches_status ON matches(match_status);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_sent_at ON messages(sent_at);
CREATE INDEX idx_dive_sites_location ON dive_sites(location_lat, location_lng);
CREATE INDEX idx_events_start_datetime ON events(start_datetime);
CREATE INDEX idx_events_dive_site ON events(dive_site_id);
CREATE INDEX idx_community_posts_created_at ON community_posts(created_at);
CREATE INDEX idx_community_posts_type ON community_posts(post_type);