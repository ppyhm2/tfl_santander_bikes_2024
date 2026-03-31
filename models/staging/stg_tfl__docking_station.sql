WITH source AS
(
    SELECT *
    FROM {{ source('tfl', 'docking_station') }}
),

renamed AS
(
    SELECT
        CAST(terminalName AS int64) AS station_id,
        name AS station_name,
        CAST(lat as float64) as latitude,
        CAST(long as float64) as longitude,
        CAST(nbDocks AS int64) AS number_of_docks,
        CAST(temporary AS bool) AS is_temporary,
        CAST(installed AS bool) AS is_installed,
        TIMESTAMP_MILLIS(CAST(installDate AS int64)) AS station_installed_on_utc,
        TIMESTAMP_MILLIS(CAST(removalDate AS int64)) AS station_removed_on_utc
    FROM source
)

SELECT *
FROM renamed