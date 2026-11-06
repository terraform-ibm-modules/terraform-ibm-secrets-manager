moved {
  from = ibm_resource_instance.secrets_manager_instance
  to   = ibm_resource_instance.secrets_manager_instance[0]
}

# `module.secrets` is skipped for the `dedicated` plan, so it now uses `count`
moved {
  from = module.secrets
  to   = module.secrets[0]
}
