# Profile for IBM Cloud Framework for Financial Services

This code is a version of the [parent root module](../../) that includes a default configuration that complies with the relevant controls from the [IBM Cloud Framework for Financial Services](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-about). See the [Example for IBM Cloud Framework for Financial Services](/examples/fscloud/) for logic that uses this module.

The default values in this profile were scanned by [IBM Code Risk Analyzer (CRA)](https://cloud.ibm.com/docs/code-risk-analyzer-cli-plugin?topic=code-risk-analyzer-cli-plugin-cra-cli-plugin#terraform-command) for compliance with the IBM Cloud Framework for Financial Services profile that is specified by the IBM Security and Compliance Center.

The IBM Cloud Framework for Financial Services mandates the application of an inbound network-based allowlist in front of the IBM Cloud Secrets Manager instance. You can comply with this requirement by using the `cbr_rules` variable in the module, which can be used to create a narrow context-based restriction rule that is scoped to the Secrets Manager instance.

### Usage

```hcl
provider "ibm" {
  ibmcloud_api_key     = "XXXXXXXXXXXXXX"  # pragma: allowlist secret
  region               = "us-south"
}

module "secrets_manager" {
  source                     = "terraform-ibm-modules/secrets-manager/ibm//modules/fscloud"
  version                    = "X.X.X"  # Replace "X.X.X" with a release version to lock into a specific release
  resource_group_id          = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  region                     = "us-south"
  secrets_manager_name       = "my-secrets-manager"
  existing_kms_instance_guid = var.existing_kms_instance_guid
  kms_key_crn                = var.kms_key_crn
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
| <a name="module_secrets_manager"></a> [secrets\_manager](#module\_secrets\_manager) | ../.. | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | (list) List of CBR rules to create | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>    operations = optional(list(object({<br/>      api_types = list(object({<br/>        api_type_id = string<br/>      }))<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_event_notification"></a> [enable\_event\_notification](#input\_enable\_event\_notification) | Set this to true to enable lifecycle notifications for your Secrets Manager instance by connecting an Event Notifications service. When setting this to true, a value must be passed for `existing_en_instance_crn` variable. | `bool` | `false` | no |
| <a name="input_existing_en_instance_crn"></a> [existing\_en\_instance\_crn](#input\_existing\_en\_instance\_crn) | The CRN of the Event Notifications service to enable lifecycle notifications for your Secrets Manager instance. | `string` | `null` | no |
| <a name="input_existing_sm_instance_crn"></a> [existing\_sm\_instance\_crn](#input\_existing\_sm\_instance\_crn) | The CRN of an existing Secrets Manager instance. If not supplied, a new instance is created. | `string` | `null` | no |
| <a name="input_is_hpcs_key"></a> [is\_hpcs\_key](#input\_is\_hpcs\_key) | Set to true if the key is hpcs, otherwise false. | `bool` | `false` | no |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | The root key CRN of Key Management Service (KMS) key that you want to use for encryption. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to provision the Secrets Manager instance to. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the resource group to provision the Secrets Manager instance to. | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secret Manager secrets configurations. | <pre>list(object({<br/>    secret_group_name        = string<br/>    secret_group_description = optional(string)<br/>    existing_secret_group    = optional(bool, false)<br/>    secrets = optional(list(object({<br/>      secret_name                                 = string<br/>      secret_description                          = optional(string)<br/>      secret_type                                 = optional(string)<br/>      imported_cert_certificate                   = optional(string)<br/>      imported_cert_private_key                   = optional(string)<br/>      imported_cert_intermediate                  = optional(string)<br/>      secret_username                             = optional(string)<br/>      secret_labels                               = optional(list(string), [])<br/>      secret_payload_password                     = optional(string, "")<br/>      secret_auto_rotation                        = optional(bool, true)<br/>      secret_auto_rotation_unit                   = optional(string, "day")<br/>      secret_auto_rotation_interval               = optional(number, 89)<br/>      service_credentials_ttl                     = optional(string, "7776000") # 90 days<br/>      service_credentials_source_service_crn      = optional(string)<br/>      service_credentials_source_service_role_crn = optional(string)<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_secrets_manager_name"></a> [secrets\_manager\_name](#input\_secrets\_manager\_name) | The name to give the Secrets Manager instance. | `string` | n/a | yes |
| <a name="input_service_plan"></a> [service\_plan](#input\_service\_plan) | The Secrets Manager plan to provision. | `string` | `"standard"` | no |
| <a name="input_skip_en_iam_authorization_policy"></a> [skip\_en\_iam\_authorization\_policy](#input\_skip\_en\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits all Secrets Manager instances (scoped to the resource group) an 'Event Source Manager' role to the given Event Notifications instance passed in the `existing_en_instance_crn` input variable. In addition, no policy is created if `enable_event_notification` is set to false. | `bool` | `false` | no |
| <a name="input_skip_iam_authorization_policy"></a> [skip\_iam\_authorization\_policy](#input\_skip\_iam\_authorization\_policy) | Whether to skip the creation of the IAM authorization policies required to enable the IAM credentials engine. If set to false, policies will be created that grants the Secrets Manager instance 'Operator' access to the IAM identity service, and 'Groups Service Member Manage' access to the IAM groups service. | `bool` | `false` | no |
| <a name="input_skip_kms_iam_authorization_policy"></a> [skip\_kms\_iam\_authorization\_policy](#input\_skip\_kms\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits all Secrets Manager instances in the resource group to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the `existing_kms_instance_crn` variable. If a value is specified for `ibmcloud_kms_api_key`, the policy is created in the KMS account. | `bool` | `false` | no |
| <a name="input_sm_tags"></a> [sm\_tags](#input\_sm\_tags) | The list of resource tags that you want to associate with your Secrets Manager instance. | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_groups"></a> [secret\_groups](#output\_secret\_groups) | IDs of the created Secret Group |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | List of secret mananger secret config data |
| <a name="output_secrets_manager_crn"></a> [secrets\_manager\_crn](#output\_secrets\_manager\_crn) | CRN of the Secrets Manager instance |
| <a name="output_secrets_manager_guid"></a> [secrets\_manager\_guid](#output\_secrets\_manager\_guid) | GUID of Secrets Manager instance |
| <a name="output_secrets_manager_id"></a> [secrets\_manager\_id](#output\_secrets\_manager\_id) | ID of the Secrets Manager instance |
| <a name="output_secrets_manager_name"></a> [secrets\_manager\_name](#output\_secrets\_manager\_name) | Name of the Secrets Manager instance |
| <a name="output_secrets_manager_region"></a> [secrets\_manager\_region](#output\_secrets\_manager\_region) | Region of the Secrets Manager instance |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
