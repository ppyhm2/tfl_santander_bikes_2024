SELECT
DATE(started_on_utc) AS journey_date,
COUNT(*) AS total_journeys,
ROUND(AVG(journey_duration_seconds), 2) AS avg_journey_duration_seconds,
FROM {{ ref("fct_cycle_journeys") }}
GROUP BY 1
ORDER BY 1 ASC