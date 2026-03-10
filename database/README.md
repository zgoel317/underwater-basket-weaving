# Underwater Basket Weaving Dating App - Database Schema

## Overview
PostgreSQL database schema with PostGIS extension for location-based features.

## Setup

### Prerequisites
- PostgreSQL 14+
- PostGIS extension
- UUID extension

### Installation

```bash
# Create database
createdb underwater_basket_weaving

# Connect and enable extensions
psql underwater_basket_weaving -c "CREATE EXTENSION IF NOT EXISTS uuid-ossp;"
psql underwater_basket_weaving -c "CREATE EXTENSION IF NOT EXISTS postgis;"

# Run schema
psql underwater_basket_weaving -f database/schema.sql

# Run additional indexes
psql underwater_basket_weaving -f database/indexes.sql

# Optional: Load seed data
psql underwater_basket_weaving -f database/seed.sql
```

## Schema Overview

### Core Tables

#### Users & Profiles
- `users` - Authentication and account management
- `profiles` - User profile information with location data
- `profile_photos` - Photo galleries (underwater, surface, basket photos)
- `user_preferences` - Matching preferences
- `emergency_contacts` - Safety feature

#### Certifications
- `diving_certifications` - Diving credentials
- `safety_certifications` - First aid, CPR, rescue badges
- `dive_buddy_verifications` - Peer verification system

#### Matching & Communication
- `matches` - User matching system
- `conversations` - Chat conversations
- `conversation_participants` - Group chat support
- `messages` - Text, photo, voice messages

#### Locations & Events
- `dive_sites` - Dive location database with PostGIS
- `dive_site_reviews` - User reviews and ratings
- `events` - Group weaves, workshops, expeditions
- `event_participants` - Event registration
- `weather_alerts` - Safety alerts for dive sites

#### Community
- `community_groups` - Local and interest-based groups
- `group_members` - Group membership
- `forum_posts` - Technique sharing
- `forum_replies` - Discussion threads

#### Marketplace
- `marketplace_listings` - Equipment and supplies

#### System
- `subscriptions` - Premium features
- `notifications` - Push notifications
- `user_activity_logs` - Activity tracking
- `blocked_users` - User blocking
- `reported_content` - Content moderation

## Key Features

### PostGIS Integration
- Location-based matching
- Dive site proximity search
- Geographic event discovery
- Travel radius calculations

### Performance Optimization
- Strategic indexing on frequently queried columns
- Partial indexes for filtered queries
- Composite indexes for complex queries
- GIST indexes for geographic data

### Data Integrity
- Foreign key constraints
- Check constraints for enums and validation
- Unique constraints preventing duplicates
- Triggers for automatic timestamp updates

### Security
- Password hashing (application layer)
- User blocking and reporting
- Content moderation system
- Emergency contact privacy

## Common Queries

### Find Nearby Users
```sql
SELECT p.*, 
       ST_Distance(p.location, ST_SetSRID(ST_MakePoint(-122.4194, 37.7749), 4326)) as distance
FROM profiles p
WHERE ST_DWithin(p.location, ST_SetSRID(ST_MakePoint(-122.4194, 37.7749), 4326), 50000)
ORDER BY distance;
```

### Get Matched Conversations
```sql
SELECT c.*, m.user1_id, m.user2_id, 
       (SELECT content FROM messages WHERE conversation_id = c.id ORDER BY created_at DESC LIMIT 1) as last_message
FROM conversations c
JOIN matches m ON c.match_id = m.id
WHERE m.status = 'matched' AND (m.user1_id = $1 OR m.user2_id = $1)
ORDER BY c.updated_at DESC;
```

### Upcoming Events Near Location
```sql
SELECT e.*,
       ST_Distance(e.location, ST_SetSRID(ST_MakePoint($1, $2), 4326)) as distance
FROM events e
WHERE e.status = 'scheduled' 
  AND e.start_datetime > CURRENT_TIMESTAMP
  AND ST_DWithin(e.location, ST_SetSRID(ST_MakePoint($1, $2), 4326), $3)
ORDER BY e.start_datetime;
```

## Maintenance

### Regular Tasks
- Vacuum analyze tables weekly
- Reindex geographic data monthly
- Archive old messages quarterly
- Cleanup expired matches
- Remove old activity logs

### Monitoring
- Query performance analysis
- Index usage statistics
- Table bloat monitoring
- Connection pool metrics

## Migration Strategy

### Version Control
- All schema changes in numbered migration files
- Migration files in `database/migrations/`
- Up/down migration support

### Deployment
- Test migrations on staging first
- Run during low-traffic windows
- Keep backups before major changes
- Monitor performance after deployment
