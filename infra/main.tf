terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.5.0"
    }
      }
    backend "gcs" {
    bucket = "tf-state-bucket-0d5c86aa742b55e6" 
    
    prefix = "terraform/state"
  }

}
provider "google" {
  project = var.project_id
  region  =  local.region
  zone    =  local.zone
}

resource "google_storage_bucket" "data-lake-bucket" {
  name                        = "${local.data_lake_bucket}_${var.project_id}"
  location                    = local.region
  storage_class               = var.storage_class
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 40
    }
  }
  force_destroy = true  
  /*If you try to delete a bucket that contains objects, Terraform will fail that run(you can't delete a bucket unless it's empty)
  setting force_destroy = True enables you to delete the bucket successfully*/
}

resource "google_bigquery_dataset" "raw_dataset" {
  dataset_id = var.BQ_DATASET_RAW
  project    = var.project_id
  location   = local.region
  delete_contents_on_destroy = true
}

resource "google_bigquery_dataset" "dev_dataset" {
  dataset_id = var.BQ_DATASET_DEV
  project    = var.project_id
  location   = local.region
  delete_contents_on_destroy = true
}

resource "google_bigquery_dataset" "prod_dataset" {
  dataset_id = var.BQ_DATASET_PROD
  project    = var.project_id
  location   = local.region
  delete_contents_on_destroy = true
}








