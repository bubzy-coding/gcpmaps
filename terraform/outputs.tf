output "cloud_run_url" {
  value = google_cloud_run_service.lines_api.status[0].url
}
