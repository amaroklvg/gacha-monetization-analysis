USE gacha_analytics;


-- fact_character_staff

DROP TABLE IF EXISTS fact_character_staff;

CREATE TABLE fact_character_staff 
	(
    character_name    	VARCHAR(100) NOT NULL,
    staff_id          	VARCHAR(20) NOT NULL,
    contribution_role 	VARCHAR(100) NOT NULL,
    work_start_date   	DATE NOT NULL,
    work_end_date     	DATE NOT NULL,
    allocated_cost_usd 	DECIMAL(12, 2) NOT NULL,

    PRIMARY KEY 
		(
        character_name,
        staff_id,
        contribution_role
		),
    FOREIGN KEY (character_name)
        REFERENCES dim_characters(character_name),
    FOREIGN KEY (staff_id)
        REFERENCES dim_staff(staff_id),
        
    CHECK (work_end_date >= work_start_date),
    CHECK (allocated_cost_usd >= 0)
	);

INSERT INTO fact_character_staff 
	(
    character_name,
    staff_id,
    contribution_role,
    work_start_date,
    work_end_date,
    allocated_cost_usd
	)
SELECT
    TRIM(character_name),
    TRIM(staff_id),
    TRIM(contribution_role),
    STR_TO_DATE(TRIM(work_start_date), '%Y-%m-%d'),
    STR_TO_DATE(TRIM(work_end_date), '%Y-%m-%d'),
    CAST(TRIM(allocated_cost_usd) AS DECIMAL(12, 2))
FROM stg_character_staff;


-- fact_character_campaigns

DROP TABLE IF EXISTS fact_character_campaigns;

CREATE TABLE fact_character_campaigns 
	(
    campaign_id        VARCHAR(20) PRIMARY KEY,
    character_name     VARCHAR(100) NOT NULL,
    campaign_name      VARCHAR(150) NOT NULL,
    campaign_start_date DATE NOT NULL,
    campaign_end_date   DATE NOT NULL,
    primary_channel    VARCHAR(100) NOT NULL,
    campaign_cost_usd  DECIMAL(12, 2) NOT NULL,

    FOREIGN KEY (character_name)
        REFERENCES dim_characters(character_name),

    CHECK (campaign_end_date >= campaign_start_date),
    CHECK (campaign_cost_usd >= 0)
	);

INSERT INTO fact_character_campaigns 
	(
    campaign_id,
    character_name,
    campaign_name,
    campaign_start_date,
    campaign_end_date,
    primary_channel,
    campaign_cost_usd
	)
SELECT
    TRIM(campaign_id),
    TRIM(character_name),
    TRIM(campaign_name),
    STR_TO_DATE(TRIM(campaign_start_date), '%Y-%m-%d'),
    STR_TO_DATE(TRIM(campaign_end_date), '%Y-%m-%d'),
    TRIM(primary_channel),
    CAST(TRIM(campaign_cost_usd) AS DECIMAL(12, 2))
FROM stg_character_campaigns;

-- Control Checks
SELECT
    'fact_character_staff' AS table_name,
    COUNT(*) AS row_count
FROM fact_character_staff
UNION ALL
SELECT
    'fact_character_campaigns',
    COUNT(*)
FROM fact_character_campaigns;