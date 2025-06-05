terraform {
  backend "gcs" {
    bucket = "abw-todo-tf-state"
    prefix = "prod"
  }
}
