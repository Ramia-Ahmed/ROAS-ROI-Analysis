CREATE OR REPLACE VIEW roas_roi AS
SELECT * REPLACE (CAST(week_start_date AS DATE) AS week_start_date)
FROM 'roas_roi_synthetic_data.csv';

SELECT * FROM roas_roi;

SELECT typeof(week_start_date) FROM roas_roi LIMIT 1;

                -- Overall Health Check --
SELECT
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(revenue) / SUM(spend), 2) AS blended_roas,
    ROUND((SUM(revenue) - SUM(spend)) / SUM(spend) * 100, 2) AS blended_roi,
    ROUND(SUM(spend) / SUM(conversions), 2) AS blended_cac
FROM roas_roi;

                -- Efficiency by Channel --
WITH channel_agg AS (

    SELECT
    channel,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(spend) / SUM(conversions), 2) AS blended_cac
FROM roas_roi
GROUP BY channel

)
SELECT 
    channel,
    total_spend,
    total_revenue,
    blended_cac,
    ROUND(total_revenue / total_spend, 2) AS roas,
    ROUND((total_revenue - total_spend) / total_spend * 100, 2) AS roi_pct,
    ROUND(total_spend / SUM(total_spend) OVER() * 100, 2) AS spend_share_pct,
    ROUND(total_revenue / SUM(total_revenue) OVER() * 100, 2) AS revenue_share_pct
FROM channel_agg
ORDER BY roas DESC;

                -- Campaign-level Drill-down --

WITH campaign_agg AS (

    SELECT
    channel,
    campaign,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(spend) / SUM(conversions), 2) AS blended_cac
FROM roas_roi
GROUP BY channel , campaign

)
SELECT 
    channel,
    campaign,
    total_spend,
    total_revenue,
    blended_cac,
    ROUND(total_revenue / total_spend, 2) AS roas,
    ROUND((total_revenue - total_spend) / total_spend * 100, 2) AS roi_pct,
    ROUND(total_spend / SUM(total_spend) OVER(PARTITION BY channel) * 100, 2) AS spend_share_pct,
    ROUND(total_revenue / SUM(total_revenue) OVER(PARTITION BY channel) * 100, 2) AS revenue_share_pct
FROM campaign_agg
WHERE channel IN (SELECT DISTINCT channel from roas_roi)
ORDER BY roas DESC;

                -- Trend Overtime Analysis --
SELECT
    STRFTIME(DATE_TRUNC('month', week_start_date), '%Y-%m') AS month,
    channel,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(revenue) / SUM(spend), 2) AS roas,
    ROUND((SUM(revenue) - SUM(spend)) / SUM(spend) * 100, 2) AS roi_pct
FROM roas_roi
GROUP BY month, channel
ORDER BY month;

                -- Spend vs. ROAS --
SELECT
    channel,
    week_start_date,
    SUM(spend) AS weekly_spend,
    SUM(revenue) AS weekly_revenue,
    ROUND(SUM(revenue) / SUM(spend), 2) AS roas
FROM roas_roi
GROUP BY channel, week_start_date
ORDER BY channel, week_start_date;

                -- Funnel Efficiency --
SELECT
    channel,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(clicks) * 1.0 / SUM(impressions) * 100, 2) AS ctr_pct,
    ROUND(SUM(conversions) * 1.0 / SUM(clicks) * 100, 2) AS conversion_rate_pct,
    ROUND(SUM(spend) / SUM(conversions), 2) AS cac
FROM roas_roi
GROUP BY channel
ORDER BY conversion_rate_pct DESC;