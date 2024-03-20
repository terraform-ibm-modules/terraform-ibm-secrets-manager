# Profile for IBM Cloud Framework for Financial Services

This code is a version of the [parent root module](../../) that includes a default configuration that complies with the relevant controls from the [IBM Cloud Framework for Financial Services](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-about). See the [Example for IBM Cloud Framework for Financial Services](/examples/fscloud/) for logic that uses this module.

The default values in this profile were scanned by [IBM Code Risk Analyzer (CRA)](https://cloud.ibm.com/docs/code-risk-analyzer-cli-plugin?topic=code-risk-analyzer-cli-plugin-cra-cli-plugin#terraform-command) for compliance with the IBM Cloud Framework for Financial Services profile that is specified by the IBM Security and Compliance Center.

The IBM Cloud Framework for Financial Services mandates the application of an inbound network-based allowlist in front of the IBM Cloud Secrets Manager instance. You can comply with this requirement by using the `cbr_rules` variable in the module, which can be used to create a narrow context-based restriction rule that is scoped to the Secrets Manager instance.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <1.6.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.61.0, <2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_zone"></a> [cbr\_zone](#module\_cbr\_zone) | terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module | 1.18.0 |
| <a name="module_secrets_manager"></a> [secrets\_manager](#module\_secrets\_manager) | ../.. | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cbr_zone_name"></a> [cbr\_zone\_name](#input\_cbr\_zone\_name) | The name given to the CBR zone | `string` | n/a | yes |
| <a name="input_existing_en_instance_crn"></a> [existing\_en\_instance\_crn](#input\_existing\_en\_instance\_crn) | The CRN of the Event Notifications service to enable lifecycle notifications for your Secrets Manager instance. | `string` | `null` | no |
| <a name="input_existing_kms_instance_guid"></a> [existing\_kms\_instance\_guid](#input\_existing\_kms\_instance\_guid) | The GUID of the Hyper Protect Crypto Services instance in which the key specified in `kms_key_crn` is coming from. | `string` | n/a | yes |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | The root key CRN of Hyper Protect Crypto Services (HPCS) that you want to use for encryption. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to provision the Secrets Manager instance to. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the resource group to provision the Secrets Manager instance to. | `string` | n/a | yes |
| <a name="input_secrets_manager_name"></a> [secrets\_manager\_name](#input\_secrets\_manager\_name) | The name to give the Secrets Manager instance. | `string` | n/a | yes |
| <a name="input_sm_tags"></a> [sm\_tags](#input\_sm\_tags) | The list of resource tags that you want to associate with your Secrets Manager instance. | `list(string)` | `[]` | no |
| <a name="input_vpc_crn"></a> [vpc\_crn](#input\_vpc\_crn) | CRN of existing VPN | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_secrets_manager_guid"></a> [secrets\_manager\_guid](#output\_secrets\_manager\_guid) | GUID of Secrets-Manager instance in which IAM engine was configured |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
