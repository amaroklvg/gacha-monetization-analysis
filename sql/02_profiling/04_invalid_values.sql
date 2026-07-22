USE gacha_analytics;


-- ============================================================================
-- 1: DIMENSION CATEGORY PROFILING
-- I am looking for spelling mistakes, inconsistent capitalization, whitespace
-- variants, unexpected labels, and categories that should be standardized.
-- ============================================================================
-- Case-sensitive distributions in descriptive tables


-- Platform, country, and acquisition-channel variants in user records
SELECT
    'platform' AS category_name,
    platform COLLATE utf8mb4_bin AS category_value,
    COUNT(*) AS user_count
FROM stg_users
GROUP BY platform COLLATE utf8mb4_bin
UNION ALL
SELECT
    'country',
    CONCAT('[', country, ']') COLLATE utf8mb4_bin,
    COUNT(*)
FROM stg_users
GROUP BY CONCAT('[', country, ']') COLLATE utf8mb4_bin
UNION ALL
SELECT
    'acquisition_channel',
    CONCAT('[', acquisition_channel, ']') COLLATE utf8mb4_bin,
    COUNT(*)
FROM stg_users
GROUP BY CONCAT('[', acquisition_channel, ']') COLLATE utf8mb4_bin
ORDER BY
    category_name,
    user_count,
    category_value;


-- Banner-type variants
SELECT
    banner_type COLLATE utf8mb4_bin AS banner_type_exact,
    COUNT(*) AS row_count
FROM stg_banners
GROUP BY banner_type COLLATE utf8mb4_bin
ORDER BY
    row_count DESC,
    banner_type_exact;


-- Department, country, and seniority variants in staff records
SELECT
    'department' AS category_name,
    department COLLATE utf8mb4_bin AS category_value,
    COUNT(*) AS row_count
FROM stg_staff
GROUP BY
    department COLLATE utf8mb4_bin
UNION ALL
SELECT
    'country',
    country COLLATE utf8mb4_bin,
    COUNT(*)
FROM stg_staff
GROUP BY
    country COLLATE utf8mb4_bin
UNION ALL
SELECT
    'seniority',
    seniority COLLATE utf8mb4_bin,
    COUNT(*)
FROM stg_staff
GROUP BY
    seniority COLLATE utf8mb4_bin
ORDER BY
    category_name,
    row_count,
    category_value;


-- Categorical attributes used to compare character performance
SELECT
    'gender' AS category_name,
    gender COLLATE utf8mb4_bin AS category_value,
    COUNT(*) AS row_count
FROM stg_characters
GROUP BY
    gender COLLATE utf8mb4_bin
UNION ALL
SELECT
    'rarity',
    rarity COLLATE utf8mb4_bin,
    COUNT(*)
FROM stg_characters
GROUP BY
    rarity COLLATE utf8mb4_bin
UNION ALL
SELECT
    'origin_country',
    origin_country COLLATE utf8mb4_bin,
    COUNT(*)
FROM stg_characters
GROUP BY
    origin_country COLLATE utf8mb4_bin
UNION ALL
SELECT
    'specs',
    specs COLLATE utf8mb4_bin,
    COUNT(*)
FROM stg_characters
GROUP BY
    specs COLLATE utf8mb4_bin
UNION ALL
SELECT
    'core',
    core COLLATE utf8mb4_bin,
    COUNT(*)
FROM stg_characters
GROUP BY
    core COLLATE utf8mb4_bin
UNION ALL
SELECT
    'visuals',
    visuals COLLATE utf8mb4_bin,
    COUNT(*)
FROM stg_characters
GROUP BY
    visuals COLLATE utf8mb4_bin
UNION ALL
SELECT
    'role',
    role COLLATE utf8mb4_bin,
    COUNT(*)
FROM stg_characters
GROUP BY
    role COLLATE utf8mb4_bin
UNION ALL
SELECT
    'banner_type',
    banner_type COLLATE utf8mb4_bin,
    COUNT(*)
FROM stg_characters
GROUP BY
    banner_type COLLATE utf8mb4_bin
ORDER BY
    category_name,
    row_count DESC,
    category_value;


-- ============================================================================
-- 2: FACT TABLE CATEGORY PROFILING
-- I am looking for unexpected rarity, 50/50, currency, phase, direction,
-- or transaction-category values that could split analytical groups.
-- ============================================================================
-- Case-sensitive distributions in event tables


SELECT
    'stg_pulls' AS table_name,
    'rarity' AS category_name,
    rarity COLLATE utf8mb4_bin AS category_value,
    COUNT(*) AS row_count
