# Advanced example

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
