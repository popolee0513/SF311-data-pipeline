FROM apache/airflow:2.7.0
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN python -m venv dbt_venv          # Create the virtual environment if it doesn't exist
RUN source dbt_venv/bin/activate    # Activate the virtual environment
RUN pip install --upgrade pip       # Upgrade pip inside the virtual environment
RUN pip install --no-cache-dir dbt-bigquery dbt-core
RUN exit 
USER $AIRFLOW_UID