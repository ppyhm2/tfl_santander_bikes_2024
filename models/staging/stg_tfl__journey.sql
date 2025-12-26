WITH source AS
(
    SELECT *
    FROM {{ source('tfl', 'journey') }}
    WHERE `Start date` <= `End date`
),

renamed AS
(
    SELECT
        CAST(`Number` AS int64) AS journey_id,
        TIMESTAMP(`Start date`) AS started_on_utc,
        TIMESTAMP(`End date`) AS ended_on_utc,
        CAST(`Start station number` AS int64) AS start_station_id,
        `Start station` AS start_station_name,
        CAST(`End station number` AS int64) AS end_station_id,
        `End station` AS end_station_name,
        CAST(`Bike number` AS int64) AS bike_id,
        `Bike model` AS bike_model,
        `Total duration` AS journey_duration_hr_min_string,
        ROUND((CAST(`Total duration in ms` AS int64) / 1000), 1) AS journey_duration_seconds
    FROM source
)

SELECT *
FROM renamed