FROM stg_pulls
GROUP BY
    rarity COLLATE utf8mb4_bin
UNION ALL
SELECT
    'stg_pulls',
    'won_5050',
    won_5050 COLLATE utf8mb4_bin,
    COUNT(*)
FROM stg_pulls
GROUP BY
    won_5050 COLLATE utf8mb4_bin
UNION ALL
SELECT
    'stg_pulls',
    'currency_type',
    currency_type COLLATE utf8mb4_bin,
    COUNT(*)
FROM stg_pulls
GROUP BY
    currency_type COLLATE utf8mb4_bin
UNION ALL
SELECT
    'stg_pulls',
    'pull_phase',
    pull_phase COLLATE utf8mb4_bin,
    COUNT(*)
FROM stg_pulls
GROUP BY
    pull_phase COLLATE utf8mb4_bin
UNION ALL
SELECT
    'stg_currency',
    'direction',
    direction COLLATE utf8mb4_bin,
    COUNT(*)
FROM stg_currency
GROUP BY
    direction COLLATE utf8mb4_bin
UNION ALL
SELECT
    'stg_currency',
    'category',
    category COLLATE utf8mb4_bin,
    COUNT(*)
FROM stg_currency
GROUP BY
    category COLLATE utf8mb4_bin
ORDER BY
    table_name,
    category_name,
    row_count DESC,
    category_value;


-- ============================================================================
-- 3: 50/50 FIELD APPLICABILITY
-- I am checking that the field is populated for five-star pulls and remains
-- not applicable for lower-rarity pulls rather than treating blanks as missing data.
-- ============================================================================

-- Check whether won_5050 is populated only when the pull rarity makes it applicable
SELECT
    rarity,
    COALESCE(NULLIF(TRIM(won_5050), ''), '[no pity here]') AS won_5050_value,
    COUNT(*) AS pull_count
FROM stg_pulls
GROUP BY
    rarity,
    COALESCE(
        NULLIF(TRIM(won_5050), ''),
        '[no pity here]'
    )
ORDER BY
    rarity,
    won_5050_value;


-- ============================================================================
-- 4: NUMERIC FORMAT AND RANGE PROFILING
-- I am looking for decimal-comma formats, non-numeric text, impossible values,
-- and ranges that would distort revenue or engagement calculations.
-- ============================================================================

-- Validate text fields that must later be converted to numeric data types

-- ============================================================================
-- 4A: PURCHASE PRICE FORMAT
-- I also preview comma-to-dot normalization before creating DECIMAL clean fields.
-- ============================================================================

-- Find purchase prices that do not use the expected dot-decimal format
SELECT
    price_usd,
    COUNT(*) AS occurrence_count
FROM stg_purchases
WHERE TRIM(price_usd) NOT REGEXP '^[0-9]+[.][0-9]{2}$'
GROUP BY price_usd
ORDER BY
    occurrence_count DESC,
    price_usd;


SELECT
    price_usd AS original_price,
    REPLACE(price_usd,',','.') AS normalized_price
FROM stg_purchases
WHERE price_usd LIKE '%,%';


-- ============================================================================
-- 4B: PURCHASE-TO-CATALOGUE PRICE CONSISTENCY
-- I am looking for genuine pricing mismatches after removing formatting differences.
-- ============================================================================

-- Preview normalized purchase prices beside their catalogue prices
SELECT
    p.purchase_id,
    p.item_id,
    p.price_usd AS purchase_price,
    s.price_usd AS catalog_price,
    CAST(REPLACE(TRIM(p.price_usd),',','.') AS DECIMAL (10,2)) AS normalized_price
FROM stg_purchases p
JOIN stg_shop_items s
    ON p.item_id = s.item_id
WHERE p.price_usd LIKE '%,%';

-- Find genuine price mismatches after decimal-separator normalization
SELECT
    p.purchase_id,
    p.item_id,
    p.price_usd AS purchase_price,
    s.price_usd AS catalog_price,
    CAST(REPLACE(TRIM(p.price_usd),',','.') AS DECIMAL (10,2)) AS normalized_price
FROM stg_purchases p
JOIN stg_shop_items s
    ON p.item_id = s.item_id
WHERE
    CAST(REPLACE(TRIM(p.price_usd),',','.') AS DECIMAL (10,2))
    <>
    CAST(TRIM(s.price_usd) AS DECIMAL (10,2));


-- ============================================================================
-- 4C: LOGIN SESSION VALUE VALIDATION
-- I am looking for non-numeric values, negative durations, physically impossible
-- daily durations, zero-minute activity, and implausible session-count ranges.
-- ============================================================================

