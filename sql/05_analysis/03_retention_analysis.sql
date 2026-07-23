USE gacha_analytics;

-- ============================================================================
-- RETENTION ANALYSIS
-- ============================================================================
-- Measure whether registered users return to the game after a specified number
-- of days and compare retention performance across registration cohorts.
--
-- Exact-day retention records activity on one specific lifecycle day.
-- Window retention records at least one login within a defined day range.
-- Only users with enough observation time are included in each denominator.
-- ============================================================================

-- ============================================================================
-- EXACT D1 RETENTION
-- ============================================================================

WITH d1_user_status AS (
    SELECT
        u.user_id,
        u.registration_date,
        MAX(
            CASE
                WHEN DATEDIFF(l.login_date, u.registration_date) = 1
                THEN 1
                ELSE 0
            END
        ) AS returned_d1
    FROM dim_users u
    LEFT JOIN fact_logins l
        ON u.user_id = l.user_id
    GROUP BY
        u.user_id,
        u.registration_date
)

SELECT
    COUNT(*) AS eligible_d1_users,
    SUM(returned_d1) AS returned_d1_users,
    ROUND(AVG(returned_d1) * 100, 2) AS exact_d1_retention_pct
FROM d1_user_status
WHERE registration_date <= DATE_SUB(
    (SELECT MAX(login_date) FROM fact_logins),
    INTERVAL 1 DAY
);


-- ============================================================================
-- EXACT AND WINDOW D7 RETENTION
-- ============================================================================
-- Compare activity exactly on lifecycle day 7 with activity at least once
-- during a broader D7 retention window.

WITH d7_user_status AS (
    SELECT
        u.user_id,
        u.registration_date,
        MAX(
            CASE
                WHEN DATEDIFF(l.login_date, u.registration_date) = 7
                THEN 1
                ELSE 0
            END
        ) AS returned_exact_d7,
        MAX(
            CASE
                WHEN DATEDIFF(l.login_date, u.registration_date)
                    BETWEEN 7 AND 10
                THEN 1
                ELSE 0
            END
        ) AS returned_d7_window
    FROM dim_users u
    LEFT JOIN fact_logins l
        ON u.user_id = l.user_id
    GROUP BY
        u.user_id,
        u.registration_date
)

SELECT
    'Exact D7' AS retention_type,
    COUNT(*) AS eligible_users,
    SUM(returned_exact_d7) AS returned_users,
    ROUND(AVG(returned_exact_d7) * 100, 2) AS retention_pct
FROM d7_user_status
WHERE registration_date <= DATE_SUB(
    (SELECT MAX(login_date) FROM fact_logins),
    INTERVAL 7 DAY
)

UNION ALL

SELECT
    'D7 Window (D7-D10)' AS retention_type,
    COUNT(*) AS eligible_users,
    SUM(returned_d7_window) AS returned_users,
    ROUND(AVG(returned_d7_window) * 100, 2) AS retention_pct
FROM d7_user_status
WHERE registration_date <= DATE_SUB(
    (SELECT MAX(login_date) FROM fact_logins),
    INTERVAL 10 DAY
);

-- ============================================================================
-- EXACT AND WINDOW D30 RETENTION
-- ============================================================================

WITH d30_user_status AS (
    SELECT
        u.user_id,
        u.registration_date,
        MAX(
            CASE
                WHEN DATEDIFF(l.login_date, u.registration_date) = 30
                THEN 1
                ELSE 0
            END
        ) AS returned_exact_d30,
        MAX(
            CASE
                WHEN DATEDIFF(l.login_date, u.registration_date)
                    BETWEEN 30 AND 36
                THEN 1
                ELSE 0
            END
        ) AS returned_d30_window
    FROM dim_users u
    LEFT JOIN fact_logins l
        ON u.user_id = l.user_id
    GROUP BY
        u.user_id,
        u.registration_date
)

-- Exact D30 includes only users observed for at least 30 full days.
SELECT
    'Exact D30' AS retention_type,
    COUNT(*) AS eligible_users,
    SUM(returned_exact_d30) AS returned_users,
    ROUND(AVG(returned_exact_d30) * 100, 2) AS retention_pct
FROM d30_user_status
WHERE registration_date <= DATE_SUB(
    (SELECT MAX(login_date) FROM fact_logins),
    INTERVAL 30 DAY
)

UNION ALL

-- Window D30 requires the complete D30-D36 observation window, so its
-- eligibility cutoff is 36 days rather than 30 days.
SELECT
    'D30 Window (D30-D36)' AS retention_type,
    COUNT(*) AS eligible_users,
    SUM(returned_d30_window) AS returned_users,
    ROUND(AVG(returned_d30_window) * 100, 2) AS retention_pct
FROM d30_user_status
WHERE registration_date <= DATE_SUB(
    (SELECT MAX(login_date) FROM fact_logins),
    INTERVAL 36 DAY
);

-- ============================================================================
-- EXPLORATORY MONTHLY COHORT RETENTION
-- ============================================================================
-- Monthly login-based cohort retention was evaluated but not selected for the
-- final dashboard because its values are highly saturated in this synthetic
-- dataset. The exploration is retained to document the analytical decision.
-- ============================================================================

SELECT DISTINCT
    u.user_id,
    DATE_FORMAT(u.registration_date, '%Y-%m-01') AS cohort_month,
    DATE_FORMAT(l.login_date, '%Y-%m-01') AS activity_month
FROM dim_users u
JOIN fact_logins l
	ON u.user_id = l.user_id
