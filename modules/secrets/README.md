# Secret Manager secrets module

You can use this submodule to create of secret groups or secrets in an existing Secret Manager instance.

The submodule extends the [secrets](https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager-secret) and [secret_group](https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager-secret-group) module by including support for multiple secrets.

### Usage

```hcl
provider "ibm" {
  ibmcloud_api_key     = "XXXXXXXXXXXXXX"  # pragma: allowlist secret
  region               = "us-south"
}

module "secrets_manager" {
  source                     = "terraform-ibm-modules/secrets-manager/ibm//modules/secrets"
  version                     = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  existing_sm_instance_guid   = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  existing_sm_instance_region = "us-south"
  endpoint_type               = "public"
  secrets = [{
    secret_group_name = "secret-group"
    secrets = [{
      secret_name             = "secret1"
      secret_type             = "arbitrary"
      secret_username         = "test"
      secret_payload_password = "test"
      },
      {
        secret_name             = "secret2"
        secret_type             = "arbitrary"
        secret_username         = "test"
        secret_payload_password = "test"
      }
    ]
    }
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.62.0, <2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_secret_groups"></a> [secret\_groups](#module\_secret\_groups) | terraform-ibm-modules/secrets-manager-secret-group/ibm | 1.2.2 |
| <a name="module_secrets"></a> [secrets](#module\_secrets) | terraform-ibm-modules/secrets-manager-secret/ibm | 1.7.0 |

### Resources

| Name | Type |
|------|------|
| [ibm_sm_secret_groups.existing_secret_groups](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/sm_secret_groups) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_endpoint_type"></a> [endpoint\_type](#input\_endpoint\_type) | The service endpoint type to communicate with the provided secrets manager instance. Possible values are `public` or `private` | `string` | `"public"` | no |
| <a name="input_existing_sm_instance_guid"></a> [existing\_sm\_instance\_guid](#input\_existing\_sm\_instance\_guid) | Instance ID of Secrets Manager instance in which the Secret will be added. | `string` | n/a | yes |
| <a name="input_existing_sm_instance_region"></a> [existing\_sm\_instance\_region](#input\_existing\_sm\_instance\_region) | Region which the Secret Manager is deployed. | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secret Manager secrets configurations. | <pre>list(object({<br/>    secret_group_name        = string<br/>    secret_group_description = optional(string)<br/>    existing_secret_group    = optional(bool, false)<br/>    secrets = optional(list(object({<br/>      secret_name                                 = string<br/>      secret_description                          = optional(string)<br/>      secret_type                                 = optional(string)<br/>      imported_cert_certificate                   = optional(string)<br/>      imported_cert_private_key                   = optional(string)<br/>      imported_cert_intermediate                  = optional(string)<br/>      secret_username                             = optional(string)<br/>      secret_labels                               = optional(list(string), [])<br/>      secret_payload_password                     = optional(string, "")<br/>      secret_auto_rotation                        = optional(bool, true)<br/>      secret_auto_rotation_unit                   = optional(string, "day")<br/>      secret_auto_rotation_interval               = optional(number, 89)<br/>      service_credentials_ttl                     = optional(string, "7776000") # 90 days<br/>      service_credentials_source_service_crn      = optional(string)<br/>      service_credentials_source_service_role_crn = optional(string)<br/>      service_credentials_source_service_hmac     = optional(bool, false)<br/>    })))<br/>  }))</pre> | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_groups"></a> [secret\_groups](#output\_secret\_groups) | IDs of the created Secret Group |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | List of secret mananger secret config data |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
