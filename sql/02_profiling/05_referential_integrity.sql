USE gacha_analytics;


-- ============================================================================
-- 1: ORPHAN USER IDENTIFICATION IN LOGIN EVENTS
-- I am looking for nonblank foreign-key values that cannot be matched
-- to a known user and therefore cannot support retention analysis.
-- ============================================================================

SELECT
    l.user_id,
    COUNT(*) AS orphan_row_count
FROM stg_logins l
LEFT JOIN stg_users u
    ON l.user_id = u.user_id
WHERE
    NULLIF(TRIM(l.user_id), '') IS NOT NULL
    AND u.user_id IS NULL
GROUP BY
    l.user_id;


-- ============================================================================
-- 2: USER FOREIGN-KEY SUMMARY ACROSS ALL EVENT TABLES
-- I am counting orphan user references in logins, pulls, purchases, and currency
-- transactions. This measures the scale of records that cannot be attributed to
-- a valid player and may need to be excluded from the clean fact tables.
-- ============================================================================


SELECT
    'stg_logins.user_id' AS relationship_name,
    COUNT(*) AS orphan_rows
FROM stg_logins l
LEFT JOIN stg_users u
    ON l.user_id = u.user_id
WHERE
    NULLIF(TRIM(l.user_id), '') IS NOT NULL
    AND u.user_id IS NULL
UNION ALL
SELECT
    'stg_pulls.user_id',
    COUNT(*)
FROM stg_pulls p
LEFT JOIN stg_users u
    ON p.user_id = u.user_id
WHERE
    NULLIF(TRIM(p.user_id), '') IS NOT NULL
    AND u.user_id IS NULL
UNION ALL
SELECT
    'stg_purchases.user_id',
    COUNT(*)
FROM stg_purchases p
LEFT JOIN stg_users u
    ON p.user_id = u.user_id
WHERE
    NULLIF(TRIM(p.user_id), '') IS NOT NULL
    AND u.user_id IS NULL
UNION ALL
SELECT
    'stg_currency.user_id',
    COUNT(*)
FROM stg_currency c
LEFT JOIN stg_users u
    ON c.user_id = u.user_id
WHERE
    NULLIF(TRIM(c.user_id), '') IS NOT NULL
    AND u.user_id IS NULL;


-- ============================================================================
-- 3: NON-USER RELATIONSHIP VALIDATION
-- I am looking for populated foreign-key values with no matching parent record.
-- Blank optional references are intentionally excluded from orphan counts.
-- ============================================================================


SELECT
    'stg_logins.active_banner_id -> stg_banners' AS relationship_name,
    COUNT(*) AS orphan_rows
FROM stg_logins l
LEFT JOIN stg_banners b
    ON l.active_banner_id = b.banner_id
WHERE
    NULLIF(TRIM(l.active_banner_id), '') IS NOT NULL
    AND b.banner_id IS NULL
UNION ALL
SELECT
    'stg_pulls.banner_id -> stg_banners',
    COUNT(*)
FROM stg_pulls p
LEFT JOIN stg_banners b
    ON p.banner_id = b.banner_id
WHERE
    NULLIF(TRIM(p.banner_id), '') IS NOT NULL
    AND b.banner_id IS NULL
UNION ALL
SELECT
    'stg_purchases.banner_id -> stg_banners',
    COUNT(*)
FROM stg_purchases p
LEFT JOIN stg_banners b
    ON p.banner_id = b.banner_id
WHERE
    NULLIF(TRIM(p.banner_id), '') IS NOT NULL
    AND b.banner_id IS NULL
UNION ALL
SELECT
    'stg_currency.banner_id -> stg_banners',
    COUNT(*)
FROM stg_currency c
LEFT JOIN stg_banners b
    ON c.banner_id = b.banner_id
WHERE
    NULLIF(TRIM(c.banner_id), '') IS NOT NULL
    AND b.banner_id IS NULL
UNION ALL
SELECT
    'stg_purchases.item_id -> stg_shop_items',
    COUNT(*)
FROM stg_purchases p
LEFT JOIN stg_shop_items s
    ON p.item_id = s.item_id
WHERE
    NULLIF(TRIM(p.item_id), '') IS NOT NULL
    AND s.item_id IS NULL
UNION ALL
SELECT
    'stg_banners.character_name -> stg_characters',
    COUNT(*)
FROM stg_banners b
LEFT JOIN stg_characters c
    ON b.character_name = c.character_name
WHERE
    NULLIF(TRIM(b.character_name), '') IS NOT NULL
    AND c.character_name IS NULL
UNION ALL
SELECT
    'stg_pulls.character_obtained -> stg_characters',
    COUNT(*)
FROM stg_pulls p
LEFT JOIN stg_characters c
    ON p.character_obtained = c.character_name
WHERE
    NULLIF(TRIM(p.character_obtained), '') IS NOT NULL
    AND c.character_name IS NULL
UNION ALL
SELECT
    'stg_character_staff.character_name -> stg_characters',
    COUNT(*)
FROM stg_character_staff cs
LEFT JOIN stg_characters c
    ON cs.character_name = c.character_name
WHERE
    NULLIF(TRIM(cs.character_name), '') IS NOT NULL
    AND c.character_name IS NULL
UNION ALL
SELECT
    'stg_character_staff.staff_id -> stg_staff',
    COUNT(*)
FROM stg_character_staff cs
LEFT JOIN stg_staff s
    ON cs.staff_id = s.staff_id
WHERE
    NULLIF(TRIM(cs.staff_id), '') IS NOT NULL
    AND s.staff_id IS NULL
UNION ALL
SELECT
    'stg_character_campaigns.character_name -> stg_characters',
    COUNT(*)
FROM stg_character_campaigns cc
LEFT JOIN stg_characters c
    ON cc.character_name = c.character_name
WHERE
    NULLIF(TRIM(cc.character_name), '') IS NOT NULL
    AND c.character_name IS NULL;
