WITH daily_starts AS (
    SELECT start_station_name AS station_name,
    DATE(started_on_utc) as journey_date,
    COUNT(*) AS journeys_started
    FROM {{ ref("fct_cycle_journeys") }}
    GROUP BY 1, 2
),

daily_ends AS (
    SELECT end_station_name AS station_name,
    DATE(ended_on_utc) AS journey_date,
    COUNT(*) AS journeys_ended
    FROM {{ ref("fct_cycle_journeys") }}
    GROUP BY 1, 2
),
daily_net_flow AS (
    SELECT
        COALESCE(s.station_name, e.station_name) AS station_name,
        COALESCE(s.journey_date, e.journey_date) AS journey_date,
        FORMAT_DATE('%A', COALESCE(s.journey_date, e.journey_date)) AS day_of_week,
            CASE
            WHEN FORMAT_DATE('%A', COALESCE(s.journey_date, e.journey_date)) IN ('Saturday', 'Sunday') THEN 'Weekend'
            ELSE 'Weekday'
        END AS weekday_or_weekend,
        COALESCE(journeys_started, 0) AS journeys_started,
        COALESCE(journeys_ended, 0) AS journeys_ended,
        COALESCE(journeys_ended, 0) - COALESCE(journeys_started, 0) AS net_flow_journeys
    FROM daily_starts s
    FULL OUTER JOIN daily_ends e
        ON s.station_name = e.station_name
        AND s.journey_date = e.journey_date
    ORDER BY 1, 2 ASC
)

SELECT *
FROM daily_net_flow