-- Validate the format and inspect the overall distribution of session duration
SELECT
    session_minutes,
    COUNT(*) AS occurrence_count
FROM stg_logins
WHERE
    NULLIF(TRIM(session_minutes), '') IS NOT NULL
    AND TRIM(session_minutes) NOT REGEXP '^-?[0-9]+$'
GROUP BY session_minutes
ORDER BY
    occurrence_count,
    session_minutes;

SELECT
    MIN(CAST(NULLIF(TRIM(session_minutes), '') AS SIGNED)) AS minimum_session_min,
    MAX(CAST(NULLIF(TRIM(session_minutes), '') AS SIGNED)) AS maximum_session_min,
    ROUND(AVG(CAST(NULLIF(TRIM(session_minutes), '') AS SIGNED)), 2) AS average_session_min
FROM stg_logins;


-- Count negative durations and values exceeding the number of minutes in one day
SELECT
    CAST(TRIM(session_minutes) AS SIGNED) AS invalid_session_minutes,
    COUNT(*) as occurrence_count
FROM stg_logins
WHERE
    NULLIF(TRIM(session_minutes), '') IS NOT NULL
    AND (CAST(TRIM(session_minutes) AS SIGNED) < 0
        OR
        CAST(TRIM(session_minutes) AS SIGNED) > 1440)
GROUP BY invalid_session_minutes
ORDER BY invalid_session_minutes;


-- Inspect zero-minute login records and their reported session counts
SELECT
    session_minutes,
    session_count,
    COUNT(*) AS occurrence_count
FROM stg_logins
WHERE
    CAST(
        NULLIF(TRIM(session_minutes), '')
        AS SIGNED
    ) = 0
GROUP BY
    session_minutes,
    session_count
ORDER BY
    session_count;


-- Validate the format and inspect the overall distribution of daily session counts

SELECT
    session_count,
    COUNT(*) AS occurrence_count
FROM stg_logins
WHERE session_count NOT REGEXP '^[0-9]+$'
GROUP BY
    session_count
ORDER BY
    occurrence_count;


SELECT
    MIN(CAST(NULLIF(TRIM(session_count), '') AS UNSIGNED)) AS minimum_session_count,
    MAX(CAST(NULLIF(TRIM(session_count), '') AS UNSIGNED)) AS maximum_session_count,
    ROUND(AVG(CAST(NULLIF(TRIM(session_count), '') AS UNSIGNED)), 2) AS average_session_count
FROM stg_logins;


-- ============================================================================
-- 5: LOGIN DATE VALIDATION
-- I am looking for invalid dates and login events occurring before registration.
-- ============================================================================

-- Find login dates that cannot be converted to the expected DATE format

SELECT
    login_id,
    login_date
FROM stg_logins
WHERE NULLIF(TRIM(login_date), '') IS NOT NULL
    AND STR_TO_DATE(TRIM(login_date), '%Y-%m-%d') IS NULL;

-- Find login events occurring before the corresponding user registration date

SELECT
    l.login_id,
    l.user_id,
    u.registration_date,
    l.login_date
FROM stg_logins AS l
JOIN stg_users AS u
    ON l.user_id = u.user_id
    WHERE
    STR_TO_DATE(TRIM(l.login_date), '%Y-%m-%d')
    <
    STR_TO_DATE(TRIM(u.registration_date), '%Y-%m-%d');


-- ============================================================================
-- 6: PURCHASE DATE AND BANNER-PERIOD VALIDATION
-- We are looking for invalid timestamps, pre-registration purchases, and purchases
-- assigned to banners that were not active on the transaction date.
-- ============================================================================

-- Find purchase timestamps that cannot be converted to the expected DATETIME format

SELECT
    purchase_id,
    purchase_datetime
FROM stg_purchases
WHERE
    NULLIF(TRIM(purchase_datetime), '') IS NOT NULL
    AND STR_TO_DATE(TRIM(purchase_datetime), '%Y-%m-%d %H:%i:%s') IS NULL;

-- Find purchases occurring before the corresponding user registration date

SELECT
    p.user_id,
    p.purchase_id,
    p.purchase_datetime,
    u.registration_date
FROM stg_purchases p
JOIN stg_users u
    ON p.user_id = u.user_id
WHERE
    STR_TO_DATE(TRIM(p.purchase_datetime), '%Y-%m-%d %H:%i:%s')
    <
    STR_TO_DATE(TRIM(u.registration_date), '%Y-%m-%d');

