-- Migration: 001_initial_schema
-- Description: Initial database schema for Underwater Basket Weaving Dating App
-- Created: 2024

BEGIN;

-- Run the main schema file
\i schema.sql

-- Run additional indexes
\i indexes.sql

COMMIT;
