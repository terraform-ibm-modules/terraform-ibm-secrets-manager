# Secrets Manager module


[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-secrets-manager?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!-- Add a description of module(s) in this repo -->
This module is used to provision and configure an IBM Cloud [Secrets Manager](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-getting-started) instance.


<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-secrets-manager](#terraform-ibm-secrets-manager)
* [Submodules](./modules)
    * [fscloud](./modules/fscloud)
    * [secrets](./modules/secrets)
* [Examples](./examples)
    * [Advanced example](./examples/advanced)
    * [Basic example](./examples/basic)
    * [Financial Services Cloud profile example with KYOK encryption](./examples/fscloud)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->

## terraform-ibm-secrets-manager

### Usage

```hcl
provider "ibm" {
  ibmcloud_api_key     = "XXXXXXXXXXXXXX"  # pragma: allowlist secret
  region               = "us-south"
}

module "secrets_manager" {
  source               = "terraform-ibm-modules/secrets-manager/ibm"
  version              = "X.X.X"  # Replace "X.X.X" with a release version to lock into a specific release
  resource_group_id    = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  region               = "us-south"
  secrets_manager_name = "my-secrets-manager"
  sm_service_plan      = "trial"
}
```


## Required IAM access policies
You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
    - IAM Services
        - **Secrets Manager** service
            - `Administrator` platform access
            - `Manager` service access


<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= v1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.79.0, <2.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.33.4 |
| <a name="module_kms_key_crn_parser"></a> [kms\_key\_crn\_parser](#module\_kms\_key\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.2.0 |
| <a name="module_secrets"></a> [secrets](#module\_secrets) | ./modules/secrets | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.en_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.iam_groups_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.iam_identity_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.kms_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.secrets_manager_hpcs_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_resource_instance.secrets_manager_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_sm_en_registration.sm_en_registration](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_en_registration) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_sm_hpcs_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [ibm_resource_instance.sm_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_network"></a> [allowed\_network](#input\_allowed\_network) | The types of service endpoints to set on the Secrets Manager instance. Possible values are `private-only` or `public-and-private`. [Learn more](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-endpoints#service-endpoints). | `string` | `"public-and-private"` | no |
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | (Optional, list) List of context-based restriction rules to create | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>    operations = optional(list(object({<br/>      api_types = list(object({<br/>        api_type_id = string<br/>      }))<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_event_notification"></a> [enable\_event\_notification](#input\_enable\_event\_notification) | Set to true to enable lifecycle notifications for your Secrets Manager instance by connecting an Event Notifications service. When set to `true`, a value must be passed for `existing_en_instance_crn` and `existing_sm_instance_crn` must be set to `null`. | `bool` | `false` | no |
| <a name="input_endpoint_type"></a> [endpoint\_type](#input\_endpoint\_type) | The type of endpoint (public or private) to connect to the Secrets Manager API. The Terraform provider uses this endpoint type to interact with the Secrets Manager API and configure Event Notifications. | `string` | `"public"` | no |
| <a name="input_existing_en_instance_crn"></a> [existing\_en\_instance\_crn](#input\_existing\_en\_instance\_crn) | The CRN of the Event Notifications service to enable lifecycle notifications for your Secrets Manager instance. | `string` | `null` | no |
| <a name="input_existing_sm_instance_crn"></a> [existing\_sm\_instance\_crn](#input\_existing\_sm\_instance\_crn) | An existing Secrets Manager instance CRN. If not provided, a new instance is created. | `string` | `null` | no |
| <a name="input_is_hpcs_key"></a> [is\_hpcs\_key](#input\_is\_hpcs\_key) | Set to `true` if the key provided through the `kms_key_crn` is a Hyper Protect Crypto Services key. | `bool` | `false` | no |
| <a name="input_kms_encryption_enabled"></a> [kms\_encryption\_enabled](#input\_kms\_encryption\_enabled) | Set to `true` to control the encryption keys that are used to encrypt the data that you store in Secrets Manager. If set to `false`, the data that you store is encrypted at rest by using envelope encryption. For more details, go to  [About customer-managed keys](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-mng-data&interface=ui#about-encryption). | `bool` | `false` | no |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | The root key CRN of a key management service like Key Protect or Hyper Protect Crypto Services that you want to use for encryption. Only used if `kms_encryption_enabled` is set to `true`. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the instance is created. Not required if passing a value for `existing_sm_instance_crn`. | `string` | `null` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the resource group that contains the Secrets Manager instance. | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secret Manager secrets configurations. | <pre>list(object({<br/>    secret_group_name        = string<br/>    secret_group_description = optional(string)<br/>    existing_secret_group    = optional(bool, false)<br/>    create_access_group      = optional(bool, false)<br/>    access_group_name        = optional(string)<br/>    access_group_roles       = optional(list(string))<br/>    access_group_tags        = optional(list(string))<br/>    secrets = optional(list(object({<br/>      secret_name                                 = string<br/>      secret_description                          = optional(string)<br/>      secret_type                                 = optional(string)<br/>      imported_cert_certificate                   = optional(string)<br/>      imported_cert_private_key                   = optional(string)<br/>      imported_cert_intermediate                  = optional(string)<br/>      secret_username                             = optional(string)<br/>      secret_labels                               = optional(list(string), [])<br/>      secret_payload_password                     = optional(string, "")<br/>      secret_auto_rotation                        = optional(bool, true)<br/>      secret_auto_rotation_unit                   = optional(string, "day")<br/>      secret_auto_rotation_interval               = optional(number, 89)<br/>      service_credentials_ttl                     = optional(string, "7776000") # 90 days<br/>      service_credentials_source_service_crn      = optional(string)<br/>      service_credentials_source_service_role_crn = optional(string)<br/>      custom_credentials_configurations           = optional(string)<br/>      custom_credentials_parameters               = optional(bool, false)<br/>      job_parameters = optional(object({<br/>        integer_values = optional(map(number))<br/>        string_values  = optional(map(string))<br/>        boolean_values = optional(map(bool))<br/>      }), {})<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_secrets_manager_name"></a> [secrets\_manager\_name](#input\_secrets\_manager\_name) | The name of the Secrets Manager instance to create | `string` | n/a | yes |
| <a name="input_skip_en_iam_authorization_policy"></a> [skip\_en\_iam\_authorization\_policy](#input\_skip\_en\_iam\_authorization\_policy) | Set to true to skip creating an IAM authorization policy that permits all Secrets Manager instances (scoped to the resource group) an 'Event Source Manager' role to the given Event Notifications instance passed in the `existing_en_instance_crn` input variable. No policy is created if `enable_event_notification` is set to `false`. | `bool` | `false` | no |
| <a name="input_skip_iam_authorization_policy"></a> [skip\_iam\_authorization\_policy](#input\_skip\_iam\_authorization\_policy) | Whether to skip creating the IAM authorization policies that are required to enable the IAM credentials engine. If set to `false`, policies are created that grant the Secrets Manager instance 'Operator' access to the IAM identity service, and 'Groups Service Member Manager' access to the IAM groups service. | `bool` | `false` | no |
| <a name="input_skip_kms_iam_authorization_policy"></a> [skip\_kms\_iam\_authorization\_policy](#input\_skip\_kms\_iam\_authorization\_policy) | Whether to skip creating the IAM authorization policies that are required to enable the IAM credentials engine. If set to false, policies are created that grant the Secrets Manager instance 'Operator' access to the IAM identity service, and 'Groups Service Member Manager' access to the IAM groups service. | `bool` | `false` | no |
| <a name="input_sm_service_plan"></a> [sm\_service\_plan](#input\_sm\_service\_plan) | The Secrets Manager plan to provision. | `string` | `"standard"` | no |
| <a name="input_sm_tags"></a> [sm\_tags](#input\_sm\_tags) | The list of resource tags to associate with your Secrets Manager instance. | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_groups"></a> [secret\_groups](#output\_secret\_groups) | IDs of the secret groups |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | List of Secrets Manager secret configuration data |
| <a name="output_secrets_manager_crn"></a> [secrets\_manager\_crn](#output\_secrets\_manager\_crn) | CRN of the Secrets Manager instance |
| <a name="output_secrets_manager_guid"></a> [secrets\_manager\_guid](#output\_secrets\_manager\_guid) | GUID of Secrets Manager instance |
| <a name="output_secrets_manager_id"></a> [secrets\_manager\_id](#output\_secrets\_manager\_id) | ID of the Secrets Manager instance |
| <a name="output_secrets_manager_name"></a> [secrets\_manager\_name](#output\_secrets\_manager\_name) | Name of the Secrets Manager instance |
| <a name="output_secrets_manager_region"></a> [secrets\_manager\_region](#output\_secrets\_manager\_region) | Region of the Secrets Manager instance |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