-- Compare affected users with their first login to assess registration-date credibility
SELECT
    u.user_id,
    u.registration_date,
    MIN(l.login_date) AS first_login_date
FROM stg_users AS u
JOIN stg_logins AS l
    ON u.user_id = l.user_id
WHERE u.user_id IN (
    'U000063',
    'U001341',
    'U002939',
    'U003291'
)
GROUP BY
    u.user_id,
    u.registration_date
ORDER BY
    u.user_id;

-- Compare affected users with their first pull and currency events
SELECT
    u.user_id,
    u.registration_date,
    MIN(p.pull_datetime) AS first_event_datetime,
    'pull' AS event_type
FROM stg_users AS u
JOIN stg_pulls AS p
    ON u.user_id = p.user_id
WHERE u.user_id IN (
    'U000063',
    'U001341',
    'U002939',
    'U003291'
)
GROUP BY
    u.user_id,
    u.registration_date
UNION ALL
SELECT
    u.user_id,
    u.registration_date,
    MIN(c.event_datetime),
    'currency'
FROM stg_users AS u
JOIN stg_currency AS c
    ON u.user_id = c.user_id
WHERE u.user_id IN (
    'U000063',
    'U001341',
    'U002939',
    'U003291'
)
GROUP BY
    u.user_id,
    u.registration_date
ORDER BY
    user_id,
    event_type;

-- Find purchases assigned to banners that were inactive on the transaction date
SELECT
    p.purchase_id,
    p.user_id,
    p.banner_id,
    p.purchase_datetime,
    b.start_date,
    b.end_date
FROM stg_purchases AS p
JOIN stg_banners AS b
    ON p.banner_id = b.banner_id
WHERE
    NULLIF(TRIM(p.banner_id), '') IS NOT NULL
    AND DATE(
        STR_TO_DATE(
            TRIM(p.purchase_datetime),
            '%Y-%m-%d %H:%i:%s'
        )
    ) NOT BETWEEN
        STR_TO_DATE(TRIM(b.start_date), '%Y-%m-%d')
        AND
        STR_TO_DATE(TRIM(b.end_date), '%Y-%m-%d');


-- ============================================================================
-- 7: PITY MECHANIC VALIDATION
-- I am looking for invalid ranges, non-incrementing pity after lower-rarity pulls,
-- and five-star pulls that fail to reset pity to zero.
-- ============================================================================

-- Validate pity formats, ranges, increments, and five-star resets
SELECT
    pull_id,
    pity_before,
    pity_after
FROM stg_pulls
WHERE (NULLIF(TRIM(pity_before), '') IS NOT NULL
    AND TRIM(pity_before) NOT REGEXP '^[0-9]+$')
    OR
    (NULLIF(TRIM(pity_after), '') IS NOT NULL
    AND TRIM(pity_after) NOT REGEXP '^[0-9]+$');

SELECT
    MIN(CAST(TRIM(pity_before) AS UNSIGNED)) AS minimum_pity_before,
    MAX(CAST(TRIM(pity_before) AS UNSIGNED)) AS maximum_pity_before,
    MIN(CAST(TRIM(pity_after) AS UNSIGNED)) AS minimum_pity_after,
    MAX(CAST(TRIM(pity_after) AS UNSIGNED)) AS maximum_pity_after
FROM stg_pulls;

SELECT
    pull_id,
    rarity,
    pity_before,
    pity_after
FROM stg_pulls
WHERE
    (CAST(TRIM(rarity) AS UNSIGNED) = 5
    AND CAST(TRIM(pity_after) AS UNSIGNED) <> 0)
    OR
    (CAST(TRIM(rarity) AS UNSIGNED) IN (3, 4)
    AND CAST(TRIM(pity_after) AS UNSIGNED)
    <>
    CAST(TRIM(pity_before) AS UNSIGNED) + 1);


-- ============================================================================
-- 8: PREMIUM-CURRENCY FLOW VALIDATION
-- I am looking for malformed amounts, inconsistent source/sink behavior, invalid
-- timestamps, and currency events occurring before user registration.
-- ============================================================================

-- Validate currency amounts, source/sink totals, and transaction chronology

SELECT
    currency_txn_id,
    amount,
    direction
FROM stg_currency
WHERE
    NULLIF(TRIM(amount), '') IS NOT NULL
    AND TRIM(amount) NOT REGEXP '^-?[0-9]+$';

