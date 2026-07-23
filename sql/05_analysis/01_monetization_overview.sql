USE gacha_analytics;

-- ============================================================================
-- OVERALL MONETIZATION KPI OVERVIEW
-- ============================================================================
-- Summarize monetization performance across the full observed dataset period.
-- total_revenue  	= total value of all valid purchases.
-- arpu           	= total revenue divided by all registered users.
-- arppu          	= total revenue divided by users who made at least one purchase.
-- conversion_rate 	= percentage of registered users who became paying users.
-- ============================================================================

SELECT
    ROUND(SUM(COALESCE(p.price_usd, 0)), 2) AS total_revenue,
    ROUND(SUM(COALESCE(p.price_usd, 0))
		/NULLIF(COUNT(DISTINCT u.user_id), 0), 2) AS arpu,
    ROUND(SUM(COALESCE(p.price_usd, 0))
		/NULLIF(COUNT(DISTINCT p.user_id), 0), 2) AS arppu,
    ROUND(100.0 * COUNT(DISTINCT p.user_id) 
		/NULLIF(COUNT(DISTINCT u.user_id), 0), 2) AS conversion_rate,
    COUNT(DISTINCT u.user_id) AS total_users,
    COUNT(DISTINCT p.user_id) AS paying_users
FROM dim_users AS u
LEFT JOIN fact_purchases AS p
    ON u.user_id = p.user_id;
