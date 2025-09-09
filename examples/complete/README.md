# Complete example with BYOK encryption

This examples handles the provisioning of a new Secrets Manager instance.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= v1.9.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.2.1 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.79.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.12.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_code_engine_build"></a> [code\_engine\_build](#module\_code\_engine\_build) | terraform-ibm-modules/code-engine/ibm//modules/build | 4.5.8 |
| <a name="module_code_engine_job"></a> [code\_engine\_job](#module\_code\_engine\_job) | terraform-ibm-modules/code-engine/ibm//modules/job | 4.5.8 |
| <a name="module_code_engine_project"></a> [code\_engine\_project](#module\_code\_engine\_project) | terraform-ibm-modules/code-engine/ibm//modules/project | 4.5.8 |
| <a name="module_code_engine_secret"></a> [code\_engine\_secret](#module\_code\_engine\_secret) | terraform-ibm-modules/code-engine/ibm//modules/secret | 4.5.8 |
| <a name="module_custom_credential_engine"></a> [custom\_credential\_engine](#module\_custom\_credential\_engine) | terraform-ibm-modules/secrets-manager-custom-credentials-engine/ibm | 1.0.0 |
| <a name="module_event_notification"></a> [event\_notification](#module\_event\_notification) | terraform-ibm-modules/event-notifications/ibm | 2.6.24 |
| <a name="module_key_protect"></a> [key\_protect](#module\_key\_protect) | terraform-ibm-modules/kms-all-inclusive/ibm | 5.1.24 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.3.0 |
| <a name="module_secret_manager_custom_credential"></a> [secret\_manager\_custom\_credential](#module\_secret\_manager\_custom\_credential) | terraform-ibm-modules/secrets-manager-secret/ibm | 1.9.0 |
| <a name="module_secrets_manager"></a> [secrets\_manager](#module\_secrets\_manager) | ../.. | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_cr_namespace.rg_namespace](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cr_namespace) | resource |
| [ibm_iam_api_key.api_key](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_api_key) | resource |
| [ibm_iam_authorization_policy.en_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [time_sleep.wait_for_en_policy](https://registry.terraform.io/providers/hashicorp/time/0.12.1/docs/resources/sleep) | resource |
| [http_http.job_config](https://registry.terraform.io/providers/hashicorp/http/3.2.1/docs/data-sources/http) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_en_region"></a> [en\_region](#input\_en\_region) | Region where event notification will be created | `string` | `"au-syd"` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key this account authenticates to | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for sm instance | `string` | `"sm-com"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where resources will be created | `string` | `"eu-de"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | An existing resource group name to use for this example, if unset a new resource group will be created | `string` | `null` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to be added to created resources | `list(string)` | `[]` | no |
| <a name="input_sm_service_plan"></a> [sm\_service\_plan](#input\_sm\_service\_plan) | The Secrets Manager service plan to provision | `string` | `"trial"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_secrets_manager_guid"></a> [secrets\_manager\_guid](#output\_secrets\_manager\_guid) | GUID of Secrets Manager instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
