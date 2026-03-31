SELECT
    station_name,
    weekday_or_weekend,
    ROUND(AVG(net_flow_journeys), 1) AS average_daily_net_flow,
    SUM(journeys_started) AS total_journeys_started,
    SUM(journeys_ended) AS total_journeys_ended,
    SUM(net_flow_journeys) AS total_yearly_net_flow
FROM {{ ref("int_station_daily_net_flow") }}
GROUP BY 1, 2
ORDER BY 1 ASC
