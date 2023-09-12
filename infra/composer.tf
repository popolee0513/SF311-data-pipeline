
resource "google_project_service" "composer_api" {
  provider = google-beta
  project = var.project_id
  service = "composer.googleapis.com"
  // Disabling Cloud Composer API might irreversibly break all other
  // environments in your project.
  disable_on_destroy = false
}



resource "google_composer_environment" "dev_environment" {
  provider = google-beta
  name = "dev-environment"
  project = var.project_id
  region  =  local.region
  
  config {
    software_config {
      image_version = "composer-2.4.1-airflow-2.5.3"
    }
    
    environment_size = "ENVIRONMENT_SIZE_SMALL"
    node_config {
    service_account = "sf311-298@sf311-396506.iam.gserviceaccount.com"
    }
  }
}