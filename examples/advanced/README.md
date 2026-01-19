# Advanced example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=secrets-manager-advanced-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager/tree/main/examples/advanced"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


An example that configures:

- A new resource group if one is not passed in.
- A new Key Protect instance and root key
- A new Event Notifications instance
- An s2s auth policy to allow Secrets Manager to manage Event Notifications service credentials
- A new Secretes Manager instance
- A new secret group with a new Event Notifications service credential secret and an arbitrary secret
- A new arbitrary secret in the default secret group
- A sample code engine project that builds a code engine job and outputs User IBM Cloud IAM API Keys
- A custom credential engine using the code engine project
- A custom credential secret

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
