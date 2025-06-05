#!/bin/bash
set -euo pipefail

# Script Root for this script, used to source environment.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
# Import the environment variables
source "$DIR/env.sh"

EXISTING_PROJECT=$(gcloud projects list --filter=name:"${GCP_PROJECT}" --format=json)
if [[ "$EXISTING_PROJECT" == "[]" ]]
  then
    gcloud projects create "$GCP_PROJECT"
  else
    echo -e "Project: The Project ($GCP_PROJECT) exists."
fi
gcloud config set project "$GCP_PROJECT"

# Enable the required services
for svc in $REQUIRED_SERVICES
do
  echo -e "Project: Enabling $svc."
  gcloud services enable "$svc"
done

# Create the user if it does not exist
EXISTING_USER=$(gcloud iam service-accounts list --format=json --filter=name:terraform)

if [[ "$EXISTING_USER" == "[]" ]]
  then
    echo -e "Terraform User: The Terraform does not exist yet, creating it and granting permissions."
    gcloud iam service-accounts create terraform --display-name "Terraform admin account"

    echo -e "Terraform User: Downloading JSON credentials."
    gcloud iam service-accounts keys create "${GCP_CREDENTIALS}" --iam-account="terraform@${GCP_PROJECT}.iam.gserviceaccount.com"
  else
    echo -e "Terraform User: The account already exists."
fi

# Assign roles for the user, don't need to check first as this works repeatedly
for prole in $PROJECT_ROLES
do
  echo -e "Terraform User: Granting $prole role to the Admin Project ($GCP_PROJECT)."
  gcloud projects add-iam-policy-binding "${GCP_PROJECT}" --member "serviceAccount:terraform@${GCP_PROJECT}.iam.gserviceaccount.com" --role "$prole"
done

# Create terraform backend
if (gsutil ls "${TF_STATE_BUCKET}" &>/dev/null)
  then
    echo -e "TF State: The Terraform state bucket ($TF_STATE_BUCKET) for ($GCP_PROJECT) already exists."
  else
    echo -e "Tf State: Creating Terraform state bucket ($TF_STATE_BUCKET) for ($GCP_PROJECT)."
    gsutil mb -p "${GCP_PROJECT}" -c multi_regional -b on "${TF_STATE_BUCKET}"
    gsutil versioning set on "${TF_STATE_BUCKET}"
fi

# All done
echo -e "Bootstrap: Bootstrapping Complete."
