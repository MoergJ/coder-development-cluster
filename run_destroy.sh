#!/usr/bin/env bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ -f ${SCRIPT_DIR}/config/env ]; then
  . ${SCRIPT_DIR}/config/env
fi

GCLOUD_PROJECT=${1:-${GCLOUD_PROJECT}}
CLUSTER_NAME=${2:-${CLUSTER_NAME}}
UNINSTALL_APPS=${3:-true}

if [ -z "${CLUSTER_NAME}" ] || [ -z "${GCLOUD_PROJECT}" ]; then
  echo "Usage: $0 <GCLOUD_PROJECT> <CLUSTER_NAME> [UNINSTALL_APPS 'true' or 'false' default 'true']"
  exit 1
fi

${SCRIPT_DIR}/activate_service_account.sh ${GCLOUD_PROJECT}

${SCRIPT_DIR}/secrets_get.sh ${GCLOUD_PROJECT} ${CLUSTER_NAME}


ansible-playbook -i inventory ${SCRIPT_DIR}/automate/tf_vars.yml

export GOOGLE_APPLICATION_CREDENTIALS=${SCRIPT_DIR}/config/google-cloud.json

terraform -chdir=${SCRIPT_DIR}/infrastructure/google init \
    -backend-config="bucket=${BUCKET_NAME}" \
    -backend-config="prefix=tf-state/${CLUSTER_NAME}" \

if [[ ! ${UNINSTALL_APPS} == "false" ]]; then
  ${SCRIPT_DIR}/get_kubeconfig.sh
  IP_ADDRESS=$(terraform -chdir=${SCRIPT_DIR}/infrastructure/google output -raw ip_address)
  ansible-playbook -i inventory ${SCRIPT_DIR}/automate/destroy.yml -e ip_address=${IP_ADDRESS}
fi

terraform -chdir=${SCRIPT_DIR}/infrastructure/google destroy -auto-approve