// Tests in this file are run in the PR pipeline
package test

import (
	"fmt"
	"log"
	"math/rand"
	"os"
	"strings"
	"testing"

	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testaddons"

	"github.com/IBM/go-sdk-core/v5/core"
	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

/*
Global variables
*/
const fscloudExampleTerraformDir = "examples/fscloud"
const fullyConfigurableTerraformDir = "solutions/fully-configurable"
const securityEnforcedTerraformDir = "solutions/security-enforced"
const resourceGroup = "geretain-test-secrets-manager"
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"
const terraformVersion = "terraform_v1.10" // This should match the version in the ibm_catalog.json

var permanentResources map[string]interface{}
var validRegions = []string{
	"eu-de", // all tests using KMS should run in the same region https://github.ibm.com/GoldenEye/issues/issues/12725
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

func TestRunSecurityEnforced(t *testing.T) {
	t.Parallel()

	// ------------------------------------------------------------------------------------
	// Provision new RG, Event Notifications and Key Protect instance + root key
	// ------------------------------------------------------------------------------------
	prefix := fmt.Sprintf("sm-se-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := ".."
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")
	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir + "/tests/existing-resources",
		Vars: map[string]interface{}{
			"prefix": prefix,
			"region": validRegions[rand.Intn(len(validRegions))],
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of new resources failed")
	} else {

		// Set up a schematics test
		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing: t,
			TarIncludePatterns: []string{
				"*.tf",
				fmt.Sprintf("%s/*.tf", securityEnforcedTerraformDir),
				fmt.Sprintf("%s/*.tf", fullyConfigurableTerraformDir),
				fmt.Sprintf("%s/*.tf", fscloudExampleTerraformDir),
				fmt.Sprintf("%s/*.tf", "modules/secrets"),
			},
			TemplateFolder:         securityEnforcedTerraformDir,
			ResourceGroup:          resourceGroup,
			Prefix:                 "sm-se",
			Tags:                   []string{"test-schematic"},
			DeleteWorkspaceOnFail:  false,
			WaitJobCompleteMinutes: 60,
			TerraformVersion:       terraformVersion,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "prefix", Value: options.Prefix, DataType: "string"},
			{Name: "region", Value: validRegions[rand.Intn(len(validRegions))], DataType: "string"},
			{Name: "existing_resource_group_name", Value: terraform.Output(t, existingTerraformOptions, "resource_group_name"), DataType: "string"},
			{Name: "service_plan", Value: "trial", DataType: "string"},
			{Name: "existing_kms_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "secrets_manager_kms_instance_crn"), DataType: "string"},
			{Name: "existing_event_notifications_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "event_notifications_instance_crn"), DataType: "string"},
		}
		err := options.RunSchematicTest()
		assert.NoError(t, err, "Schematic Test had unexpected error")
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

func TestRunSecurityEnforcedUpgrade(t *testing.T) {
	t.Parallel()

	// ------------------------------------------------------------------------------------
	// Provision new RG
	// ------------------------------------------------------------------------------------
	prefix := fmt.Sprintf("sm-se-ug-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := ".."
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")
	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir + "/tests/existing-resources",
		Vars: map[string]interface{}{
			"prefix": prefix,
			"region": validRegions[rand.Intn(len(validRegions))],
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of new resources failed")
	} else {
		// Set up a schematics test
		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing: t,
			TarIncludePatterns: []string{
				"*.tf",
				fmt.Sprintf("%s/*.tf", securityEnforcedTerraformDir),
				fmt.Sprintf("%s/*.tf", fullyConfigurableTerraformDir),
				fmt.Sprintf("%s/*.tf", "modules/secrets"),
			},
			TemplateFolder:             securityEnforcedTerraformDir,
			ResourceGroup:              resourceGroup,
			Prefix:                     "sm-se-ug",
			Tags:                       []string{"test-schematic"},
			DeleteWorkspaceOnFail:      false,
			WaitJobCompleteMinutes:     60,
			CheckApplyResultForUpgrade: true,
			TerraformVersion:           terraformVersion,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "prefix", Value: options.Prefix, DataType: "string"},
			{Name: "region", Value: validRegions[rand.Intn(len(validRegions))], DataType: "string"},
			{Name: "existing_resource_group_name", Value: terraform.Output(t, existingTerraformOptions, "resource_group_name"), DataType: "string"},
			{Name: "service_plan", Value: "trial", DataType: "string"},
			{Name: "existing_kms_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "secrets_manager_kms_instance_crn"), DataType: "string"},
			{Name: "existing_event_notifications_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "event_notifications_instance_crn"), DataType: "string"},
		}

		err := options.RunSchematicUpgradeTest()
		if !options.UpgradeTestSkipped {
			assert.Nil(t, err, "This should not have errored")
		}
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

func TestAddonsDefaultConfiguration(t *testing.T) {
	t.Parallel()

	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing:       t,
		Prefix:        "smdeft",
		ResourceGroup: resourceGroup,
		QuietMode:     true, // Suppress logs except on failure
	})

	options.AddonConfig = cloudinfo.NewAddonConfigTerraform(
		options.Prefix,
		"deploy-arch-ibm-secrets-manager",
		"fully-configurable",
		map[string]interface{}{
			"region":                  validRegions[rand.Intn(len(validRegions))],
			"service_plan":            "trial",
			"existing_resource_group": options.ResourceGroup,
		},
	)

	// Disable target / route creation to prevent hitting quota in account
	options.AddonConfig.Dependencies = []cloudinfo.AddonConfig{
		{
			OfferingName:   "deploy-arch-ibm-cloud-monitoring",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"enable_metrics_routing_to_cloud_monitoring": false,
			},
			Enabled: core.BoolPtr(true),
		},
		{
			OfferingName:   "deploy-arch-ibm-activity-tracker",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"enable_activity_tracker_event_routing_to_cos_bucket": false,
				"enable_activity_tracker_event_routing_to_cloud_logs": false,
			},
			Enabled: core.BoolPtr(true),
		},
	}

	err := options.RunAddonTest()
	require.NoError(t, err)
}

func TestAddonsExistingSecretsManager(t *testing.T) {
	t.Parallel()

	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing:       t,
		Prefix:        "extsm",
		ResourceGroup: resourceGroup,
		QuietMode:     true, // Suppress logs except on failure
	})

	options.AddonConfig = cloudinfo.NewAddonConfigTerraform(
		options.Prefix,
		"deploy-arch-ibm-secrets-manager",
		"fully-configurable",
		map[string]interface{}{
			"region":                               permanentResources["privateOnlySecMgrRegion"],
			"existing_secrets_manager_crn":         permanentResources["privateOnlySecMgrCRN"],
			"existing_resource_group":              options.ResourceGroup,
			"service_plan":                         "__NULL__", // Plan not needed if using existing instance
			"skip_secrets_manager_iam_auth_policy": true,       // Skip s2s auth policy for IAM engine - it already exists for the existing Secrets Manager instance
			"secret_groups":                        []string{}, // Don't create any secret groups in existing instance (The default 'General' group already exists)
		},
	)

	// Disable target / route creation to prevent hitting quota in account
	options.AddonConfig.Dependencies = []cloudinfo.AddonConfig{
		{
			OfferingName:   "deploy-arch-ibm-cloud-monitoring",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"enable_metrics_routing_to_cloud_monitoring": false,
			},
			Enabled: core.BoolPtr(true),
		},
		{
			OfferingName:   "deploy-arch-ibm-activity-tracker",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"enable_activity_tracker_event_routing_to_cos_bucket": false,
			},
			Enabled: core.BoolPtr(true),
		},
	}

	err := options.RunAddonTest()
	require.NoError(t, err)
}
