# Create an initial inventory of staging tables, columns and row counts.
# This script only reads data. It does not clean or modify anything.

USE gacha_analytics;

-- Tables
SELECT
	table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'gacha_analytics'
ORDER BY table_name;


-- Columns
SELECT
	table_name,
    ordinal_position,
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'gacha_analytics'
	AND table_name LIKE '%stg_%'
ORDER BY
	table_name,
    ordinal_position;
    
-- Number of Records
SELECT 'stg_users' AS table_name, COUNT(*) AS row_count
FROM stg_users
	UNION ALL
SELECT 'stg_banners', COUNT(*) 
FROM stg_banners
	UNION ALL
SELECT 'stg_characters', COUNT(*) 
FROM stg_characters
	UNION ALL
SELECT 'stg_shop_items', COUNT(*) 
FROM stg_shop_items
	UNION ALL
SELECT 'stg_staff', COUNT(*) 
FROM stg_staff
	UNION ALL
SELECT 'stg_character_staff', COUNT(*) 
FROM stg_character_staff
	UNION ALL
SELECT 'stg_character_campaigns', COUNT(*) 
FROM stg_character_campaigns
	UNION ALL
SELECT 'stg_logins', COUNT(*) 
FROM stg_logins
	UNION ALL
SELECT 'stg_pulls', COUNT(*) 
FROM stg_pulls
	UNION ALL
SELECT 'stg_purchases', COUNT(*) 
FROM stg_purchases
	UNION ALL
SELECT 'stg_currency', COUNT(*) 
FROM stg_currency
ORDER BY table_name;

-- Quick Glance at Tables Content
SELECT * 
FROM stg_users 
LIMIT 10;

SELECT * 
FROM stg_banners 
LIMIT 10;

SELECT * 
FROM stg_characters 
LIMIT 10;

SELECT * 
FROM stg_shop_items 
LIMIT 10;

SELECT * 
FROM stg_staff 
LIMIT 10;

SELECT * 
FROM stg_character_staff 
LIMIT 10;

SELECT * 
FROM stg_character_campaigns 
LIMIT 10;

SELECT * 
FROM stg_logins 
LIMIT 10;

SELECT * 
FROM stg_pulls 
LIMIT 10;

SELECT * 
FROM stg_purchases 
LIMIT 10;

SELECT * 
FROM stg_currency 
LIMIT 10;