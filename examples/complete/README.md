# Complete example with BYOK encryption

This examples handles the provisioning of a new Secrets Manager instance.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= v1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.65.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_event_notification"></a> [event\_notification](#module\_event\_notification) | terraform-ibm-modules/event-notifications/ibm | 1.10.17 |
| <a name="module_key_protect"></a> [key\_protect](#module\_key\_protect) | terraform-ibm-modules/kms-all-inclusive/ibm | 4.16.4 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.1.6 |
| <a name="module_secrets_manager"></a> [secrets\_manager](#module\_secrets\_manager) | ../.. | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_en_region"></a> [en\_region](#input\_en\_region) | Region where event notification will be created | `string` | `"au-syd"` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key this account authenticates to | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for sm instance | `string` | `"sm-com"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where resources will be created | `string` | `"us-east"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | An existing resource group name to use for this example, if unset a new resource group will be created | `string` | `null` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to be added to created resources | `list(string)` | `[]` | no |
| <a name="input_sm_service_plan"></a> [sm\_service\_plan](#input\_sm\_service\_plan) | The Secrets Manager service plan to provision | `string` | `"trial"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_secrets_manager_guid"></a> [secrets\_manager\_guid](#output\_secrets\_manager\_guid) | GUID of Secrets Manager instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
