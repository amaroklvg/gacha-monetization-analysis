USE gacha_analytics;


-- fact_purchases

DROP TABLE IF EXISTS fact_purchases;

CREATE TABLE fact_purchases 
	(
    purchase_id       VARCHAR(30) PRIMARY KEY,
    user_id           VARCHAR(20) NOT NULL,
    purchase_datetime DATETIME NOT NULL,
    banner_id         VARCHAR(20),
    item_id           VARCHAR(20) NOT NULL,
    price_usd         DECIMAL(10, 2) NOT NULL,
    premium_currency  INT UNSIGNED NOT NULL,

    FOREIGN KEY (user_id)
        REFERENCES dim_users(user_id),
    FOREIGN KEY (banner_id)
        REFERENCES dim_banners(banner_id),
    FOREIGN KEY (item_id)
        REFERENCES dim_shop_items(item_id),

    CHECK (price_usd > 0),
    CHECK (premium_currency > 0)
);


INSERT INTO fact_purchases 
	(
    purchase_id,
    user_id,
    purchase_datetime,
    banner_id,
    item_id,
    price_usd,
    premium_currency
	)
SELECT
    TRIM(p.purchase_id),
    TRIM(p.user_id),
    STR_TO_DATE(TRIM(p.purchase_datetime), '%Y-%m-%d %H:%i:%s'),
    CASE
        WHEN b.banner_id IS NOT NULL THEN TRIM(p.banner_id)
        ELSE NULL
    END,
    TRIM(p.item_id),
    CAST(REPLACE(TRIM(p.price_usd), ',', '.') AS DECIMAL(10, 2)),
    CAST(TRIM(p.premium_currency) AS UNSIGNED)
FROM 
	(
    SELECT DISTINCT
        purchase_id,
        user_id,
        purchase_datetime,
        banner_id,
        item_id,
        item_name,
        price_usd,
        premium_currency,
        purchase_number
    FROM stg_purchases
	) AS p
JOIN dim_users AS u
    ON TRIM(p.user_id) = u.user_id
JOIN dim_shop_items AS s
    ON TRIM(p.item_id) = s.item_id
LEFT JOIN dim_banners AS b
    ON TRIM(p.banner_id) = b.banner_id
WHERE
    STR_TO_DATE(TRIM(p.purchase_datetime),'%Y-%m-%d %H:%i:%s') >= u.registration_date
    AND (b.banner_id IS NULL OR DATE(STR_TO_DATE(TRIM(p.purchase_datetime), '%Y-%m-%d %H:%i:%s')) 
    BETWEEN b.start_date AND b.end_date
    );
    
    
-- Control Checks

SELECT
    COUNT(*) AS clean_purchases,
    COUNT(DISTINCT purchase_id) AS unique_purchase_ids,
    COUNT(DISTINCT user_id) AS paying_users,
    ROUND(SUM(price_usd), 2) AS total_revenue
FROM fact_purchases;

SELECT
    COUNT(*) AS purchases_without_banner
FROM fact_purchases
WHERE banner_id IS NULL;

SELECT
    COUNT(*) AS price_mismatches
FROM fact_purchases AS p
JOIN dim_shop_items AS s
    ON p.item_id = s.item_id
WHERE p.price_usd <> s.price_usd;