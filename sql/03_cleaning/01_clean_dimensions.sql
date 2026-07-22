USE gacha_analytics;

-- dim_users

DROP TABLE IF EXISTS dim_users;

CREATE TABLE dim_users
	(
    user_id 			VARCHAR(20) PRIMARY KEY,
    registration_date 	DATE NOT NULL,
    country 			VARCHAR(50) NOT NULL,
    platform 			VARCHAR(20) NOT NULL,
    acquisition_channel VARCHAR(50) NOT NULL
    );
 
 
INSERT INTO dim_users
	(
    user_id,
    registration_date,
    country,
    platform,
    acquisition_channel
    )
SELECT DISTINCT
	TRIM(user_id),
    STR_TO_DATE(TRIM(registration_date), '%Y-%m-%d'),
    COALESCE(NULLIF(TRIM(country),''), 'Unknown'),
    CASE TRIM(platform)
		WHEN 'Andriod' THEN 'Android'
        WHEN 'IOS'     THEN 'iOS'
        WHEN 'Pc'      THEN 'PC'
        ELSE TRIM(platform)
	END,
    TRIM(acquisition_channel)
FROM stg_users
WHERE
	NULLIF(TRIM(user_id),'') IS NOT NULL
    AND STR_TO_DATE(TRIM(registration_date), '%Y-%m-%d') IS NOT NULL;
    
    
-- dim_characters

DROP TABLE IF EXISTS dim_characters;

CREATE TABLE dim_characters 
	(
    character_name 	VARCHAR(100) PRIMARY KEY,
    gender         	CHAR(1) NOT NULL,
    rarity         	TINYINT UNSIGNED NOT NULL,
    origin_country 	VARCHAR(50) NOT NULL,
    specs          	VARCHAR(100) NOT NULL,
    core           	VARCHAR(100) NOT NULL,
    visuals        	VARCHAR(100) NOT NULL,
    role           	VARCHAR(100) NOT NULL,
    banner_type    	VARCHAR(50) NOT NULL,
    power_score    	TINYINT UNSIGNED NOT NULL,
    CHECK (rarity IN (4, 5)),
    CHECK (power_score BETWEEN 0 AND 100)
	);

INSERT INTO dim_characters 
	(
    character_name,
    gender,
    rarity,
    origin_country,
    specs,
    core,
    visuals,
    role,
    banner_type,
    power_score
	)
SELECT
    TRIM(character_name),
    TRIM(gender),
    CAST(TRIM(rarity) AS UNSIGNED),
    TRIM(origin_country),
    TRIM(specs),
    TRIM(core),
    TRIM(visuals),
    TRIM(role),
    TRIM(banner_type),
    CAST(TRIM(power_score) AS UNSIGNED)
FROM stg_characters;


-- dim_banners

DROP TABLE IF EXISTS dim_banners;

CREATE TABLE dim_banners 
	(
    banner_id      VARCHAR(20) PRIMARY KEY,
    banner_name    VARCHAR(150) NOT NULL,
    character_name VARCHAR(100),
    banner_type    VARCHAR(50) NOT NULL,
    start_date     DATE NOT NULL,
    end_date       DATE NOT NULL,
    CHECK (end_date >= start_date)
	);

INSERT INTO dim_banners 
	(
    banner_id,
    banner_name,
    character_name,
    banner_type,
    start_date,
    end_date
	)
SELECT
    TRIM(banner_id),
    TRIM(banner_name),
    NULLIF(TRIM(character_name), ''),
    TRIM(banner_type),
    STR_TO_DATE(TRIM(start_date), '%Y-%m-%d'),
    STR_TO_DATE(TRIM(end_date), '%Y-%m-%d')
FROM stg_banners;


-- dim_shop_items

DROP TABLE IF EXISTS dim_shop_items;

CREATE TABLE dim_shop_items 
	(
    item_id          VARCHAR(20) PRIMARY KEY,
    item_name        VARCHAR(150) NOT NULL,
    price_usd        DECIMAL(10, 2) NOT NULL,
    premium_currency INT UNSIGNED NOT NULL
	);

INSERT INTO dim_shop_items 
	(
    item_id,
    item_name,
    price_usd,
    premium_currency
	)
SELECT
    TRIM(item_id),
    TRIM(item_name),
    CAST(REPLACE(TRIM(price_usd), ',', '.') AS DECIMAL(10, 2)),
    CAST(TRIM(premium_currency) AS UNSIGNED)
FROM stg_shop_items;


-- dim_staff

DROP TABLE IF EXISTS dim_staff;

CREATE TABLE dim_staff 
	(
    staff_id   VARCHAR(20) PRIMARY KEY,
    staff_name VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    country    VARCHAR(50) NOT NULL,
    seniority  VARCHAR(50) NOT NULL
	);

INSERT INTO dim_staff 
	(
    staff_id,
    staff_name,
    department,
    country,
    seniority
	)
SELECT
    TRIM(staff_id),
    TRIM(staff_name),
    TRIM(department),
    TRIM(country),
    TRIM(seniority)
FROM stg_staff;

-- Control Checks

SELECT 
	'dim_users' AS table_name, 
    COUNT(*) AS row_count
FROM dim_users
UNION ALL
SELECT 
	'dim_characters', 
    COUNT(*)
FROM dim_characters
UNION ALL
SELECT 
	'dim_banners', 
    COUNT(*)
FROM dim_banners
UNION ALL
SELECT 
	'dim_shop_items', 
    COUNT(*)
FROM dim_shop_items
UNION ALL
SELECT 
	'dim_staff', 
    COUNT(*)
FROM dim_staff;