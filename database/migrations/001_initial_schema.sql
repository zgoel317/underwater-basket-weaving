-- Migration: Initial schema setup
-- Created: 2024-01-01
-- Description: Creates all initial tables for underwater basket weaving dating app

BEGIN;

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Execute schema creation
\i schema.sql

-- Insert seed data for testing
INSERT INTO users (email, password_hash) VALUES 
('test@example.com', '$2b$12$example_hash'),
('demo@example.com', '$2b$12$demo_hash');

INSERT INTO dive_sites (name, description, latitude, longitude, max_depth, difficulty_level, water_type) VALUES
('Crystal Springs', 'Perfect for beginners, clear water with sandy bottom', 33.7490, -84.3880, 15, 'Beginner', 'freshwater'),
('Blue Hole', 'Advanced diving site with deep waters', 25.2760, -79.9775, 45, 'Advanced', 'saltwater'),
('Kelp Forest Cove', 'Intermediate site with natural kelp formations', 36.9531, -121.9994, 25, 'Intermediate', 'saltwater');

COMMIT;