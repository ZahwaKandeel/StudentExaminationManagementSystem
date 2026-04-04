-- =============================================================
-- File     : 00_collation.sql
-- Purpose  : Create Arabic ICU collation for the project
-- Run this ONCE before any CREATE TABLE scripts
-- =============================================================

-- First verify ICU is available on your PostgreSQL installation
-- Run this query to check:
-- SELECT * FROM pg_available_extensions WHERE name = 'icu';

CREATE COLLATION IF NOT EXISTS arabic_icu (
    provider = icu,
    locale   = 'ar-x-icu'
);

-- Verify it was created:
-- SELECT collname, collprovider, colliculocale
-- FROM pg_collation
-- WHERE collname = 'arabic_icu';