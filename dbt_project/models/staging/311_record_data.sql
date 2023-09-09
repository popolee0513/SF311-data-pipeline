{{ config(
    materialized = 'incremental',
    unique_key = 'service_request_id'
    
) }}

SELECT service_request_id,
      requested_datetime,
      CASE
    WHEN closed_date IS NULL THEN NULL
    WHEN closed_date < requested_datetime THEN requested_datetime
    ELSE closed_date
END AS closed_date,
CASE
    WHEN updated_datetime IS NULL THEN NULL
    WHEN updated_datetime < requested_datetime THEN requested_datetime
    ELSE updated_datetime
END AS updated_datetime,
      status_description,
      status_notes,
      agency_responsible,
      service_name,
      service_subtype,
      service_details,
      address,
      street,
      CAST(supervisor_district as  INT64) as supervisor_district,
      neighborhoods_sffind_boundaries as neighborhood,
      police_district ,
      lat,
      long,
      source
FROM {{ source('staging', 'staging_table') }}
WHERE status_notes NOT LIKE  '%duplicate%' and status_notes NOT LIKE  '%Duplicate%' 
And requested_datetime >='2020-01-01'