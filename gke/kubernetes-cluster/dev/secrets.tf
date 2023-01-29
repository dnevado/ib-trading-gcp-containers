

resource "google_project_service" "secretmanager" {
  provider = google-beta
  service  = "secretmanager.googleapis.com"
  project      = var.project_id
}

resource "time_sleep" "secretmanager_gcp_wait_crm_api_enabling" {
  depends_on = [
    google_project_service.secretmanager
  ]

  create_duration = "1m"
}


resource "google_secret_manager_secret" "credentials-ibuser-gw-paper" {
  provider = google-beta

  secret_id = "credentials-ibuser-gw-paper-${var.env}"
  project      = var.project_id
  replication {
    automatic = true
  }

  depends_on = [google_project_service.secretmanager]
}

# secrets version creation 
resource "google_secret_manager_secret_version" "credentials-ibuser-gw-paper-1" {
  provider = google-beta

  secret      = google_secret_manager_secret.credentials-ibuser-gw-paper.id
  secret_data = "Initial user  @yahoo.es"
}


resource "google_secret_manager_secret" "credentials-ibpassword-gw-paper" {
  provider = google-beta
  project      = var.project_id
  secret_id = "credentials-ibpassword-gw-paper-${var.env}"

  replication {
    automatic = true
  }

  depends_on = [google_project_service.secretmanager]
}
# secrets version creation 
resource "google_secret_manager_secret_version" "credentials-ibpassword-gw-paper-1" {
  provider = google-beta

  secret      = google_secret_manager_secret.credentials-ibpassword-gw-paper.id
  secret_data = "Initial password  10203040 ex "
}


