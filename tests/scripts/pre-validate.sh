#! /bin/bash

############################################################################################################
## This script is used by the catalog pipeline to provision a new resource group
## (required to ensure auth policies don't clash in account)
############################################################################################################

set -e

DA_DIR="${1}"
TERRAFORM_SOURCE_DIR="tests/new-rg"
JSON_FILE="${DA_DIR}/catalogValidationValues.json"
TF_VARS_FILE="terraform.tfvars"

(
  cwd=$(pwd)
  cd ${TERRAFORM_SOURCE_DIR}
  echo "Provisioning new resource group .."
  terraform init || exit 1
  # $VALIDATION_APIKEY is available in the catalog runtime
  {
    echo "ibmcloud_api_key=\"${VALIDATION_APIKEY}\""
    echo "prefix=\"ocp-$(openssl rand -hex 2)\""
  } >> ${TF_VARS_FILE}
  terraform apply -input=false -auto-approve -var-file=${TF_VARS_FILE} || exit 1

  rg_var_name="existing_resource_group_name"
  rg_value=$(terraform output -state=terraform.tfstate -raw resource_group_name)

  echo "Appending '${rg_var_name}', input variable value to ${JSON_FILE}.."

  cd "${cwd}"
  jq -r --arg rg_var_name "${rg_var_name}" \
        --arg rg_value "${rg_value}" \
        '. + {($rg_var_name): $rg_value}' "${JSON_FILE}" > tmpfile && mv tmpfile "${JSON_FILE}" || exit 1

  echo "Pre-validation complete successfully"
)