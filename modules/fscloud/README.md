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
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | (list) List of CBR rules to create | <pre>list(object({<br>    description = string<br>    account_id  = string<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>    }))) }))<br>    enforcement_mode = string<br>  }))</pre> | `[]` | no |
| <a name="input_enable_event_notification"></a> [enable\_event\_notification](#input\_enable\_event\_notification) | Set this to true to enable lifecycle notifications for your Secrets Manager instance by connecting an Event Notifications service. When setting this to true, a value must be passed for `existing_en_instance_crn` variable. | `bool` | `false` | no |
| <a name="input_existing_en_instance_crn"></a> [existing\_en\_instance\_crn](#input\_existing\_en\_instance\_crn) | The CRN of the Event Notifications service to enable lifecycle notifications for your Secrets Manager instance. | `string` | `null` | no |
| <a name="input_existing_kms_instance_guid"></a> [existing\_kms\_instance\_guid](#input\_existing\_kms\_instance\_guid) | The GUID of the Hyper Protect Crypto Services instance in which the key specified in `kms_key_crn` is coming from. | `string` | n/a | yes |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | The root key CRN of Hyper Protect Crypto Services (HPCS) that you want to use for encryption. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to provision the Secrets Manager instance to. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the resource group to provision the Secrets Manager instance to. | `string` | n/a | yes |
| <a name="input_secrets_manager_name"></a> [secrets\_manager\_name](#input\_secrets\_manager\_name) | The name to give the Secrets Manager instance. | `string` | n/a | yes |
| <a name="input_service_plan"></a> [service\_plan](#input\_service\_plan) | The Secrets Manager plan to provision. | `string` | `"standard"` | no |
| <a name="input_skip_en_iam_authorization_policy"></a> [skip\_en\_iam\_authorization\_policy](#input\_skip\_en\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits all Secrets Manager instances (scoped to the resource group) an 'Event Source Manager' role to the given Event Notifications instance passed in the `existing_en_instance_crn` input variable. In addition, no policy is created if `enable_event_notification` is set to false. | `bool` | `false` | no |
| <a name="input_sm_tags"></a> [sm\_tags](#input\_sm\_tags) | The list of resource tags that you want to associate with your Secrets Manager instance. | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_secrets_manager_crn"></a> [secrets\_manager\_crn](#output\_secrets\_manager\_crn) | CRN of the Secrets Manager instance |
| <a name="output_secrets_manager_guid"></a> [secrets\_manager\_guid](#output\_secrets\_manager\_guid) | GUID of Secrets Manager instance |
| <a name="output_secrets_manager_id"></a> [secrets\_manager\_id](#output\_secrets\_manager\_id) | ID of the Secrets Manager instance |
| <a name="output_secrets_manager_name"></a> [secrets\_manager\_name](#output\_secrets\_manager\_name) | Name of the Secrets Manager instance |
| <a name="output_secrets_manager_region"></a> [secrets\_manager\_region](#output\_secrets\_manager\_region) | Region of the Secrets Manager instance |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