SELECT
    direction,
    COUNT(*) AS transaction_count,
    MIN(CAST(TRIM(amount) AS SIGNED)) AS minimum_amount,
    MAX(CAST(TRIM(amount) AS SIGNED)) AS maximum_amount,
    SUM(CAST(TRIM(amount) AS SIGNED)) AS total_amount
FROM stg_currency
GROUP BY direction
ORDER BY direction;

SELECT
    c.currency_txn_id,
    c.user_id,
    c.event_datetime,
    u.registration_date
FROM stg_currency c
JOIN stg_users u
    ON c.user_id = u.user_id
WHERE
    STR_TO_DATE(NULLIF(TRIM(c.event_datetime), ''),'%Y-%m-%d %H:%i:%s') IS NULL
    OR
    STR_TO_DATE(TRIM(c.event_datetime), '%Y-%m-%d %H:%i:%s')
    <
    STR_TO_DATE(TRIM(u.registration_date), '%Y-%m-%d');


-- ============================================================================
-- 9: CHARACTER PRODUCTION AND CAMPAIGN COST VALIDATION
-- I am looking for missing or malformed costs, invalid dates, and work or campaign
-- end dates occurring before their corresponding start dates.
-- ============================================================================

SELECT
    'character_staff_invalid_cost' AS issue_name,
    COUNT(*) AS issue_count
FROM stg_character_staff
WHERE
    NULLIF(TRIM(allocated_cost_usd), '') IS NULL
    OR TRIM(allocated_cost_usd) NOT REGEXP '^[0-9]+([.][0-9]{1,2})?$'
UNION ALL
SELECT
    'character_staff_invalid_dates',
    COUNT(*)
FROM stg_character_staff
WHERE
    STR_TO_DATE(NULLIF(TRIM(work_start_date), ''), '%Y-%m-%d') IS NULL
    OR STR_TO_DATE(NULLIF(TRIM(work_end_date), ''), '%Y-%m-%d') IS NULL
    OR STR_TO_DATE(TRIM(work_end_date), '%Y-%m-%d')
    <
    STR_TO_DATE(TRIM(work_start_date), '%Y-%m-%d')
UNION ALL
SELECT
    'campaign_invalid_cost',
    COUNT(*)
FROM stg_character_campaigns
WHERE
    NULLIF(TRIM(campaign_cost_usd), '') IS NULL
    OR TRIM(campaign_cost_usd) NOT REGEXP '^[0-9]+([.][0-9]{1,2})?$'
UNION ALL
SELECT
    'campaign_invalid_dates',
    COUNT(*)
FROM stg_character_campaigns
WHERE
    STR_TO_DATE(NULLIF(TRIM(campaign_start_date), ''),'%Y-%m-%d') IS NULL
    OR STR_TO_DATE(NULLIF(TRIM(campaign_end_date), ''), '%Y-%m-%d') IS NULL
    OR STR_TO_DATE(TRIM(campaign_end_date), '%Y-%m-%d')
    <
    STR_TO_DATE(TRIM(campaign_start_date), '%Y-%m-%d');


-- ============================================================================
-- 10: PULL TIMELINE VALIDATION
-- I am looking for invalid timestamps, pulls before registration, and pulls outside
-- the active period of their assigned banner. Duplicate users are collapsed for checks.
-- ============================================================================

WITH unique_users AS (
    SELECT
        user_id,
        MIN(registration_date) AS registration_date
    FROM stg_users
    GROUP BY user_id
)

SELECT
    'invalid_pull_datetime' AS issue_name,
    COUNT(*) AS issue_count
FROM stg_pulls
WHERE STR_TO_DATE(NULLIF(TRIM(pull_datetime), ''), '%Y-%m-%d %H:%i:%s') IS NULL
UNION ALL
SELECT
    'pull_before_registration',
    COUNT(*)
FROM stg_pulls AS p
JOIN unique_users AS u
    ON p.user_id = u.user_id
WHERE
    STR_TO_DATE(TRIM(p.pull_datetime), '%Y-%m-%d %H:%i:%s')
    <
    STR_TO_DATE(TRIM(u.registration_date), '%Y-%m-%d')
UNION ALL
SELECT
    'pull_outside_banner_period',
    COUNT(*)
FROM stg_pulls AS p
JOIN stg_banners AS b
    ON p.banner_id = b.banner_id
WHERE
    DATE(STR_TO_DATE(TRIM(p.pull_datetime), '%Y-%m-%d %H:%i:%s'))
    NOT BETWEEN
    STR_TO_DATE(TRIM(b.start_date), '%Y-%m-%d')
    AND
    STR_TO_DATE(TRIM(b.end_date), '%Y-%m-%d');
