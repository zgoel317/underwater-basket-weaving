-- Migration: Initial database schema setup
-- Version: 001
-- Date: 2024-01-01

BEGIN;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Execute main schema
\i schema.sql

-- Insert sample data for testing
INSERT INTO users (id, email, password_hash) VALUES 
('550e8400-e29b-41d4-a716-446655440000', 'alice@example.com', '$2b$10$hash1'),
('550e8400-e29b-41d4-a716-446655440001', 'bob@example.com', '$2b$10$hash2');

INSERT INTO profiles (user_id, display_name, experience_level, location_lat, location_lng, location_name) VALUES 
('550e8400-e29b-41d4-a716-446655440000', 'Alice Weaver', 'Advanced', 37.7749, -122.4194, 'San Francisco, CA'),
('550e8400-e29b-41d4-a716-446655440001', 'Bob Diver', 'Intermediate', 37.8044, -122.2711, 'Oakland, CA');

INSERT INTO dive_sites (name, location_lat, location_lng, max_depth, difficulty_level) VALUES 
('Monterey Bay Kelp Forest', 36.6177, -121.9166, 30, 'Intermediate'),
('Point Lobos Reserve', 36.5225, -121.9552, 25, 'Beginner');

COMMIT;