USE gacha_analytics;

-- ============================================================================
-- DAILY AND MONTHLY ACTIVE USERS
-- ============================================================================
-- I want to establish the basic engagement volumes used later in the stickiness
-- and monthly monetization calculations.
-- ============================================================================

-- ============================================================================
-- Daily Active Users (DAU)
-- ============================================================================
SELECT
    login_date,
    COUNT(DISTINCT user_id) AS dau
FROM fact_logins
GROUP BY
    login_date
ORDER BY
    login_date;

-- ============================================================================
-- Monthly Active Users (MAU):
-- ============================================================================

SELECT
    DATE_FORMAT(login_date, '%Y-%m-01') AS activity_month,
    COUNT(DISTINCT user_id) AS mau
FROM fact_logins
GROUP BY
    DATE_FORMAT(login_date, '%Y-%m-01')
ORDER BY
    activity_month;

SELECT
    MIN(dau) AS minimum_dau,
    MAX(dau) AS maximum_dau,
    ROUND(AVG(dau), 2) AS average_dau
FROM
    (
        SELECT
            login_date,
            COUNT(DISTINCT user_id) AS dau
        FROM fact_logins
        GROUP BY
            login_date
    ) AS daily_activity;

-- ============================================================================
-- MONTHLY STICKINESS (DAU/MAU)
-- ============================================================================
-- Measure how frequently monthly active users return on an average day.
-- 1. daily_activity calculates DAU for every date and assigns the date to a month.
-- 2. monthly_dau averages the daily DAU values within each month.
-- 3. monthly_mau counts distinct active users within each month.
-- 4. the final query joins both monthly results and calculates stickiness.
-- ============================================================================

WITH
daily_activity AS (
    SELECT
        login_date,
        DATE_FORMAT(login_date, '%Y-%m-01') AS activity_month,
        COUNT(DISTINCT user_id) AS dau
    FROM fact_logins
    GROUP BY
        login_date,
        DATE_FORMAT(login_date, '%Y-%m-01')
),

monthly_dau AS (
    SELECT
        activity_month,
        ROUND(AVG(dau), 2) AS average_dau
    FROM daily_activity
    GROUP BY activity_month
),

monthly_mau AS (
    SELECT
        DATE_FORMAT(login_date, '%Y-%m-01') AS activity_month,
        COUNT(DISTINCT user_id) AS mau
    FROM fact_logins
    GROUP BY DATE_FORMAT(login_date, '%Y-%m-01')
)
SELECT
    d.activity_month,
    d.average_dau,
    m.mau,
    ROUND(d.average_dau / NULLIF(m.mau, 0) * 100, 2) AS dau_mau_ratio_pct
FROM monthly_dau d
JOIN monthly_mau m
    ON d.activity_month = m.activity_month
ORDER BY d.activity_month;

-- ============================================================================
-- MONTHLY REVENUE AND ARPPU
-- ============================================================================
-- Examine whether revenue changes are driven by the number of paying users
-- or by changes in the average amount spent by each payer.
-- Preview the cleaned purchase events before monthly aggregation.
-- ============================================================================

SELECT
    DATE_FORMAT(purchase_datetime, '%Y-%m-01') AS revenue_month,
    ROUND(SUM(price_usd), 2) AS monthly_revenue,
    COUNT(DISTINCT user_id) AS monthly_paying_users,
    ROUND(SUM(price_usd) / NULLIF(COUNT(DISTINCT user_id), 0), 2) AS monthly_arppu
FROM fact_purchases
GROUP BY
    DATE_FORMAT(purchase_datetime, '%Y-%m-01')
ORDER BY
    revenue_month;

-- ============================================================================
-- MONTHLY MONETIZATION AMONG ACTIVE USERS
-- ============================================================================
-- Combine monthly engagement and purchase activity to measure monetization
-- efficiency within the active player base.
-- ============================================================================

WITH
monthly_activity AS (
    SELECT
        DATE_FORMAT(login_date, '%Y-%m-01') AS activity_month,
        COUNT(DISTINCT user_id) AS mau
    FROM fact_logins
    GROUP BY DATE_FORMAT(login_date, '%Y-%m-01')
),

monthly_monetization AS (
    SELECT
        DATE_FORMAT(purchase_datetime, '%Y-%m-01') AS revenue_month,
        ROUND(SUM(price_usd), 2) AS monthly_revenue,
        COUNT(DISTINCT user_id) AS monthly_paying_users
    FROM fact_purchases
    GROUP BY DATE_FORMAT(purchase_datetime, '%Y-%m-01')
)
SELECT
    a.activity_month,
    a.mau,
    COALESCE(m.monthly_revenue, 0) AS monthly_revenue,
    COALESCE(m.monthly_paying_users, 0) AS monthly_paying_users,
    ROUND(COALESCE(m.monthly_revenue, 0) / NULLIF(a.mau, 0), 2) AS monthly_arpu,
    ROUND(COALESCE(m.monthly_paying_users, 0) / NULLIF(a.mau, 0) * 100, 2) AS monthly_conversion_rate,
    ROUND(COALESCE(m.monthly_revenue, 0) / NULLIF(COALESCE(m.monthly_paying_users, 0), 0), 2) AS monthly_arppu
FROM monthly_activity a
LEFT JOIN monthly_monetization m
    ON a.activity_month = m.revenue_month
ORDER BY a.activity_month;