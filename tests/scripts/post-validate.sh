#! /bin/bash

########################################################################################################################
## This script is used by the catalog pipeline to destroy prerequisite resource required for catalog validation       ##
########################################################################################################################

set -e

TERRAFORM_SOURCE_DIR="tests/new-rg"
TF_VARS_FILE="terraform.tfvars"

(
  cd ${TERRAFORM_SOURCE_DIR}
  echo "Destroying resource group .."
  terraform destroy -input=false -auto-approve -var-file=${TF_VARS_FILE} || exit 1
  rm -f "${TF_VARS_FILE}"

  echo "Post-validation completed successfully"
)
