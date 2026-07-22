USE gacha_analytics;


-- fact_pulls

DROP TABLE IF EXISTS fact_pulls;

CREATE TABLE fact_pulls 
	(
    pull_id            VARCHAR(20) PRIMARY KEY,
    user_id            VARCHAR(20) NOT NULL,
    pull_datetime      DATETIME NOT NULL,
    banner_id          VARCHAR(20) NOT NULL,
    character_obtained VARCHAR(100),
    rarity             TINYINT UNSIGNED NOT NULL,
    pity_before        TINYINT UNSIGNED NOT NULL,
    pity_after         TINYINT UNSIGNED NOT NULL,
    won_5050           BOOLEAN,
    currency_type      VARCHAR(50) NOT NULL,
    currency_spent     SMALLINT UNSIGNED NOT NULL,

    FOREIGN KEY (user_id)
        REFERENCES dim_users(user_id),
    FOREIGN KEY (banner_id)
        REFERENCES dim_banners(banner_id),
    FOREIGN KEY (character_obtained)
        REFERENCES dim_characters(character_name),

    CHECK (rarity IN (3, 4, 5)),
    CHECK (currency_spent = 160),
    CHECK ((rarity = 5 AND won_5050 IS NOT NULL) OR (rarity IN (3, 4) AND won_5050 IS NULL)),
    CHECK ((rarity = 5 AND pity_after = 0) OR (rarity IN (3, 4) AND pity_after = pity_before + 1))
	);
    

INSERT INTO fact_pulls 
	(
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
    currency_spent
	)
SELECT
    TRIM(p.pull_id),
    TRIM(p.user_id),
    STR_TO_DATE(TRIM(p.pull_datetime), '%Y-%m-%d %H:%i:%s'),
    TRIM(p.banner_id),
    NULLIF(TRIM(p.character_obtained), ''),
    CAST(TRIM(p.rarity) AS UNSIGNED),
    CAST(TRIM(p.pity_before) AS UNSIGNED),
    CAST(TRIM(p.pity_after) AS UNSIGNED),
    CASE
        WHEN LOWER(TRIM(p.won_5050)) = 'true'  THEN TRUE
        WHEN LOWER(TRIM(p.won_5050)) = 'false' THEN FALSE
        ELSE NULL
    END,
    TRIM(p.currency_type),
    CAST(TRIM(p.currency_spent) AS UNSIGNED)
FROM 
	(
    SELECT DISTINCT
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
    FROM stg_pulls
	) AS p
JOIN dim_users AS u
    ON TRIM(p.user_id) = u.user_id
JOIN dim_banners AS b
    ON TRIM(p.banner_id) = b.banner_id;
    
    
    -- Control Checks
    
SELECT
    COUNT(*) AS clean_pulls,
    COUNT(DISTINCT pull_id) AS unique_pull_ids
FROM fact_pulls;

SELECT
    rarity,
    won_5050,
    COUNT(*) AS pull_count
FROM fact_pulls
GROUP BY
    rarity,
    won_5050
ORDER BY
    rarity,
    won_5050;