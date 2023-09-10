# End to End SF311 Data Pipeline

## Project Overview: Enhancing Civic Insights with SF311 Data
This project is dedicated to the strategic application of Data Engineering methodologies for in-depth analysis of SF311 data, a vital civic service in San Francisco. The project's core technical objectives encompass:

1. **Data Extraction**: Efficient retrieval of comprehensive SF311 data through API integration.

2. **Data Ingestion and Storage**: Organizing the raw data in a Data Lake, establishing a centralized repository in Google Cloud Storage (GCS) for accessibility and preservation, and further uploading it to BigQuery.

3. **Data Transformation**: Leveraging dbt (data build tool) for high-level transformations, structuring, cleaning, and processing the data to enhance data quality and facilitate in-depth analysis.

4. **Data Visualization**: Employing powerful visualization tools and techniques to present meaningful insights in an accessible and actionable manner.

The Data Warehouse architecture is meticulously designed with three essential layers:

- **Raw Data Ingestion**: Utilizing BigQuery for direct interaction with the data stored in GCS, ensuring the availability of raw data.

- **Data Preparation Sub-layer**: Within the Data Transformation Layer, we create staging tables for a specific date, preparing the data for further processing. 

- **Data Integration Sub-layer**: After staging, data is loaded into destination tables using dbt's incremental strategy, which includes data cleaning and deduplication steps. This sub-layer ensures data quality and prepares it for aggregation.

- **Data Aggregation and Metrics Calculation**: The core layer focuses on aggregating and analyzing the cleaned data to calculate various metrics and generate valuable insights.

**Orchestration** is seamlessly managed using Apache Airflow, ensuring a smooth, automated data pipeline from data extraction to transformation.

<img src="https://github.com/popolee0513/SF311-data-pipeline/raw/main/Images/architecture.JPG" alt="Data Pipeline Architecture" width="80%">

This project's technical focus aims to empower stakeholders with advanced Data Engineering capabilities, enabling the extraction of valuable civic insights from SF311 data. These insights are instrumental in enhancing municipal services and contributing to the well-being of the community.


# Dataset
The dataset chosen for my data engineering project is derived from [SF311](https://data.sfgov.org/City-Infrastructure/311-Cases/vw6y-z8j6), a municipal service formally established by the City and County of San Francisco. SF311 serves as a pivotal communications channel, seamlessly connecting residents, businesses, and visitors with a dedicated team of Customer Service Representatives. This service plays a fundamental role in facilitating a wide spectrum of government-related inquiries and services, ranging from reporting issues related to public spaces and infrastructure, to seeking information on various administrative matters.

# Technologies and Tools
For this project I decided to use the following tools:
- Infrastructure as Code: *`Terraform`*
- Workflow orchestration: *`Airflow`*
- VM instance to run the whole data pipeline: *Google Compute Engine*
- Data Lake: *Google Cloud Storage*
- Data Warehouse: Google *BigQuery*
- Data Transformation: *DBT*
- Data Visualization: *Google Looker Studio*


  
