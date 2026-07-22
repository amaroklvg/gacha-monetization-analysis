# Check all staging tables for NULL values, empty strings and whitespace-only values.
# This script only profiles data. It does not modify any staging table.

USE gacha_analytics;

-- Users Table
SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN user_id IS NULL OR TRIM(user_id) = ''
            THEN 1
            ELSE 0
        END
		) AS user_id_missing,
    SUM(
        CASE
            WHEN registration_date IS NULL OR TRIM(registration_date) = ''
            THEN 1
            ELSE 0
        END
		) AS registration_date_missing,
    SUM(
        CASE
            WHEN country IS NULL OR TRIM(country) = ''
            THEN 1
            ELSE 0
        END
		) AS country_missing,
    SUM(
        CASE
            WHEN platform IS NULL OR TRIM(platform) = ''
            THEN 1
            ELSE 0
        END
		) AS platform_missing,
    SUM(
        CASE
            WHEN acquisition_channel IS NULL
                OR TRIM(acquisition_channel) = ''
            THEN 1
            ELSE 0
        END
		) AS acquisition_channel_missing
FROM stg_users;


-- Banners Table
SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN banner_id IS NULL OR TRIM(banner_id) = ''
            THEN 1
            ELSE 0
        END
		) AS banner_id_missing,
    SUM(
        CASE
            WHEN banner_name IS NULL OR TRIM(banner_name) = ''
            THEN 1
            ELSE 0
        END
		) AS banner_name_missing,
    SUM(
        CASE
            WHEN character_name IS NULL OR TRIM(character_name) = ''
            THEN 1
            ELSE 0
        END
		) AS character_name_missing,
    SUM(
        CASE
            WHEN banner_type IS NULL OR TRIM(banner_type) = ''
            THEN 1
            ELSE 0
        END
		) AS banner_type_missing,
    SUM(
        CASE
            WHEN start_date IS NULL OR TRIM(start_date) = ''
            THEN 1
            ELSE 0
        END
		) AS start_date_missing,
    SUM(
        CASE
            WHEN end_date IS NULL OR TRIM(end_date) = ''
            THEN 1
            ELSE 0
        END
		) AS end_date_missing
FROM stg_banners;


-- Characters Table
SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN character_name IS NULL OR TRIM(character_name) = ''
            THEN 1
            ELSE 0
        END
		) AS character_name_missing,
    SUM(
        CASE
            WHEN gender IS NULL OR TRIM(gender) = ''
            THEN 1
            ELSE 0
        END
		) AS gender_missing,
    SUM(
        CASE
            WHEN rarity IS NULL OR TRIM(rarity) = ''
            THEN 1
            ELSE 0
        END
    ) AS rarity_missing,
    SUM(
        CASE
            WHEN origin_country IS NULL OR TRIM(origin_country) = ''
            THEN 1
            ELSE 0
        END
		) AS origin_country_missing,
    SUM(
        CASE
            WHEN specs IS NULL OR TRIM(specs) = ''
            THEN 1
            ELSE 0
        END
		) AS specs_missing,
    SUM(
        CASE
            WHEN core IS NULL OR TRIM(core) = ''
            THEN 1
            ELSE 0
        END
		) AS core_missing,
    SUM(
        CASE
            WHEN visuals IS NULL OR TRIM(visuals) = ''
            THEN 1
            ELSE 0
        END
		) AS visuals_missing,
    SUM(
        CASE
            WHEN role IS NULL OR TRIM(role) = ''
            THEN 1
            ELSE 0
        END
		) AS role_missing,
    SUM(
        CASE
            WHEN banner_type IS NULL OR TRIM(banner_type) = ''
            THEN 1
            ELSE 0
        END
		) AS banner_type_missing,
    SUM(
        CASE
            WHEN power_score IS NULL OR TRIM(power_score) = ''
            THEN 1
            ELSE 0
        END
		) AS power_score_missing
FROM stg_characters;


-- Shop Items Table
SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN item_id IS NULL OR TRIM(item_id) = ''
            THEN 1
            ELSE 0
        END
		) AS item_id_missing,
    SUM(
        CASE
            WHEN item_name IS NULL OR TRIM(item_name) = ''
            THEN 1
            ELSE 0
        END
		) AS item_name_missing,
    SUM(
        CASE
            WHEN price_usd IS NULL OR TRIM(price_usd) = ''
            THEN 1
            ELSE 0
        END
		) AS price_usd_missing,
    SUM(
        CASE
            WHEN premium_currency IS NULL OR TRIM(premium_currency) = ''
            THEN 1
            ELSE 0
        END
		) AS premium_currency_missing
FROM stg_shop_items;


