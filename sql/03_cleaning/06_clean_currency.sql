USE gacha_analytics;


-- fact_currency

DROP TABLE IF EXISTS fact_currency;

CREATE TABLE fact_currency 
	(
    currency_txn_id VARCHAR(30) PRIMARY KEY,
    user_id         VARCHAR(20) NOT NULL,
    event_datetime  DATETIME NOT NULL,
    amount          INT UNSIGNED NOT NULL,
    direction       VARCHAR(10) NOT NULL,
    category        VARCHAR(100) NOT NULL,
    banner_id       VARCHAR(20),

    FOREIGN KEY (user_id)
        REFERENCES dim_users(user_id),
    FOREIGN KEY (banner_id)
        REFERENCES dim_banners(banner_id),

    CHECK (amount > 0),
    CHECK (direction IN ('source', 'sink'))
	);
    
    
INSERT INTO fact_currency 
	(
    currency_txn_id,
    user_id,
    event_datetime,
    amount,
    direction,
    category,
    banner_id
	)
SELECT
    TRIM(c.currency_txn_id),
    TRIM(c.user_id),
    STR_TO_DATE(TRIM(c.event_datetime), '%Y-%m-%d %H:%i:%s'),
    CAST(TRIM(c.amount) AS UNSIGNED),
    LOWER(TRIM(c.direction)),
    TRIM(c.category),
    CASE
        WHEN b.banner_id IS NOT NULL THEN TRIM(c.banner_id)
        ELSE NULL
    END
FROM stg_currency AS c
JOIN dim_users AS u
    ON TRIM(c.user_id) = u.user_id
LEFT JOIN dim_banners AS b
    ON TRIM(c.banner_id) = b.banner_id
WHERE
    STR_TO_DATE(TRIM(c.event_datetime), '%Y-%m-%d %H:%i:%s') >= u.registration_date;
    

-- Control Checks

SELECT
    COUNT(*) AS clean_currency_transactions,
    COUNT(DISTINCT currency_txn_id) AS unique_transaction_ids
FROM fact_currency;

SELECT
    direction,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM fact_currency
GROUP BY direction
ORDER BY direction;

SELECT
    ROUND(SUM(
			CASE 
				WHEN direction = 'sink' THEN amount 
                ELSE 0
            END
            )
        /
        NULLIF(
            SUM(
                CASE
                    WHEN direction = 'source' THEN amount
                    ELSE 0
                END
				),
            0
        ),
        4
		) AS sink_to_source_ratio
FROM fact_currency;