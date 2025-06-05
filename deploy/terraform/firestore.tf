resource "google_firestore_database" "default" {
  depends_on  = [google_project_service.firestore]
  project     = var.project_id
  name        = "(default)"
  location_id = var.primary_region
  type        = "FIRESTORE_NATIVE"
}
