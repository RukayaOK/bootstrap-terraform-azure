#!/bin/bash
set -e

# Global Variables
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

###### DELETING RESOURCE GROUP ######
az group delete \
        --name "${TF_VAR_resource_group_name}" \
        --yes

###### DELETING SERVICE PRINCIPAL ######
service_principal_object_id=$(az ad sp list \
                --filter "displayName eq '$TF_VAR_service_principal_name'" \
                --query '[].id' \
                -o json --only-show-errors | jq -r '.[0]')

az ad sp delete \
        --id "${service_principal_object_id}"


###### DELETING LOCAL TERRAFORM FILES (for local runs) ######
rm ${SCRIPT_DIR}/../projects/${PROJECT_NAME}/.terraform.lock.hcl || true
rm ${SCRIPT_DIR}/../projects/${PROJECT_NAME}/*.tfstate || true
rm ${SCRIPT_DIR}/../projects/${PROJECT_NAME}/*.tfstate.backup || true
rm -rf ${SCRIPT_DIR}/${PROJECT_NAME}/.terraform || true