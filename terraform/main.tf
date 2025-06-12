provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_artifact_registry_repository" "docker_repo" {
  name     = "lines-app"
  format   = "DOCKER"
  location = var.region
}

resource "google_cloud_run_service" "lines_api" {
  name     = "lines-api"
  location = var.region

  template {
    spec {
      containers {
        image = var.image_url
      }
      service_account_name = google_service_account.cloud_run.id
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}

resource "google_service_account" "cloud_run" {
  account_id   = "cloudrun-lines"
  display_name = "Cloud Run BigQuery Access"
}

resource "google_project_iam_member" "bq_access" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_service.lines_api.location
  service  = google_cloud_run_service.lines_api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
