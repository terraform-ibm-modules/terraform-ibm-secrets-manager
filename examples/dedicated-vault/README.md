# Dedicated Vault example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=secrets-manager-dedicated-vault-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager/tree/main/examples/dedicated-vault">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

An example that provisions a Vault Dedicated plan instance of Secrets Manager and configures it with the HashiCorp Vault provider.

The `dedicated` plan is a Vault Enterprise cluster that does not expose the Secrets Manager API. The module only creates the instance, the IBM provider generates a Vault admin token, and the HashiCorp Vault provider configures the cluster. The `secrets` input of the module is not supported with this plan.

The `dedicated` plan is only available in the `us-south`, `eu-de` and `eu-fr2` regions, and is billed per instance.

The following resources are provisioned by this example:

- A new resource group, if an existing one is not passed in.
- A `dedicated` plan instance of Secrets Manager with public and private endpoints.
- A Vault admin token for the instance (`ibm_sm_admin_token`). The token is valid for 1 hour. When a `terraform plan` or `apply` runs 55 minutes or more after the token was created, a new token is generated to replace it.
- A KV v2 secrets engine mounted at `secret` in the `admin` namespace, with an example secret.
