# Provisioning Secrets Groups

Secrets groups and access groups associated to them can be provisioned using the `secret_groups` variable.

An example value:
```
[
  {
    secret_group_name        = "Example Secret Group"
    secret_group_description = "an example secret group"
    create_access_group      = true
    access_group_name        = "example-secret-group-access-group"
    access_group_roles       = ["SecretsReader"]
    access_group_tags        = []
  },
  {
    secret_group_name        = "Existing Secret Group"
    secret_group_description = "an existing secret group"
    existing_secret_group    = true
  }
]
```

It is a list of objects, so you can specify as many secrets groups as you wish.

## Options:

- `secret_group_name` (required) - the name of secrets group
- `secret_group_description` (optional, default = `null`) - the description of secrets group
- `create_access_group` (optional, default = `false`) - Whether to create an access group associated to this secrets group
- `access_group_name` (optional, default = `null`) - Name of the access group to create. If you are creating an access group and a name is not passed, the name will become `<secret_group_name>-access-group`
- `access_group_roles` (optional, default = `null`) - The list of roles to give to the created access group. If `create_access_group` is true, there must be a value here. Valid values: ["Reader", "Writer", "Manager", "SecretsReader", "Viewer", "Operator", "Editor", "Administrator", "Service Configuration Reader", "Key Manager"]
- `access_group_tags` (optional, default = `[]`) - Tags that should be applied to the access group.
