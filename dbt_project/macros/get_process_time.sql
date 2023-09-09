{# This macro returns the description of  process_time #}

{% macro get_process_time_description(closed_date, requested_datetime) %}
    
    case 
        when AVG(DATE_DIFF({{closed_date}}, {{requested_datetime}}, DAY))<=1 then '<=1 Day'
        when AVG(DATE_DIFF({{closed_date}}, {{requested_datetime}}, DAY))>1 and AVG(DATE_DIFF({{closed_date}}, {{requested_datetime}}, DAY))<=3  then '1~3 Day'
        when AVG(DATE_DIFF({{closed_date}}, {{requested_datetime}}, DAY))>3 and AVG(DATE_DIFF({{closed_date}}, {{requested_datetime}}, DAY))<=7  then '3~7 Day'
        when AVG(DATE_DIFF({{closed_date}}, {{requested_datetime}}, DAY))>7 and AVG(DATE_DIFF({{closed_date}}, {{requested_datetime}}, DAY))<=14  then '7~14 Day'
        when AVG(DATE_DIFF({{closed_date}}, {{requested_datetime}}, DAY))>14 and AVG(DATE_DIFF({{closed_date}}, {{requested_datetime}}, DAY))<=30  then '14~30 Day'
        else '>1 Month'
    end

{% endmacro %}