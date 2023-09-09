{{ config(
    materialized = 'table'  
) }}

SELECT
    format_timestamp('%Y-%m', requested_datetime) as yyyy_mm,
    service_name as service_request_type,
     {{get_process_time_description( 'closed_date', 'requested_datetime') }} AS Avg_Process_Day
FROM {{ ref('311_record_data') }}
WHERE closed_date IS NOT NULL and service_name IS NOT NULL
GROUP BY 1, 2
ORDER BY yyyy_mm DESC, Avg_Process_day DESC