USE gacha_analytics;

SELECT
    'duplicate_dim_users' AS check_name,
    COUNT(*) - COUNT(DISTINCT user_id) AS issue_count
FROM dim_users
UNION ALL
SELECT
    'duplicate_fact_logins',
    COUNT(*) - COUNT(DISTINCT login_id)
FROM fact_logins
UNION ALL
SELECT
    'duplicate_fact_pulls',
    COUNT(*) - COUNT(DISTINCT pull_id)
FROM fact_pulls
UNION ALL
SELECT
    'duplicate_fact_purchases',
    COUNT(*) - COUNT(DISTINCT purchase_id)
FROM fact_purchases
UNION ALL
SELECT
    'duplicate_fact_currency',
    COUNT(*) - COUNT(DISTINCT currency_txn_id)
FROM fact_currency
UNION ALL
SELECT
    'orphan_login_users',
    COUNT(*)
FROM fact_logins AS l
LEFT JOIN dim_users AS u
    ON l.user_id = u.user_id
WHERE u.user_id IS NULL
UNION ALL
SELECT
    'orphan_pull_users',
    COUNT(*)
FROM fact_pulls AS p
LEFT JOIN dim_users AS u
    ON p.user_id = u.user_id
WHERE u.user_id IS NULL
UNION ALL
SELECT
    'orphan_purchase_users',
    COUNT(*)
FROM fact_purchases AS p
LEFT JOIN dim_users AS u
    ON p.user_id = u.user_id
WHERE u.user_id IS NULL
UNION ALL
SELECT
    'orphan_currency_users',
    COUNT(*)
FROM fact_currency AS c
LEFT JOIN dim_users AS u
    ON c.user_id = u.user_id
WHERE u.user_id IS NULL
UNION ALL
SELECT
    'invalid_session_minutes',
    COUNT(*)
FROM fact_logins
WHERE
    session_minutes < 0
    OR session_minutes > 1440
UNION ALL
SELECT
    'purchase_before_registration',
    COUNT(*)
FROM fact_purchases AS p
JOIN dim_users AS u
    ON p.user_id = u.user_id
WHERE p.purchase_datetime < u.registration_date
UNION ALL
SELECT
    'purchase_outside_banner_period',
    COUNT(*)
FROM fact_purchases AS p
JOIN dim_banners AS b
    ON p.banner_id = b.banner_id
WHERE DATE(p.purchase_datetime)
    NOT BETWEEN b.start_date AND b.end_date
UNION ALL
SELECT
    'purchase_price_mismatch',
    COUNT(*)
FROM fact_purchases AS p
JOIN dim_shop_items AS s
    ON p.item_id = s.item_id
WHERE p.price_usd <> s.price_usd
UNION ALL
SELECT
    'invalid_pity_transition',
    COUNT(*)
FROM fact_pulls
WHERE
    (rarity = 5 AND pity_after <> 0)
    OR
    (rarity IN (3, 4) AND pity_after <> pity_before + 1)
UNION ALL
SELECT
    'pull_outside_banner_period',
    COUNT(*)
FROM fact_pulls AS p
JOIN dim_banners AS b
    ON p.banner_id = b.banner_id
WHERE DATE(p.pull_datetime)
    NOT BETWEEN b.start_date AND b.end_date;