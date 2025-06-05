#!/bin/bash
set -euo pipefail

app_name='todo'
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
app_dir="${script_dir}/.."

docker run -it \
  -p 8080:8080 \
  --env-file "${app_dir}/.local.env" \
  --env GOOGLE_APPLICATION_CREDENTIALS=/gcp/creds.json \
  -v "${HOME}/.config/gcloud/application_default_credentials.json:/gcp/creds.json" \
  "${app_name}-local"