-- Staff Table
SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN staff_id IS NULL OR TRIM(staff_id) = ''
            THEN 1
            ELSE 0
        END
		) AS staff_id_missing,
    SUM(
        CASE
            WHEN staff_name IS NULL OR TRIM(staff_name) = ''
            THEN 1
            ELSE 0
        END
		) AS staff_name_missing,
    SUM(
        CASE
            WHEN department IS NULL OR TRIM(department) = ''
            THEN 1
            ELSE 0
        END
		) AS department_missing,
    SUM(
        CASE
            WHEN country IS NULL OR TRIM(country) = ''
            THEN 1
            ELSE 0
        END
		) AS country_missing,
    SUM(
        CASE
            WHEN seniority IS NULL OR TRIM(seniority) = ''
            THEN 1
            ELSE 0
        END
		) AS seniority_missing
FROM stg_staff;


-- Character Staff Table
SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN character_name IS NULL OR TRIM(character_name) = ''
            THEN 1
            ELSE 0
        END
		) AS character_name_missing,
    SUM(
        CASE
            WHEN staff_id IS NULL OR TRIM(staff_id) = ''
            THEN 1
            ELSE 0
        END
		) AS staff_id_missing,
    SUM(
        CASE
            WHEN contribution_role IS NULL
                OR TRIM(contribution_role) = ''
            THEN 1
            ELSE 0
        END
		) AS contribution_role_missing,
    SUM(
        CASE
            WHEN work_start_date IS NULL OR TRIM(work_start_date) = ''
            THEN 1
            ELSE 0
        END
		) AS work_start_date_missing,
    SUM(
        CASE
            WHEN work_end_date IS NULL OR TRIM(work_end_date) = ''
            THEN 1
            ELSE 0
        END
		) AS work_end_date_missing,
    SUM(
        CASE
            WHEN allocated_cost_usd IS NULL
                OR TRIM(allocated_cost_usd) = ''
            THEN 1
            ELSE 0
        END
		) AS allocated_cost_usd_missing
FROM stg_character_staff;


-- Character Campaigns Table
SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN campaign_id IS NULL OR TRIM(campaign_id) = ''
            THEN 1
            ELSE 0
        END
		) AS campaign_id_missing,
    SUM(
        CASE
            WHEN character_name IS NULL OR TRIM(character_name) = ''
            THEN 1
            ELSE 0
        END
		) AS character_name_missing,
    SUM(
        CASE
            WHEN campaign_name IS NULL OR TRIM(campaign_name) = ''
            THEN 1
            ELSE 0
        END
		) AS campaign_name_missing,
    SUM(
        CASE
            WHEN campaign_start_date IS NULL
                OR TRIM(campaign_start_date) = ''
            THEN 1
            ELSE 0
        END
		) AS campaign_start_date_missing,
    SUM(
        CASE
            WHEN campaign_end_date IS NULL
                OR TRIM(campaign_end_date) = ''
            THEN 1
            ELSE 0
        END
		) AS campaign_end_date_missing,
    SUM(
        CASE
            WHEN primary_channel IS NULL OR TRIM(primary_channel) = ''
            THEN 1
            ELSE 0
        END
		) AS primary_channel_missing,
    SUM(
        CASE
            WHEN campaign_cost_usd IS NULL
                OR TRIM(campaign_cost_usd) = ''
            THEN 1
            ELSE 0
        END
		) AS campaign_cost_usd_missing
FROM stg_character_campaigns;


-- Logins Table
SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN login_id IS NULL OR TRIM(login_id) = ''
            THEN 1
            ELSE 0
        END
		) AS login_id_missing,
    SUM(
        CASE
            WHEN user_id IS NULL OR TRIM(user_id) = ''
            THEN 1
            ELSE 0
        END
		) AS user_id_missing,
    SUM(
        CASE
            WHEN login_date IS NULL OR TRIM(login_date) = ''
            THEN 1
            ELSE 0
        END
		) AS login_date_missing,
    SUM(
        CASE
            WHEN session_minutes IS NULL OR TRIM(session_minutes) = ''
            THEN 1
            ELSE 0
        END
		) AS session_minutes_missing,
    SUM(
        CASE
            WHEN session_count IS NULL OR TRIM(session_count) = ''
            THEN 1
            ELSE 0
        END
		) AS session_count_missing,
    SUM(
        CASE
            WHEN active_banner_id IS NULL OR TRIM(active_banner_id) = ''
            THEN 1
            ELSE 0
        END
		) AS active_banner_id_missing
FROM stg_logins;


