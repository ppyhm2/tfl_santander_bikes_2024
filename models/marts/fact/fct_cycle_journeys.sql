SELECT
j.journey_id,
j.started_on_utc,
EXTRACT(hour FROM j.started_on_utc) AS started_on_hour,
FORMAT_DATE('%A', DATE(j.started_on_utc)) AS started_on_day_of_week,
CASE
    WHEN FORMAT_DATE('%A', DATE(j.started_on_utc)) IN ('Saturday', 'Sunday') THEN 'Weekend'
    ELSE 'Weekday'
END AS journey_started_weekday_or_weekend,
j.ended_on_utc,
j.start_station_name,
dss.latitude AS start_station_latitude,
dss.longitude AS start_station_longitude,
dss.number_of_docks AS start_station_number_of_docks,
j.end_station_name,
dse.latitude AS end_station_latitude,
dse.longitude AS end_station_longitude,
dse.number_of_docks AS end_station_number_of_docks,
j.bike_model,
j.journey_duration_hr_min_string,
j.journey_duration_seconds
FROM {{ ref("stg_tfl__journey") }} j
LEFT JOIN {{ ref("stg_tfl__docking_station") }} dss ON j.start_station_id = dss.station_id
LEFT JOIN {{ ref("stg_tfl__docking_station") }} dse ON j.end_station_id = dse.station_id

-- fact table may have missing data for start/end longitude, latitude, and station ID because the station may be missing from the
-- docking station dimension table e.g. an old station. However, start/end station name will still be available because
-- that data comes from the journey table which is immutable