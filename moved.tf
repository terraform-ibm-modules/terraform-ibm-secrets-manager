moved {
  from = ibm_iam_authorization_policy.policy
  to   = ibm_iam_authorization_policy.kms_policy
}

moved {
  from = ibm_resource_instance.secrets_manager_instance
  to   = ibm_resource_instance.secrets_manager_instance[0]
}
