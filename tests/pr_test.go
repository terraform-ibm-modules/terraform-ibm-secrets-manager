// Tests in this file are run in the PR pipeline
package test

import (
	"fmt"
	"log"
	"os"
	"strings"
	"testing"

	"github.com/IBM/go-sdk-core/v5/core"
	"github.com/IBM/secrets-manager-go-sdk/v2/secretsmanagerv2"
	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

const completeExampleTerraformDir = "examples/complete"
const fscloudExampleTerraformDir = "examples/fscloud"
const solutionsTerraformDir = "solutions/standard"

const bestRegionYAMLPath = "../common-dev-assets/common-go-assets/cloudinfo-region-secmgr-prefs.yaml"
const resourceGroup = "geretain-test-scc-module"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func setupOptions(t *testing.T, prefix string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: completeExampleTerraformDir,
		Prefix:       prefix,
		/*
		 Comment out the 'ResourceGroup' input to force this tests to create a unique resource group. This is because
		 there is a restriction with the Event Notification service, which allows only one Lite plan instance per resource group.
		*/
		// ResourceGroup:      resourceGroup,
		BestRegionYAMLPath: bestRegionYAMLPath,
	})

	return options
}

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "secrets-mgr")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "secrets-mgr-upg")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestFSCloudInSchematics(t *testing.T) {
	t.Parallel()

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "sm-fscloud",
		TarIncludePatterns: []string{
			"*.tf",
			fscloudExampleTerraformDir + "/*.tf",
			"modules/fscloud/*.tf",
		},
		BestRegionYAMLPath: bestRegionYAMLPath,
		// ResourceGroup:          resourceGroup,
		TemplateFolder:         fscloudExampleTerraformDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_kms_instance_guid", Value: permanentResources["hpcs_south"], DataType: "string"},
		{Name: "kms_key_crn", Value: permanentResources["hpcs_south_root_key_crn"], DataType: "string"},
		{Name: "sm_service_plan", Value: "trial", DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunDASolutionSchematics(t *testing.T) {
	t.Parallel()

	acme_letsencrypt_private_key := GetSecretsManagerKey( // pragma: allowlist secret
		permanentResources["acme_letsencrypt_private_key_sm_id"].(string),
		permanentResources["acme_letsencrypt_private_key_sm_region"].(string),
		permanentResources["acme_letsencrypt_private_key_secret_id"].(string),
	)

	// Set up a schematics test
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:                t,
		TarIncludePatterns:     []string{"*.tf", fmt.Sprintf("%s/*.tf", solutionsTerraformDir)},
		TemplateFolder:         solutionsTerraformDir,
		ResourceGroup:          resourceGroup,
		Prefix:                 "sm-da",
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
		BestRegionYAMLPath:     bestRegionYAMLPath,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "resource_group_name", Value: options.Prefix, DataType: "string"},
		{Name: "service_plan", Value: "trial", DataType: "string"},
		{Name: "allowed_network", Value: "private-only", DataType: "string"},
		{Name: "existing_kms_instance_crn", Value: permanentResources["hpcs_south_crn"], DataType: "string"},
		{Name: "iam_engine_enabled", Value: true, DataType: "bool"},
		{Name: "public_engine_enabled", Value: true, DataType: "bool"},
		{Name: "private_engine_enabled", Value: true, DataType: "bool"},
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

// A test to pass existing resources to the SM DA
func TestRunExistingResourcesInstances(t *testing.T) {
	t.Parallel()

	// Init test options for DA to get the region, which is used for provisioning the existing resources
	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: solutionsTerraformDir,
		// Do not hard fail the test if the implicit destroy steps fail to allow a full destroy of resource to occur
		ImplicitRequired:   false,
		BestRegionYAMLPath: bestRegionYAMLPath,
	})

	// ------------------------------------------------------------------------------------
	// Provision Event Notification, KMS key and resource group first
	// ------------------------------------------------------------------------------------

	prefix := fmt.Sprintf("scc-exist-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := "./existing-resources"
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))
	tags := common.GetTagsFromTravis()
	region := "us-south"

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")
	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		Vars: map[string]interface{}{
			"prefix":        prefix,
			"region":        options.Region,
			"resource_tags": tags,
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed")
	} else {
		// add existing resources to previously created options
		options.TerraformVars = map[string]interface{}{
			"ibmcloud_api_key":                         os.Getenv("TF_VAR_ibmcloud_api_key"),
			"region":                                   region,
			"resource_group_name":                      terraform.Output(t, existingTerraformOptions, "resource_group_name"),
			"use_existing_resource_group":              true,
			"existing_event_notification_instance_crn": terraform.Output(t, existingTerraformOptions, "event_notification_instance_crn"),
			"existing_secrets_manager_kms_key_crn":     terraform.Output(t, existingTerraformOptions, "secrets_manager_kms_key_crn"),
			"existing_kms_instance_crn":                terraform.Output(t, existingTerraformOptions, "secrets_manager_kms_instance_crn"),
			"service_plan":                             "trial",
			"existing_secrets_manager_crn":             terraform.Output(t, existingTerraformOptions, "secrets_manager_instance_crn"),
			"iam_engine_enabled":                       true,
			"public_engine_enabled":                    true,
			"private_engine_enabled":                   true,
		}

		output, err := options.RunTestConsistency()
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")

	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (existing resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (existing resources)")
	}
}
