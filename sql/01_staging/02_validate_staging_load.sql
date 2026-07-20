USE gacha_analytics;


-- Dim Tables
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
FROM stg_character_campaigns;


-- Fact Tables
SELECT 'stg_logins', COUNT(*) FROM stg_logins
UNION ALL
SELECT 'stg_pulls', COUNT(*) FROM stg_pulls
UNION ALL
SELECT 'stg_purchases', COUNT(*) FROM stg_purchases
UNION ALL
SELECT 'stg_currency', COUNT(*) FROM stg_currency;