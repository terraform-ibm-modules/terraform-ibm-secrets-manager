// Tests in this file are run in the PR pipeline
package test

import (
	"fmt"
	"log"
	"math/rand"
	"os"
	"testing"

	"github.com/IBM/go-sdk-core/v5/core"
	"github.com/IBM/secrets-manager-go-sdk/v2/secretsmanagerv2"
	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

const completeExampleTerraformDir = "examples/complete"
const fscloudExampleTerraformDir = "examples/fscloud"
const fullyConfigurableTerraformDir = "solutions/fully-configurable"
const securityEnforcedTerraformDir = "solutions/security-enforced"

const resourceGroup = "geretain-test-scc-module"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}

// Current supported Event Notification regions
var validRegions = []string{
	// "us-south", # do not run secrets manager tests in us regions
	// "eu-de",
	// "eu-gb",
	"au-syd", // all tests using KMS should avoid dallas and EU regions https://github.ibm.com/GoldenEye/issues/issues/12725
}

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func setupOptions(t *testing.T, prefix string, checkApplyResultForUpgrade bool) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:                    t,
		TerraformDir:               completeExampleTerraformDir,
		Prefix:                     prefix,
		Region:                     validRegions[rand.Intn(len(validRegions))],
		CheckApplyResultForUpgrade: checkApplyResultForUpgrade,
		/*
		 Comment out the 'ResourceGroup' input to force this tests to create a unique resource group. This is because
		 there is a restriction with the Event Notification service, which allows only one Lite plan instance per resource group.
		*/
		// ResourceGroup:      resourceGroup,
	})

	return options
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "secrets-mgr-upg", true)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestRunFullyConfigurableSchematics(t *testing.T) {
	t.Parallel()

	acme_letsencrypt_private_key := GetSecretsManagerKey( // pragma: allowlist secret
		permanentResources["acme_letsencrypt_private_key_sm_id"].(string),
		permanentResources["acme_letsencrypt_private_key_sm_region"].(string),
		permanentResources["acme_letsencrypt_private_key_secret_id"].(string),
	)

	// Set up a schematics test
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		TarIncludePatterns: []string{
			"*.tf",
			fmt.Sprintf("%s/*.tf", fullyConfigurableTerraformDir),
			fmt.Sprintf("%s/*.tf", fscloudExampleTerraformDir),
			fmt.Sprintf("%s/*.tf", "modules/secrets"),
			fmt.Sprintf("%s/*.tf", "modules/fscloud"),
		},
		TemplateFolder:         fullyConfigurableTerraformDir,
		ResourceGroup:          resourceGroup,
		Prefix:                 "sm-fc",
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: validRegions[rand.Intn(len(validRegions))], DataType: "string"},
		{Name: "existing_resource_group_name", Value: "geretain-test-secrets-manager", DataType: "string"},
		{Name: "service_plan", Value: "trial", DataType: "string"},
		{Name: "existing_kms_instance_crn", Value: permanentResources["hpcs_south_crn"], DataType: "string"},
		{Name: "is_hpcs_key", Value: true, DataType: "bool"},
		{Name: "kms_encryption_enabled", Value: true, DataType: "bool"},
		{Name: "cis_id", Value: permanentResources["cisInstanceId"], DataType: "string"},
		{Name: "ca_name", Value: permanentResources["certificateAuthorityName"], DataType: "string"},
		{Name: "dns_provider_name", Value: permanentResources["dnsProviderName"], DataType: "string"},
		{Name: "acme_letsencrypt_private_key", Value: *acme_letsencrypt_private_key, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}

func GetSecretsManagerKey(sm_id string, sm_region string, sm_key_id string) *string {
	secretsManagerService, err := secretsmanagerv2.NewSecretsManagerV2(&secretsmanagerv2.SecretsManagerV2Options{
		URL: fmt.Sprintf("https://%s.%s.secrets-manager.appdomain.cloud", sm_id, sm_region),
		Authenticator: &core.IamAuthenticator{
			ApiKey: os.Getenv("TF_VAR_ibmcloud_api_key"),
		},
	})
	if err != nil {
		panic(err)
	}

	getSecretOptions := secretsManagerService.NewGetSecretOptions(
		sm_key_id,
	)

	secret, _, err := secretsManagerService.GetSecret(getSecretOptions)
	if err != nil {
		panic(err)
	}
	return secret.(*secretsmanagerv2.ArbitrarySecret).Payload
}

