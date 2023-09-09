locals {
  region = "asia-east1"
  zone    = "asia-east1-a"
  data_lake_bucket = "dtc_data_lake"
}

variable "project_id" {
  description = "project id"
  type = string
  default = "sf311-396506"
}
variable "storage_class" {
  description = "Storage class type for your bucket. Check official docs for more info."
  default = "STANDARD"
}

variable "BQ_DATASET_DEV" {
  description = "BigQuery Dataset that raw data (from GCS) will be written to"
  type = string
  default = "SF311_DEV"
}

variable "BQ_DATASET_PROD" {
  description = "BigQuery Dataset that raw data (from GCS) will be written to"
  type = string
  default = "SF311_PROD"
}

variable "BQ_DATASET_RAW" {
  description = "BigQuery Dataset that raw data (from GCS) will be written to"
  type = string
  default = "SF311_RAW"
}

