# TfL Santander Cycles 2024 — dbt Project

A personal dbt project built to practise an end-to-end ELT workflow using Transport for London's Santander Cycle Hire data for 2024.

## Overview

This project transforms raw TfL cycle hire data in BigQuery using dbt. It covers journey-level data and docking station metadata, and is structured across multiple layers following dbt best practices.

The goal is to practise modern Analytics Engineering patterns: source declaration, staged transformations, intermediate business logic, and aggregated marts ready for consumption.

**Note:** Data visualisation is out of scope for this project. The focus is on the transformation layer. If you'd like to see some examples of my data visualisations, please see this link: https://public.tableau.com/app/profile/henry.mak/vizzes

## Data Sources

Data was loaded manually into BigQuery from CSV files downloaded from TfL's open data platform.

| Table | Description |
|---|---|
| `raw_tfl.journey` | One row per bike hire journey across 2024 |
| `raw_tfl.docking_station` | Docking station metadata (correct as of December 2025) |

## Project Structure
```
models/
├── sources/          # Source definitions and documentation for raw BigQuery tables
├── staging/          # Renamed columns, correct data types, light cleaning only
├── marts/
│   ├── intermediate/ # Business logic (e.g. net flow calculations per station per day)
│   ├── fact/         # Fact table joining journeys with docking station dimension data
│   └── aggregated_marts/ # Aggregated outputs ready for reporting
```

### Layer Descriptions

**Staging** — One model per source table. Renames raw columns to consistent snake_case, casts to correct data types, and converts journey duration from milliseconds to seconds. No business logic at this layer.

**Intermediate** — Calculates daily net flow per station (journeys ended minus journeys started) using a FULL OUTER JOIN to ensure stations with only arrivals or only departures are not dropped. Adds weekday/weekend classification for downstream reuse.

**Fact** — Joins staged journey data with docking station metadata (latitude, longitude, dock count) for both start and end stations. Uses LEFT JOINs to preserve all journeys, including those where a station has since been decommissioned and is absent from the station dimension.

**Aggregated Marts** — Two marts built for reporting:
- `mart_cycle_journeys_daily` — daily journey counts and average duration
- `mart_station_net_flow_weekday_weekend` — weekday vs. weekend net flow per station across 2024

## Tests

Tests are defined using [dbt_utils](https://github.com/dbt-labs/dbt_utils) and [dbt_expectations](https://github.com/metaplane/dbt_expectations).

Examples include:

- `unique` and `not_null` on all primary keys
- `accepted_range` on timestamps (must be within 2024), journey duration (1–86,400 seconds), and coordinates (valid lat/long bounds)
- `relationships` between journey station IDs and the docking station model — set to `severity: warn` rather than error, since journeys may reference stations that have since been removed from the network
- `expect_column_values_to_be_in_set` on `bike_model` to ensure only known bike types appear

## How to Run

This project was developed using [dbt Cloud](https://www.getdbt.com/product/dbt-cloud).

### Prerequisites

- A dbt Cloud account connected to a BigQuery project
- The raw source tables loaded into BigQuery (see Data Sources above)

### Steps

1. Clone or fork this repository and connect it to a dbt Cloud project
2. Configure a BigQuery connection in dbt Cloud pointing to your project
3. Run `dbt deps` in the dbt Cloud IDE to install package dependencies
4. Use `dbt build` to run all models and tests, or `dbt run` and `dbt test` separately

## Notes

- Source data was loaded manually into BigQuery from Excel/CSV files as part of the learning scope — there is no automated ingestion pipeline.
- This project is primarily a learning exercise to practise dbt, BigQuery, and modern ELT patterns, rather than a production pipeline.
- BigQuery was chosen as the data warehouse both to gain experience with a modern cloud platform and because its free tier makes it accessible for personal projects.
- Journey data covers 2024 only.
- Docking station correct as of December 2025.
