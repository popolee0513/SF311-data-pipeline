resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "tf-state-bucket" {
  name     = "tf-state-bucket-${random_id.bucket_prefix.hex}"
  force_destroy = false
  location      = local.region
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

output "tf_state_bucket" {
  value = google_storage_bucket.tf-state-bucket.name
}