ORDER BY
    cohort_month,
    u.user_id,
    activity_month
LIMIT 100;

-- 1. user_month_activity creates one row per user and active calendar month.
-- 2. user_lifecycle_activity converts calendar months into M0, M1, M2, etc.
-- 3. cohort_activity counts active users in each cohort lifecycle month.
-- 4. cohort_sizes counts all users registered in each cohort.
-- 5. The final query calculates active users as a percentage of cohort size.

WITH 
user_month_activity AS (
    SELECT DISTINCT
        u.user_id,
        DATE_FORMAT(u.registration_date, '%Y-%m-01') AS cohort_month,
        DATE_FORMAT(l.login_date, '%Y-%m-01') AS activity_month
    FROM dim_users u
    JOIN fact_logins l
        ON u.user_id = l.user_id
),

user_lifecycle_activity AS (
    SELECT
        user_id,
        cohort_month,
        activity_month,
        TIMESTAMPDIFF(
            MONTH,
            cohort_month,
            activity_month
        ) AS lifecycle_month
    FROM user_month_activity
),

cohort_activity AS (
    SELECT
        cohort_month,
        lifecycle_month,
        COUNT(DISTINCT user_id) AS active_users
    FROM user_lifecycle_activity
    GROUP BY
        cohort_month,
        lifecycle_month
),

cohort_sizes AS (
    SELECT
        DATE_FORMAT(registration_date, '%Y-%m-01') AS cohort_month,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM dim_users
    GROUP BY DATE_FORMAT(registration_date, '%Y-%m-01')
)

SELECT
    a.cohort_month,
    a.lifecycle_month,
    s.cohort_size,
    a.active_users,
    ROUND(
        100.0 * a.active_users / NULLIF(s.cohort_size, 0),
        2
    ) AS retention_pct
FROM cohort_activity a
JOIN cohort_sizes s
    ON a.cohort_month = s.cohort_month
ORDER BY
    a.cohort_month,
    a.lifecycle_month;
    
    
-- ============================================================================
-- EXACT D1 RETENTION BY REGISTRATION COHORT
-- ============================================================================

WITH d1_user_status AS (
    SELECT
        u.user_id,
        u.registration_date,
        DATE_FORMAT(u.registration_date, '%Y-%m-01') AS cohort_month,
        MAX(
            CASE
                WHEN DATEDIFF(l.login_date, u.registration_date) = 1
                THEN 1
                ELSE 0
            END
        ) AS returned_d1
    FROM dim_users u
    LEFT JOIN fact_logins l
        ON u.user_id = l.user_id
    GROUP BY
        u.user_id,
        u.registration_date,
        DATE_FORMAT(u.registration_date, '%Y-%m-01')
)

SELECT
    cohort_month,
    COUNT(*) AS eligible_users,
    SUM(returned_d1) AS returned_users,
    ROUND(AVG(returned_d1) * 100, 2) AS exact_d1_retention_pct
FROM d1_user_status
WHERE registration_date <= DATE_SUB(
    (SELECT MAX(login_date) FROM fact_logins),
    INTERVAL 1 DAY
)
GROUP BY cohort_month
ORDER BY cohort_month;


-- ============================================================================
-- EXACT D7 RETENTION BY REGISTRATION COHORT
-- ============================================================================

WITH d7_user_status AS (
    SELECT
        u.user_id,
        u.registration_date,
        DATE_FORMAT(u.registration_date, '%Y-%m-01') AS cohort_month,
        MAX(
            CASE
                WHEN DATEDIFF(l.login_date, u.registration_date) = 7
                THEN 1
                ELSE 0
            END
        ) AS returned_d7
    FROM dim_users u
    LEFT JOIN fact_logins l
        ON u.user_id = l.user_id
    GROUP BY
        u.user_id,
        u.registration_date,
        DATE_FORMAT(u.registration_date, '%Y-%m-01')
)

SELECT
    cohort_month,
    COUNT(*) AS eligible_users,
    SUM(returned_d7) AS returned_users,
    ROUND(AVG(returned_d7) * 100, 2) AS exact_d7_retention_pct
FROM d7_user_status
WHERE registration_date <= DATE_SUB(
    (SELECT MAX(login_date) FROM fact_logins),
    INTERVAL 7 DAY
)
GROUP BY cohort_month
ORDER BY cohort_month;


-- ============================================================================
-- EXACT D30 RETENTION BY REGISTRATION COHORT
-- ============================================================================

WITH d30_user_status AS (
    SELECT
        u.user_id,
        u.registration_date,
        DATE_FORMAT(u.registration_date, '%Y-%m-01') AS cohort_month,
        MAX(
            CASE
                WHEN DATEDIFF(l.login_date, u.registration_date) = 30
                THEN 1
                ELSE 0
            END
        ) AS returned_d30
    FROM dim_users u
    LEFT JOIN fact_logins l
        ON u.user_id = l.user_id
    GROUP BY
        u.user_id,
        u.registration_date,
        DATE_FORMAT(u.registration_date, '%Y-%m-01')
)

SELECT
    cohort_month,
    COUNT(*) AS eligible_users,
    SUM(returned_d30) AS returned_users,
    ROUND(AVG(returned_d30) * 100, 2) AS exact_d30_retention_pct
FROM d30_user_status
WHERE registration_date <= DATE_SUB(
    (SELECT MAX(login_date) FROM fact_logins),
    INTERVAL 30 DAY
)
GROUP BY cohort_month
ORDER BY cohort_month;