-- Pulls Table
SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN pull_id IS NULL OR TRIM(pull_id) = ''
            THEN 1
            ELSE 0
        END
		) AS pull_id_missing,
    SUM(
        CASE
            WHEN user_id IS NULL OR TRIM(user_id) = ''
            THEN 1
            ELSE 0
        END
		) AS user_id_missing,
    SUM(
        CASE
            WHEN pull_datetime IS NULL OR TRIM(pull_datetime) = ''
            THEN 1
            ELSE 0
        END
		) AS pull_datetime_missing,
    SUM(
        CASE
            WHEN banner_id IS NULL OR TRIM(banner_id) = ''
            THEN 1
            ELSE 0
        END
		) AS banner_id_missing,
    SUM(
        CASE
            WHEN character_obtained IS NULL
                OR TRIM(character_obtained) = ''
            THEN 1
            ELSE 0
        END
		) AS character_obtained_missing,
    SUM(
        CASE
            WHEN rarity IS NULL OR TRIM(rarity) = ''
            THEN 1
            ELSE 0
        END
		) AS rarity_missing,
    SUM(
        CASE
            WHEN pity_before IS NULL OR TRIM(pity_before) = ''
            THEN 1
            ELSE 0
        END
		) AS pity_before_missing,
    SUM(
        CASE
            WHEN pity_after IS NULL OR TRIM(pity_after) = ''
            THEN 1
            ELSE 0
        END
		) AS pity_after_missing,
    SUM(
        CASE
            WHEN won_5050 IS NULL OR TRIM(won_5050) = ''
            THEN 1
            ELSE 0
        END
		) AS won_5050_missing,
    SUM(
        CASE
            WHEN currency_type IS NULL OR TRIM(currency_type) = ''
            THEN 1
            ELSE 0
        END
		) AS currency_type_missing,
    SUM(
        CASE
            WHEN currency_spent IS NULL OR TRIM(currency_spent) = ''
            THEN 1
            ELSE 0
        END
		) AS currency_spent_missing,
    SUM(
        CASE
            WHEN pull_phase IS NULL OR TRIM(pull_phase) = ''
            THEN 1
            ELSE 0
        END
		) AS pull_phase_missing
FROM stg_pulls;


-- Purchases Table
SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN purchase_id IS NULL OR TRIM(purchase_id) = ''
            THEN 1
            ELSE 0
        END
		) AS purchase_id_missing,
    SUM(
        CASE
            WHEN user_id IS NULL OR TRIM(user_id) = ''
            THEN 1
            ELSE 0
        END
		) AS user_id_missing,
    SUM(
        CASE
            WHEN purchase_datetime IS NULL
                OR TRIM(purchase_datetime) = ''
            THEN 1
            ELSE 0
        END
		) AS purchase_datetime_missing,
    SUM(
        CASE
            WHEN banner_id IS NULL OR TRIM(banner_id) = ''
            THEN 1
            ELSE 0
        END
		) AS banner_id_missing,
    SUM(
        CASE
            WHEN item_id IS NULL OR TRIM(item_id) = ''
            THEN 1
            ELSE 0
        END
		) AS item_id_missing,
    SUM(
        CASE
            WHEN item_name IS NULL OR TRIM(item_name) = ''
            THEN 1
            ELSE 0
        END
		) AS item_name_missing,
    SUM(
        CASE
            WHEN price_usd IS NULL OR TRIM(price_usd) = ''
            THEN 1
            ELSE 0
        END
		) AS price_usd_missing,
    SUM(
        CASE
            WHEN premium_currency IS NULL OR TRIM(premium_currency) = ''
            THEN 1
            ELSE 0
        END
		) AS premium_currency_missing,
    SUM(
        CASE
            WHEN purchase_number IS NULL OR TRIM(purchase_number) = ''
            THEN 1
            ELSE 0
        END
		) AS purchase_number_missing
FROM stg_purchases;


-- Currency Table
SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN currency_txn_id IS NULL OR TRIM(currency_txn_id) = ''
            THEN 1
            ELSE 0
        END
		) AS currency_txn_id_missing,
    SUM(
        CASE
            WHEN user_id IS NULL OR TRIM(user_id) = ''
            THEN 1
            ELSE 0
        END
		) AS user_id_missing,
    SUM(
        CASE
            WHEN event_datetime IS NULL OR TRIM(event_datetime) = ''
            THEN 1
            ELSE 0
        END
		) AS event_datetime_missing,
    SUM(
        CASE
            WHEN amount IS NULL OR TRIM(amount) = ''
            THEN 1
            ELSE 0
        END
		) AS amount_missing,
    SUM(
        CASE
            WHEN direction IS NULL OR TRIM(direction) = ''
            THEN 1
            ELSE 0
        END
		) AS direction_missing,
    SUM(
        CASE
            WHEN category IS NULL OR TRIM(category) = ''
            THEN 1
            ELSE 0
        END
		) AS category_missing,
    SUM(
        CASE
            WHEN banner_id IS NULL OR TRIM(banner_id) = ''
            THEN 1
            ELSE 0
        END
		) AS banner_id_missing
FROM stg_currency;