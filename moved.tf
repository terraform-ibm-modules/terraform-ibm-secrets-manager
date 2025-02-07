moved {
  from = ibm_resource_instance.secrets_manager_instance
  to   = ibm_resource_instance.secrets_manager_instance[0]
}
