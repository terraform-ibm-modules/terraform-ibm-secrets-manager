moved {
  from = module.secrets_manager.ibm_resource_instance.secrets_manager_instance
  to   = module.secrets_manager.module.secrets_manager.ibm_resource_instance.secrets_manager_instance
}

moved {
  from = module.secrets_manager.ibm_iam_authorization_policy.kms_policy
  to   = module.secrets_manager.module.secrets_manager.ibm_iam_authorization_policy.kms_policy
}

moved {
  from = module.secrets_manager.time_sleep.wait_for_authorization_policy
  to   = module.secrets_manager.module.secrets_manager.time_sleep.wait_for_authorization_policy
}

moved {
  from = module.secrets_manager.ibm_iam_authorization_policy.en_policy
  to   = module.secrets_manager.module.secrets_manager.ibm_iam_authorization_policy.en_policy
}

moved {
  from = module.secrets_manager.ibm_sm_en_registration.sm_en_registration
  to   = module.secrets_manager.module.secrets_manager.ibm_sm_en_registration.sm_en_registration
}
