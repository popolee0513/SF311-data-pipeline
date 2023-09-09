{{ config(
    materialized = 'table'  
) }}

SELECT DATE(requested_datetime) AS date,
    count(1) AS daily_request_count
FROM {{ ref('311_record_data') }}
GROUP BY 1 
order by date DESC