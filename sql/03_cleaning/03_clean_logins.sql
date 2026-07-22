USE gacha_analytics;


-- fact_logins

DROP TABLE IF EXISTS fact_logins;

CREATE TABLE fact_logins 
	(
    login_id        	VARCHAR(20) PRIMARY KEY,
    user_id         	VARCHAR(20) NOT NULL,
    login_date      	DATE NOT NULL,
    session_minutes 	SMALLINT UNSIGNED,
    session_count   	TINYINT UNSIGNED NOT NULL,
    active_banner_id 	VARCHAR(20),

    FOREIGN KEY (user_id)
        REFERENCES dim_users(user_id),
    FOREIGN KEY (active_banner_id)
        REFERENCES dim_banners(banner_id),

    CHECK (session_minutes IS NULL OR session_minutes <= 1440),
    CHECK (session_count >= 1)
	);
    
    
INSERT INTO fact_logins 
	(
    login_id,
    user_id,
    login_date,
    session_minutes,
    session_count,
    active_banner_id
	)
SELECT
    TRIM(l.login_id),
    TRIM(l.user_id),
    STR_TO_DATE(TRIM(l.login_date),'%Y-%m-%d'),
    CASE
        WHEN NULLIF(TRIM(l.session_minutes), '') IS NULL THEN NULL
        WHEN CAST(TRIM(l.session_minutes) AS SIGNED) BETWEEN 0 AND 1440 THEN CAST(TRIM(l.session_minutes) AS UNSIGNED)
        ELSE NULL
    END,
    CAST(TRIM(l.session_count) AS UNSIGNED),
    NULLIF(TRIM(l.active_banner_id), '')
FROM 
	(
    SELECT DISTINCT
        login_id,
        user_id,
        login_date,
        session_minutes,
        session_count,
        active_banner_id
    FROM stg_logins
	) AS l
JOIN dim_users AS u
    ON TRIM(l.user_id) = u.user_id;
    

-- Control Checks

SELECT
    COUNT(*) AS total_logins,
    COUNT(DISTINCT login_id) AS unique_login_ids
FROM fact_logins;

SELECT
    COUNT(*) AS invalid_session_minutes
FROM fact_logins
WHERE
    session_minutes < 0
    OR session_minutes > 1440;
    
SELECT
    COUNT(*) AS missing_session_minutes
FROM fact_logins
WHERE session_minutes IS NULL;