USE gacha_analytics;

-- dim-tables

CREATE TABLE stg_users
    (
    user_id VARCHAR(20),
    registration_date VARCHAR(30),
    country VARCHAR(50),
    platform VARCHAR(50),
    acquisition_channel VARCHAR(100)
    );

CREATE TABLE stg_banners 
    (
    banner_id VARCHAR(20),
    banner_name VARCHAR(150),
    character_name VARCHAR(100),
    banner_type VARCHAR(50),
    start_date VARCHAR(30),
    end_date VARCHAR(30)
    );

CREATE TABLE stg_shop_items 
    (
    item_id VARCHAR(20),
    item_name VARCHAR(150),
    price_usd VARCHAR(20),
    premium_currency VARCHAR(20)
    );

CREATE TABLE stg_characters 
    (
    character_name VARCHAR(100),
    gender VARCHAR(20),
    rarity VARCHAR(20),
    origin_country VARCHAR(50),
    specs VARCHAR(100),
    core VARCHAR(100),
    visuals VARCHAR(100),
    role VARCHAR(100),
    banner_type VARCHAR(50),
    power_score VARCHAR(20)
    );

CREATE TABLE stg_staff 
    (
    staff_id VARCHAR(20),
    staff_name VARCHAR(100),
    department VARCHAR(100),
    country VARCHAR(50),
    seniority VARCHAR(50)
    );

CREATE TABLE stg_character_staff 
    (
    character_name VARCHAR(100),
    staff_id VARCHAR(20),
    contribution_role VARCHAR(100),
    work_start_date VARCHAR(30),
    work_end_date VARCHAR(30),
    allocated_cost_usd VARCHAR(30)
    );

CREATE TABLE stg_character_campaigns 
    (
    campaign_id VARCHAR(20),
    character_name VARCHAR(100),
    campaign_name VARCHAR(150),
    campaign_start_date VARCHAR(30),
    campaign_end_date VARCHAR(30),
    primary_channel VARCHAR(100),
    campaign_cost_usd VARCHAR(30)
    );

-- fact tables

CREATE TABLE stg_logins 
    (
    login_id VARCHAR(30),
    user_id VARCHAR(20),
    login_date VARCHAR(30),
    session_minutes VARCHAR(30),
    session_count VARCHAR(30),
    active_banner_id VARCHAR(20)
    );

CREATE TABLE stg_pulls 
    (
    pull_id VARCHAR(30),
    user_id VARCHAR(20),
    pull_datetime VARCHAR(50),
    banner_id VARCHAR(20),
    character_obtained VARCHAR(100),
    rarity VARCHAR(20),
    pity_before VARCHAR(20),
    pity_after VARCHAR(20),
    won_5050 VARCHAR(20),
    currency_type VARCHAR(50),
    currency_spent VARCHAR(30),
    pull_phase VARCHAR(50)
    );

CREATE TABLE stg_purchases 
    (
    purchase_id VARCHAR(30),
    user_id VARCHAR(20),
    purchase_datetime VARCHAR(50),
    banner_id VARCHAR(20),
    item_id VARCHAR(20),
    item_name VARCHAR(150),
    price_usd VARCHAR(30),
    premium_currency VARCHAR(30),
    purchase_number VARCHAR(30)
    );

CREATE TABLE stg_currency 
    (
    currency_txn_id VARCHAR(30),
    user_id VARCHAR(20),
    event_datetime VARCHAR(50),
    amount VARCHAR(30),
    direction VARCHAR(50),
    category VARCHAR(100),
    banner_id VARCHAR(20)
    );