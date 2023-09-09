{{ config(
    materialized = 'table'  
) }}

SELECT DATE(requested_datetime) AS date,agency_responsible,
    count(1) AS daily_request_count
FROM {{ ref('311_record_data') }}
where agency_responsible is not null
GROUP BY 1 ,2
order by date DESC, daily_request_count DESC