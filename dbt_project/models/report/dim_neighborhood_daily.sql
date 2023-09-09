{{ config(
    materialized = 'table'  
) }}

SELECT DATE(requested_datetime) AS date,neighborhood,service_name as service_request_type,
    count(1) AS daily_request_count
FROM {{ ref('311_record_data') }}
where neighborhood is not null and service_name is not null
GROUP BY 1 ,2, 3
order by date DESC, daily_request_count DESC