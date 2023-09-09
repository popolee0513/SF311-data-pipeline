{{ config(
    materialized = 'table'  
) }}

SELECT
    format_timestamp('%Y-%m', requested_datetime) as yyyy_mm,
    agency_responsible,
    {{get_process_time_description( 'closed_date', 'requested_datetime') }} AS Avg_Process_Day
FROM {{ ref('311_record_data') }}
WHERE closed_date IS NOT NULL and agency_responsible IS NOT NULL
GROUP BY 1, 2
ORDER BY yyyy_mm DESC, Avg_Process_day DESC
