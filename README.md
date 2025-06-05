# todo

## Introduction

This is an example project for a simple go API on GKE and Firestore as a datasource for the API. Workload identity is used to authenticate from the pod in GKE. `pre-commit` is used within the repo as a local git hook to provide fmt, linting and doc generation for terraform.

To start using `pre-commit`, first install it and then run `pre-commit install` within the repo.

## Bootstrapping

A bootstrapping script is included initial setup of the GCP project and TF backend state, the following script only needs to be run once with configurable parameters in `./bootstrap/env.sh`:
```sh
./bootstrap/init.sh
```

## Local development

`tools/docker-build.sh` and `tools/docker-run.sh` are scripts for running the application, reading from the `.local.env` file.

## Github Workflows

`.github/workflows/terraform.yaml` - For deploying terraform changes.
`.github/workflows/deploy.yaml` - For building and deploying the application to GKE via helm chart.
