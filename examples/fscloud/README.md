# Financial Services Cloud profile example with KYOK encryption

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
