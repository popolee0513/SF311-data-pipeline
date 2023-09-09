from airflow import DAG
from datetime import datetime, timedelta
from sodapy import Socrata
import numpy as np
import pandas  as pd
from requests.exceptions import HTTPError
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryCreateEmptyTableOperator,BigQueryDeleteTableOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from google.cloud import storage
#from dotenv import load_dotenv
import os
import pendulum
from cosmos import ProfileConfig,ProjectConfig,ExecutionConfig,DbtTaskGroup
from cosmos.constants import ExecutionMode

taiwan_timezone = pendulum.timezone("Asia/Taipei")

JSON_filepath = os.getenv('GOOGLE_APPLICATION_CREDENTIALS')
client = storage.Client.from_service_account_json(JSON_filepath)
PROJECT_ID = os.getenv('GCP_PROJECT_ID')
BUCKET = os.getenv('GCP_GCS_BUCKET')
DATASET_ID = os.getenv('DATASET_ID')

schema_definition = [
  {'name': 'service_request_id', 'type': 'string'},
  {'name': 'requested_datetime', 'type': 'datetime'},
  {'name': 'closed_date', 'type': 'datetime'},
  {'name': 'updated_datetime', 'type': 'datetime'},
  {'name': 'status_description', 'type': 'string'},
  {'name': 'status_notes', 'type': 'string'},
  {'name': 'agency_responsible', 'type': 'string'},
  {'name': 'service_name', 'type': 'string'},
  {'name': 'service_subtype', 'type': 'string'},
  {'name': 'service_details', 'type': 'string'},
  {'name': 'address', 'type': 'string'},
  {'name': 'street', 'type': 'string'},
  {'name': 'supervisor_district', 'type': 'INTEGER'},
  {'name': 'neighborhoods_sffind_boundaries', 'type': 'string'},
  {'name': 'police_district', 'type': 'string'},
  {'name': 'lat', 'type': 'FLOAT'},
  {'name': 'long', 'type': 'FLOAT'},
  {'name': 'source', 'type': 'string'}
    ]
default_args = {
    'owner': 'Peter Lee',
    'start_date': pendulum.datetime(2020, 1, 2, 16, 0, 0, tz=taiwan_timezone),
    'schedule_interval': '@daily',
    "catchup": True,
    'retries': 2,
    'retry_delay': timedelta(minutes=1)
}



profile_config = ProfileConfig(
    profile_name="dbt_project",
    target_name="dev",
    # choose one of the following
    profiles_yml_filepath="/opt/airflow/dbt/profiles.yml",
)



def fetch_data_from_api(**kwargs):
    client = Socrata("data.sfgov.org", None)
    ti = kwargs['ti']
    execution_date = ti.execution_date
    ds = execution_date.strftime('%Y-%m-%d')  # Format as YYYY-MM-DD
    # Calculate tomorrow's date
    yesterday_date = execution_date - timedelta(days=1)
    yesterday_ds = yesterday_date.strftime('%Y-%m-%d')
    print(yesterday_ds,ds)
    query = "(requested_datetime >= '%s' and requested_datetime < '%s') or (\
    updated_datetime >= '%s' and updated_datetime < '%s'\
    )" %(yesterday_ds,ds,yesterday_ds,ds)
    result = client.get_all("vw6y-z8j6",where = query)
    try:
        df = pd.DataFrame.from_records(result)
        assert len(df)!=0
        return df
    except HTTPError as e:
        status_code = e.response.status_code
        print(f"API Request Failed with status code: {status_code}")
        raise Exception("API Request Failed")
def clean(**kwargs):
    ti = kwargs['ti']
    df = ti.xcom_pull(task_ids='fetch_api_data')
    columns_to_keep = [
        'service_request_id', 'requested_datetime', 'closed_date',
        'updated_datetime', 'status_description', 'status_notes',
        'agency_responsible', 'service_name', 'service_subtype',
        'service_details', 'address', 'street', 'supervisor_district',
        'neighborhoods_sffind_boundaries', 'police_district', 'lat', 'long', 'source'
    ]
    # Select and drop duplicate rows    
    df = df[columns_to_keep].drop_duplicates()
    # Replace '0.000000000000' with NaN in lat and long columns
    df['lat'] = df['lat'].replace('0.000000000000',np.nan)
    df['long'] = df['long'].replace('0.000000000000',np.nan)
    return df
def upload_to_gcs(**kwargs):
    ti = kwargs['ti']
    df = ti.xcom_pull(task_ids='process_data')
    yesterday_date = ti.execution_date - timedelta(days=1)
    yesterday_ds = yesterday_date.strftime('%Y-%m-%d')
    bucket = client.bucket(BUCKET)
    path_in_gcs = f"raw/{yesterday_ds}_SF311.csv"
    bucket.blob(path_in_gcs).upload_from_string(df.to_csv(index=False), 'text/csv')
    
       
with DAG('SF311', default_args=default_args) as dag:
 
    fetch_api_data_task = PythonOperator(
    task_id='fetch_api_data',
    python_callable=fetch_data_from_api
    )
    process_data_task = PythonOperator(
    task_id='process_data',
    python_callable=clean
    )
    upload_to_gcs_task = PythonOperator(
    task_id='upload_to_gcs',
    python_callable=upload_to_gcs
    )
    create_staging_table = BigQueryCreateEmptyTableOperator(
    task_id='create_staging_table',
    dataset_id=DATASET_ID,
    table_id='staging_table',
    project_id=PROJECT_ID,
    schema_fields =schema_definition
)   
    load_data_to_staging = GCSToBigQueryOperator(
        task_id='load_data_to_staging',
        bucket=BUCKET,
        source_objects=["raw/{{yesterday_ds}}_SF311.csv"],  #  GCS file path
        destination_project_dataset_table='{0}.{1}.staging_table'.format(
            PROJECT_ID, DATASET_ID
        ),
        source_format='CSV',
        write_disposition='WRITE_TRUNCATE',  # Overwrite data in the staging table
        allow_quoted_newlines = True,
        autodetect=True,
        skip_leading_rows=1)
    
    dbt_tg = DbtTaskGroup(
        project_config=ProjectConfig("/opt/airflow/dbt_project"),
        profile_config=profile_config,
        execution_config=ExecutionConfig(
        execution_mode=ExecutionMode.VIRTUALENV,
    )
    )

    drop_staging_table =  BigQueryDeleteTableOperator(
    task_id="drop_staging_table",
    deletion_dataset_table='{0}.{1}.staging_table'.format(
            PROJECT_ID, DATASET_ID
        ),
)


    fetch_api_data_task>>process_data_task>> upload_to_gcs_task
    upload_to_gcs_task >> create_staging_table>>load_data_to_staging>>dbt_tg >>drop_staging_table
    
    