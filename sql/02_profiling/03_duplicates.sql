# Check whether expected identifiers are unique in staging tables.
# This script only profiles data. It does not remove any duplicates.

USE gacha_analytics;

-- Quick Glance at Duplicates
SELECT
    'stg_users' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT user_id) AS distinct_ids,
    COUNT(*) - COUNT(DISTINCT user_id) AS duplicate_rows
FROM stg_users
UNION ALL
SELECT
    'stg_purchases',
    COUNT(*),
    COUNT(DISTINCT purchase_id),
    COUNT(*) - COUNT(DISTINCT purchase_id)
FROM stg_purchases
UNION ALL
SELECT
    'stg_logins',
    COUNT(*),
    COUNT(DISTINCT login_id),
    COUNT(*) - COUNT(DISTINCT login_id)
FROM stg_logins
UNION ALL
SELECT
    'stg_pulls',
    COUNT(*),
    COUNT(DISTINCT pull_id),
    COUNT(*) - COUNT(DISTINCT pull_id)
FROM stg_pulls
UNION ALL
SELECT
    'stg_currency',
    COUNT(*),
    COUNT(DISTINCT currency_txn_id),
    COUNT(*) - COUNT(DISTINCT currency_txn_id)
FROM stg_currency
UNION ALL
SELECT
    'stg_banners',
    COUNT(*),
    COUNT(DISTINCT banner_id),
    COUNT(*) - COUNT(DISTINCT banner_id)
FROM stg_banners
UNION ALL
SELECT
    'stg_characters',
    COUNT(*),
    COUNT(DISTINCT character_name),
    COUNT(*) - COUNT(DISTINCT character_name)
FROM stg_characters
UNION ALL
SELECT
    'stg_shop_items',
    COUNT(*),
    COUNT(DISTINCT item_id),
    COUNT(*) - COUNT(DISTINCT item_id)
FROM stg_shop_items
UNION ALL
SELECT
    'stg_staff',
    COUNT(*),
    COUNT(DISTINCT staff_id),
    COUNT(*) - COUNT(DISTINCT staff_id)
FROM stg_staff
UNION ALL
SELECT
    'stg_character_campaigns',
    COUNT(*),
    COUNT(DISTINCT campaign_id),
    COUNT(*) - COUNT(DISTINCT campaign_id)
FROM stg_character_campaigns;


-- Character Staff Table (Composite Key)
SELECT 
	character_name,
    staff_id,
    contribution_role,
    COUNT(*) AS occurrence_count
FROM stg_character_staff
GROUP BY 
	character_name,
    staff_id,
    contribution_role
HAVING COUNT(*) > 1;


-- Validating Duplicates in Purchases Table
SELECT *
FROM stg_purchases
WHERE purchase_id IN 
	(
	SELECT purchase_id
    FROM stg_purchases
    GROUP BY purchase_id
    HAVING COUNT(*) > 1
    )
ORDER BY purchase_id;

SELECT
    purchase_id,
    user_id,
    purchase_datetime,
    banner_id,
    item_id,
    item_name,
    price_usd,
    premium_currency,
    purchase_number,
    COUNT(*) AS occurrence_count
FROM stg_purchases
GROUP BY
    purchase_id,
    user_id,
    purchase_datetime,
    banner_id,
    item_id,
    item_name,
    price_usd,
    premium_currency,
    purchase_number
HAVING COUNT(*) > 1
ORDER BY purchase_id;

-- Validating Duplicates in Logins Table
SELECT 
	login_id,
    COUNT(*) AS occurrence_count
FROM stg_logins
GROUP BY login_id
HAVING COUNT(*) > 1
ORDER BY login_id;

SELECT
    login_id,
    user_id,
    login_date,
    session_minutes,
    session_count,
    active_banner_id,
    COUNT(*) AS occurrence_count
FROM stg_logins
GROUP BY
    login_id,
    user_id,
    login_date,
    session_minutes,
    session_count,
    active_banner_id
HAVING COUNT(*) > 1
ORDER BY login_id;


-- Validating Duplicates in Pulls Table
SELECT 
	pull_id,
    COUNT(*) AS occurrence_count
FROM stg_pulls
GROUP BY pull_id
HAVING COUNT(*) > 1
ORDER BY pull_id;

SELECT
	pull_id,
	user_id,
	pull_datetime,
	banner_id,
	character_obtained,
	rarity,
	pity_before,
	pity_after,
	won_5050,
	currency_type,
	currency_spent,
	pull_phase,
    COUNT(*) AS occurrence_count
FROM stg_pulls
GROUP BY
	pull_id,
	user_id,
	pull_datetime,
	banner_id,
	character_obtained,
	rarity,
	pity_before,
	pity_after,
	won_5050,
	currency_type,
	currency_spent,
	pull_phase
HAVING COUNT(*) > 1
ORDER BY pull_id;