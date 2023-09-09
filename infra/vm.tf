resource "google_compute_instance" "vm" {
  project                   = var.project_id
  
  name                      = "de-zoomcamp"
  machine_type              = "e2-standard-4"
  allow_stopping_for_update = true

  
  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20230817"
      size  = "30"
    }
  }
  network_interface {
    network = "default"

    access_config {
      
    }
  }
}