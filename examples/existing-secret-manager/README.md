# existing-secret-manager example

This examples handles the use of existing Secrets Manager instance

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= v1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.62.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_event_notification"></a> [event\_notification](#module\_event\_notification) | terraform-ibm-modules/event-notifications/ibm | 1.6.5 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.1.6 |
| <a name="module_secrets_manager"></a> [secrets\_manager](#module\_secrets\_manager) | ../.. | n/a |
| <a name="module_secrets_manager_service_credentails"></a> [secrets\_manager\_service\_credentails](#module\_secrets\_manager\_service\_credentails) | ../../modules/secrets | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_en_region"></a> [en\_region](#input\_en\_region) | Region where event notification will be created | `string` | `"au-syd"` | no |
| <a name="input_existing_sm_instance_crn"></a> [existing\_sm\_instance\_crn](#input\_existing\_sm\_instance\_crn) | An existing Secrets Manager instance CRN. If not provided an new instance will be provisioned. | `string` | `"crn:v1:bluemix:public:secrets-manager:us-south:a/abac0df06b644a9cabc6e44f55b3880e:79c6d411-c18f-4670-b009-b0044a238667::"` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key this account authenticates to | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for sm instance | `string` | `"sm-com"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | An existing resource group name to use for this example, if unset a new resource group will be created | `string` | `null` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to be added to created resources | `list(string)` | `[]` | no |
| <a name="input_service_credentials_secrets"></a> [service\_credentials\_secrets](#input\_service\_credentials\_secrets) | Service credentials secret configuration for COS | <pre>list(object({<br>    secret_group_name        = string<br>    secret_group_description = optional(string)<br>    existing_secret_group    = optional(bool, false)<br>    service_credentials = list(object({<br>      secret_name                             = string<br>      service_credentials_source_service_role = string<br>      secret_labels                           = optional(list(string))<br>      secret_auto_rotation                    = optional(bool)<br>      secret_auto_rotation_unit               = optional(string)<br>      secret_auto_rotation_interval           = optional(number)<br>      service_credentials_ttl                 = optional(string)<br>      service_credential_secret_description   = optional(string)<br>    }))<br>  }))</pre> | <pre>[<br>  {<br>    "existing_secret_group": true,<br>    "secret_group_name": "soaib-secret-group",<br>    "service_credentials": [<br>      {<br>        "secret_name": "soaib-cred-1",<br>        "service_credentials_source_service_role": "Editor"<br>      },<br>      {<br>        "secret_name": "soaib-cred-2",<br>        "service_credentials_source_service_role": "Editor"<br>      }<br>    ]<br>  }<br>]</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_secrets_manager_guid"></a> [secrets\_manager\_guid](#output\_secrets\_manager\_guid) | GUID of Secrets Manager instance. |
| <a name="output_secrets_manager_region"></a> [secrets\_manager\_region](#output\_secrets\_manager\_region) | Region of the Secrets Manager instance |
| <a name="output_sm_cred_input"></a> [sm\_cred\_input](#output\_sm\_cred\_input) | input |
| <a name="output_sm_cred_ouput"></a> [sm\_cred\_ouput](#output\_sm\_cred\_ouput) | output |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
