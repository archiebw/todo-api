#!/bin/bash
set -euo pipefail

app_name='todo'
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
app_dir=$(cd "${script_dir}/.." && pwd)

cd "$app_dir"
docker build -t "${app_name}-local" .
