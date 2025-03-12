# Secrets Manager solution

This solution supports the following:
- Creating a new resource group, or taking in an existing one.
- Provisioning and configuring of a Secrets Manager instance.
- Optionally configure an IBM Secrets Manager IAM credentials engine to an IBM Secrets Manager instance.
- Configuring KMS encryption using a newly created key, or passing an existing key.

![secret-manager-deployable-architecture](../../reference-architecture/secrets_manager.svg)

**NB:** This solution is not intended to be called by one or more other modules since it contains a provider configurations, meaning it is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)
