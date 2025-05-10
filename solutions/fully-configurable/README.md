# Secrets Manager fully-configurable solution

This solution supports the following:
- Taking in an existing resource group.
- Provisioning and configuring of a Secrets Manager instance.
- Provisioning secrets groups inside a new or pre-existing Secrets Manager instance.
- Provisioning access groups to the secrets groups of the Secrets Manager instance.
- Configuring KMS encryption using a newly created key, or passing an existing key.

![secret-manager-deployable-architecture](../../reference-architecture/secrets_manager.svg)

**NB:** This solution is not intended to be called by one or more other modules since it contains a provider configurations, meaning it is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.76.2 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.13.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-ibm-modules/kms-all-inclusive/ibm | 5.1.2 |
| <a name="module_kms_instance_crn_parser"></a> [kms\_instance\_crn\_parser](#module\_kms\_instance\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |
| <a name="module_kms_key_crn_parser"></a> [kms\_key\_crn\_parser](#module\_kms\_key\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.2.0 |
| <a name="module_secrets_manager"></a> [secrets\_manager](#module\_secrets\_manager) | ../.. | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_en_subscription_email.email_subscription](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.76.2/docs/resources/en_subscription_email) | resource |
| [ibm_en_topic.en_topic](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.76.2/docs/resources/en_topic) | resource |
| [ibm_iam_authorization_policy.kms_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.76.2/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.secrets_manager_hpcs_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.76.2/docs/resources/iam_authorization_policy) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/0.13.0/docs/resources/sleep) | resource |
| [time_sleep.wait_for_secrets_manager](https://registry.terraform.io/providers/hashicorp/time/0.13.0/docs/resources/sleep) | resource |
| [time_sleep.wait_for_sm_hpcs_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/0.13.0/docs/resources/sleep) | resource |
| [ibm_en_destinations.en_destinations](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.76.2/docs/data-sources/en_destinations) | data source |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.76.2/docs/data-sources/iam_account_settings) | data source |
| [ibm_resource_instance.existing_sm](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.76.2/docs/data-sources/resource_instance) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_network"></a> [allowed\_network](#input\_allowed\_network) | The types of service endpoints to set on the Secrets Manager instance. Possible values are `private-only` or `public-and-private`. | `string` | `"private-only"` | no |
| <a name="input_event_notifications_email_list"></a> [event\_notifications\_email\_list](#input\_event\_notifications\_email\_list) | The list of email address to target out when Secrets Manager triggers an event | `list(string)` | `[]` | no |
| <a name="input_event_notifications_from_email"></a> [event\_notifications\_from\_email](#input\_event\_notifications\_from\_email) | The email address used to send any Secrets Manager event coming via Event Notifications | `string` | `"compliancealert@ibm.com"` | no |
| <a name="input_event_notifications_reply_to_email"></a> [event\_notifications\_reply\_to\_email](#input\_event\_notifications\_reply\_to\_email) | The email address specified in the 'reply\_to' section for any Secret Manager event coming via Event Notifications | `string` | `"no-reply@ibm.com"` | no |
| <a name="input_existing_event_notifications_instance_crn"></a> [existing\_event\_notifications\_instance\_crn](#input\_existing\_event\_notifications\_instance\_crn) | The CRN of the Event Notifications service used to enable lifecycle notifications for your Secrets Manager instance. | `string` | `null` | no |
| <a name="input_existing_kms_instance_crn"></a> [existing\_kms\_instance\_crn](#input\_existing\_kms\_instance\_crn) | The CRN of the KMS instance (Hyper Protect Crypto Services or Key Protect). Required only if `existing_secrets_manager_crn` or `existing_secrets_manager_kms_key_crn` is not specified. If the KMS instance is in different account you must also provide a value for `ibmcloud_kms_api_key`. | `string` | `null` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | The name of an existing resource group to provision resource in. | `string` | `"Default"` | no |
| <a name="input_existing_secrets_manager_crn"></a> [existing\_secrets\_manager\_crn](#input\_existing\_secrets\_manager\_crn) | The CRN of an existing Secrets Manager instance. If not supplied, a new instance is created. | `string` | `null` | no |
| <a name="input_existing_secrets_manager_kms_key_crn"></a> [existing\_secrets\_manager\_kms\_key\_crn](#input\_existing\_secrets\_manager\_kms\_key\_crn) | The CRN of a Key Protect or Hyper Protect Crypto Services key to use for Secrets Manager. If not specified, a key ring and key are created. | `string` | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key used to provision resources. | `string` | n/a | yes |
| <a name="input_ibmcloud_kms_api_key"></a> [ibmcloud\_kms\_api\_key](#input\_ibmcloud\_kms\_api\_key) | The IBM Cloud API key that can create a root key and key ring in the key management service (KMS) instance. If not specified, the 'ibmcloud\_api\_key' variable is used. Specify this key if the instance in `existing_kms_instance_crn` is in an account that's different from the Secrets Manager instance. Leave this input empty if the same account owns both instances. | `string` | `null` | no |
| <a name="input_kms_encryption_enabled"></a> [kms\_encryption\_enabled](#input\_kms\_encryption\_enabled) | Set to true to enable Secrets Manager Secrets Encryption using customer managed keys. When set to true, a value must be passed for either `existing_kms_instance_crn` or `existing_secrets_manager_kms_key_crn`. Cannot be set to true if passing a value for `existing_secrets_manager_crn`. | `bool` | `false` | no |
| <a name="input_kms_endpoint_type"></a> [kms\_endpoint\_type](#input\_kms\_endpoint\_type) | The endpoint for communicating with the Key Protect or Hyper Protect Crypto Services instance. Possible values: `public`, `private`. Applies only if `existing_secrets_manager_kms_key_crn` is not specified. | `string` | `"private"` | no |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | The name for the new root key. Applies only if `existing_secrets_manager_kms_key_crn` is not specified. If a prefix input variable is passed, it is added to the value in the `<prefix>-value` format. | `string` | `"secrets-manager-key"` | no |
| <a name="input_kms_key_ring_name"></a> [kms\_key\_ring\_name](#input\_kms\_key\_ring\_name) | The name for the new key ring to store the key. Applies only if `existing_secrets_manager_kms_key_crn` is not specified. If a prefix input variable is passed, it is added to the value in the `<prefix>-value` format. . | `string` | `"secrets-manager-key-ring"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to add to all resources created by this solution. To not use any prefix value, you can set this value to `null` or an empty string. | `string` | n/a | yes |
| <a name="input_provider_visibility"></a> [provider\_visibility](#input\_provider\_visibility) | Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints). | `string` | `"private"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to provision resources to. | `string` | `"us-south"` | no |
| <a name="input_secret_groups"></a> [secret\_groups](#input\_secret\_groups) | Secret Manager secret group and access group configurations. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager/tree/main/solutions/fully-configurable/provisioning_secrets_groups.md). | <pre>list(object({<br/>    secret_group_name        = string<br/>    secret_group_description = optional(string)<br/>    create_access_group      = optional(bool, true)<br/>    access_group_name        = optional(string)<br/>    access_group_roles       = optional(list(string), ["SecretsReader"])<br/>    access_group_tags        = optional(list(string))<br/>  }))</pre> | <pre>[<br/>  {<br/>    "access_group_name": "general-secrets-group-access-group",<br/>    "access_group_roles": [<br/>      "SecretsReader"<br/>    ],<br/>    "create_access_group": true,<br/>    "secret_group_description": "A general purpose secrets group with an associated access group which has a secrets reader role",<br/>    "secret_group_name": "General"<br/>  }<br/>]</pre> | no |
| <a name="input_secrets_manager_cbr_rules"></a> [secrets\_manager\_cbr\_rules](#input\_secrets\_manager\_cbr\_rules) | (Optional, list) List of CBR rules to create. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager/blob/main/solutions/fully-configurable/DA-cbr_rules.md) | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>    operations = optional(list(object({<br/>      api_types = list(object({<br/>        api_type_id = string<br/>      }))<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_secrets_manager_endpoint_type"></a> [secrets\_manager\_endpoint\_type](#input\_secrets\_manager\_endpoint\_type) | The type of endpoint (public or private) to connect to the Secrets Manager API. The Terraform provider uses this endpoint type to interact with the Secrets Manager API and configure Event Notifications. | `string` | `"private"` | no |
| <a name="input_secrets_manager_instance_name"></a> [secrets\_manager\_instance\_name](#input\_secrets\_manager\_instance\_name) | The name to give the Secrets Manager instance provisioned by this solution. If a prefix input variable is specified, it is added to the value in the `<prefix>-value` format. Applies only if `existing_secrets_manager_crn` is not provided. | `string` | `"secrets-manager"` | no |
| <a name="input_secrets_manager_resource_tags"></a> [secrets\_manager\_resource\_tags](#input\_secrets\_manager\_resource\_tags) | The list of resource tags you want to associate with your Secrets Manager instance. Applies only if `existing_secrets_manager_crn` is not provided. | `list(any)` | `[]` | no |
| <a name="input_service_plan"></a> [service\_plan](#input\_service\_plan) | The pricing plan to use when provisioning a Secrets Manager instance. Possible values: `standard`, `trial`. | `string` | `"standard"` | no |
| <a name="input_skip_event_notifications_iam_authorization_policy"></a> [skip\_event\_notifications\_iam\_authorization\_policy](#input\_skip\_event\_notifications\_iam\_authorization\_policy) | If set to true, this skips the creation of a service to service authorization from Secrets Manager to Event Notifications. If false, the service to service authorization is created. | `bool` | `false` | no |
| <a name="input_skip_sm_ce_iam_authorization_policy"></a> [skip\_sm\_ce\_iam\_authorization\_policy](#input\_skip\_sm\_ce\_iam\_authorization\_policy) | Whether to skip the creation of the IAM authorization policies required to enable the IAM credentials engine. If set to false, policies will be created that grants the Secrets Manager instance 'Operator' access to the IAM identity service, and 'Groups Service Member Manage' access to the IAM groups service. | `bool` | `false` | no |
| <a name="input_skip_sm_kms_iam_authorization_policy"></a> [skip\_sm\_kms\_iam\_authorization\_policy](#input\_skip\_sm\_kms\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits all Secrets Manager instances in the resource group to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the `existing_kms_instance_crn` variable. If a value is specified for `ibmcloud_kms_api_key`, the policy is created in the KMS account. | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource group ID |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name |
| <a name="output_secrets_manager_crn"></a> [secrets\_manager\_crn](#output\_secrets\_manager\_crn) | CRN of the Secrets Manager instance |
| <a name="output_secrets_manager_guid"></a> [secrets\_manager\_guid](#output\_secrets\_manager\_guid) | GUID of Secrets Manager instance |
| <a name="output_secrets_manager_id"></a> [secrets\_manager\_id](#output\_secrets\_manager\_id) | ID of Secrets Manager instance. |
| <a name="output_secrets_manager_name"></a> [secrets\_manager\_name](#output\_secrets\_manager\_name) | Name of the Secrets Manager instance |
| <a name="output_secrets_manager_region"></a> [secrets\_manager\_region](#output\_secrets\_manager\_region) | Region of the Secrets Manager instance |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
