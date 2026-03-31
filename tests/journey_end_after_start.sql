{{ config(severity = 'warn') }}

SELECT *
FROM {{ source('tfl', 'journey') }}
WHERE `Start date` > `End date`

-- 27th October 2024 due to BST ending (clocks go back)