func TestRunSecretsManagerFullyConfigurableUpgradeSchematic(t *testing.T) {
	t.Parallel()

	acme_letsencrypt_private_key := GetSecretsManagerKey( // pragma: allowlist secret
		permanentResources["acme_letsencrypt_private_key_sm_id"].(string),
		permanentResources["acme_letsencrypt_private_key_sm_region"].(string),
		permanentResources["acme_letsencrypt_private_key_secret_id"].(string),
	)

	// Set up a schematics test
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		TarIncludePatterns: []string{
			"*.tf",
			fmt.Sprintf("%s/*.tf", fullyConfigurableTerraformDir),
			fmt.Sprintf("%s/*.tf", "modules/secrets"),
			fmt.Sprintf("%s/*.tf", "modules/fscloud"),
		},
		TemplateFolder:         fullyConfigurableTerraformDir,
		ResourceGroup:          resourceGroup,
		Prefix:                 "sm-fc-ug",
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: validRegions[rand.Intn(len(validRegions))], DataType: "string"},
		{Name: "existing_resource_group_name", Value: "geretain-test-secrets-manager", DataType: "string"},
		{Name: "service_plan", Value: "trial", DataType: "string"},
		{Name: "existing_kms_instance_crn", Value: permanentResources["hpcs_south_crn"], DataType: "string"},
		{Name: "is_hpcs_key", Value: true, DataType: "bool"},
		{Name: "kms_encryption_enabled", Value: true, DataType: "bool"},
		{Name: "cis_id", Value: permanentResources["cisInstanceId"], DataType: "string"},
		{Name: "ca_name", Value: permanentResources["certificateAuthorityName"], DataType: "string"},
		{Name: "dns_provider_name", Value: permanentResources["dnsProviderName"], DataType: "string"},
		{Name: "acme_letsencrypt_private_key", Value: *acme_letsencrypt_private_key, DataType: "string"},
	}

	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}

func TestRunSecurityEnforcedSchematics(t *testing.T) {

	acme_letsencrypt_private_key := GetSecretsManagerKey( // pragma: allowlist secret
		permanentResources["acme_letsencrypt_private_key_sm_id"].(string),
		permanentResources["acme_letsencrypt_private_key_sm_region"].(string),
		permanentResources["acme_letsencrypt_private_key_secret_id"].(string),
	)

	// Set up a schematics test
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		TarIncludePatterns: []string{
			"*.tf",
			fmt.Sprintf("%s/*.tf", securityEnforcedTerraformDir),
			fmt.Sprintf("%s/*.tf", fullyConfigurableTerraformDir),
			fmt.Sprintf("%s/*.tf", fscloudExampleTerraformDir),
			fmt.Sprintf("%s/*.tf", "modules/secrets"),
			fmt.Sprintf("%s/*.tf", "modules/fscloud"),
		},
		TemplateFolder:         securityEnforcedTerraformDir,
		ResourceGroup:          resourceGroup,
		Prefix:                 "sm-se",
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: validRegions[rand.Intn(len(validRegions))], DataType: "string"},
		{Name: "existing_resource_group_name", Value: "geretain-test-secrets-manager", DataType: "string"},
		{Name: "service_plan", Value: "trial", DataType: "string"},
		{Name: "existing_kms_instance_crn", Value: permanentResources["hpcs_south_crn"], DataType: "string"},
		{Name: "is_hpcs_key", Value: true, DataType: "bool"},
		{Name: "cis_id", Value: permanentResources["cisInstanceId"], DataType: "string"},
		{Name: "ca_name", Value: permanentResources["certificateAuthorityName"], DataType: "string"},
		{Name: "dns_provider_name", Value: permanentResources["dnsProviderName"], DataType: "string"},
		{Name: "acme_letsencrypt_private_key", Value: *acme_letsencrypt_private_key, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}

func TestRunSecretsManagerSecurityEnforcedUpgradeSchematic(t *testing.T) {

	acme_letsencrypt_private_key := GetSecretsManagerKey( // pragma: allowlist secret
		permanentResources["acme_letsencrypt_private_key_sm_id"].(string),
		permanentResources["acme_letsencrypt_private_key_sm_region"].(string),
		permanentResources["acme_letsencrypt_private_key_secret_id"].(string),
	)

	// Set up a schematics test
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		TarIncludePatterns: []string{
			"*.tf",
			fmt.Sprintf("%s/*.tf", securityEnforcedTerraformDir),
			fmt.Sprintf("%s/*.tf", fullyConfigurableTerraformDir),
			fmt.Sprintf("%s/*.tf", "modules/secrets"),
			fmt.Sprintf("%s/*.tf", "modules/fscloud"),
		},
		TemplateFolder:         securityEnforcedTerraformDir,
		ResourceGroup:          resourceGroup,
		Prefix:                 "sm-se-ug",
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: validRegions[rand.Intn(len(validRegions))], DataType: "string"},
		{Name: "existing_resource_group_name", Value: "geretain-test-secrets-manager", DataType: "string"},
		{Name: "service_plan", Value: "trial", DataType: "string"},
		{Name: "existing_kms_instance_crn", Value: permanentResources["hpcs_south_crn"], DataType: "string"},
		{Name: "is_hpcs_key", Value: true, DataType: "bool"},
		{Name: "cis_id", Value: permanentResources["cisInstanceId"], DataType: "string"},
		{Name: "ca_name", Value: permanentResources["certificateAuthorityName"], DataType: "string"},
		{Name: "dns_provider_name", Value: permanentResources["dnsProviderName"], DataType: "string"},
		{Name: "acme_letsencrypt_private_key", Value: *acme_letsencrypt_private_key, DataType: "string"},
	}

	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}
