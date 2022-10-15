#!/usr/bin/env bash
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

CLUSTER_NAME=${1}

if [ -z "${CLUSTER_NAME}" ]; then
  echo "Usage: $0 <cluster-name>"
  exit 1
fi

gcloud secrets delete ${CLUSTER_NAME}_env --quiet 2> /dev/null || true
gcloud secrets delete ${CLUSTER_NAME}_app_config --quiet 2> /dev/null || true

echo ok.