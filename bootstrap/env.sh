#!/bin/bash
export GCP_PROJECT=abw-todo
export GCP_CREDENTIALS="$HOME/.config/gcloud/${GCP_PROJECT}-service-account.json"
export TF_STATE_BUCKET=gs://${GCP_PROJECT}-tf-state
export PROJECT_ROLES='roles/storage.admin roles/editor roles/iam.serviceAccountTokenCreator'
export REQUIRED_SERVICES='cloudresourcemanager.googleapis.com'
