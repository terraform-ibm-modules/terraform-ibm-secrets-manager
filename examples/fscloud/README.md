# Financial Services Cloud profile example with KYOK encryption

An end-to-end example that uses the [Profile for IBM Cloud Framework for Financial Services](https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager/tree/main/modules/fscloud) to deploy a private only Secrets-Manager instance with KYOK encryption

This examples handles the provisioning of Secrets-Manager instance, the IAM engine configuration in the recently created instance and a context-based restriction (CBR) rule to only allow Secret Manager to be accessible from within the VPC..

Only private service endpoints are enabled, public are disabled. Secrets Manager instances that are private only do not offer a UI management experience.
The example uses the IBM Cloud Terraform provider to create the following infrastructure:

- A resource group, if one is not passed in.
- A sample virtual private cloud (VPC).
- A sample event notification service.
- A secrets manager instance.
- A context-based restriction (CBR) rule to only allow Secrets Manager to be accessible from within the VPC.

:exclamation: **Important:** In this example, only the IBM Secrets Manager instance complies with the IBM Cloud Framework for Financial Services. Other parts of the infrastructure do not necessarily comply.

## Before you begin

- You need a Hyper Protect Crypto Services instance and root key available.
