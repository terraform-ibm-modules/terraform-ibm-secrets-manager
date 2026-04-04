# Financial Services Cloud profile example with KYOK encryption

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=secrets-manager-fscloud-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager/tree/main/examples/fscloud">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

An end-to-end example that uses the [Profile for IBM Cloud Framework for Financial Services](https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager/tree/main/modules/fscloud) to deploy a private only Secrets-Manager instance with KYOK encryption

The example creates the following infrastructure:

- A resource group, if one is not passed in.
- A CBR zone for Schematics
- An Event Notifications instance.
- A Secrets Manager instance.
- A context-based restriction (CBR) rule to only allow Secrets Manager to be accessible from the Schematics service.

:exclamation: **Important:** In this example, only the IBM Secrets Manager instance complies with the IBM Cloud Framework for Financial Services. Other parts of the infrastructure do not necessarily comply.

## Before you begin

- You need a Hyper Protect Crypto Services instance and root key available.
