{{ config(
    materialized = 'table'  
) }}

SELECT format_timestamp('%Y-%m', requested_datetime)
     AS yyyy_mm,
    source,
    count(service_request_id) as source_count
FROM {{ ref('311_record_data') }}
GROUP BY 1, 2
ORDER BY  yyyy_mm DESC