// Tests in this file are run in the PR pipeline
package test

import (
	"fmt"
	"log"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

const completeExampleTerraformDir = "examples/complete"
const fscloudExampleTerraformDir = "examples/fscloud"
const solutionsTerraformDir = "solutions/standard"

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
		BestRegionYAMLPath: "../common-dev-assets/common-go-assets/cloudinfo-region-secmgr-prefs.yaml",
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

/* func setupPrivateOptions(t *testing.T, prefix string) *testhelper.TestOptions {
options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
	Testing:      t,
	TerraformDir: fscloudExampleTerraformDir,
	Prefix:       prefix,
	Region:       "us-south", // Locking into us-south since that is where the HPCS permanent instance is */
/*
 Comment out the 'ResourceGroup' input to force this tests to create a unique resource group to ensure tests do
 not clash. This is due to the fact that an auth policy may already exist in this resource group since we are
 re-using a permanent HPCS instance. By using a new resource group, the auth policy will not already exist
 since this module scopes auth policies by resource group.
*/
//ResourceGroup: resourceGroup,
/*		TerraformVars: map[string]interface{}{
			// "kms_encryption_enabled":     true,
			"existing_kms_instance_guid": permanentResources["hpcs_south"],
			"kms_key_crn":                permanentResources["hpcs_south_root_key_crn"],
		},
	})

	return options
} */

/* func TestRunFSCloudExample(t *testing.T) {
	t.Parallel()

	options := setupPrivateOptions(t, "secrets-mgr-priv")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
} */

func TestFSCloudInSchematics(t *testing.T) {
	t.Parallel()

	const region = "us-south"

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "sm-fscloud",
		TarIncludePatterns: []string{
			"*.tf",
			fscloudExampleTerraformDir + "/*.tf",
			"modules/fscloud/*.tf",
		},
		// ResourceGroup:          resourceGroup,
		TemplateFolder:         fscloudExampleTerraformDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
		Region:                 region,
	})

	// Workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5154
	options.AddWorkspaceEnvVar("IBMCLOUD_KP_API_ENDPOINT", "https://private."+region+".kms.cloud.ibm.com", false, false)

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "resource_group_name", Value: options.Prefix, DataType: "string"},
		// {Name: "service_endpoints", Value: "private", DataType: "string"},
		// {Name: "resource_tags", Value: options.Tags, DataType: "list(string)"},
		// {Name: "access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
		// {Name: "sm_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "existing_kms_instance_guid", Value: permanentResources["hpcs_south"], DataType: "string"},
		{Name: "kms_key_crn", Value: permanentResources["hpcs_south_root_key_crn"], DataType: "string"},
		// {Name: "keys", Value: []map[string]interface{}{{"key_ring_name": "my-key-ring", "keys": []map[string]interface{}{{"key_name": "some-key-name-1"}, {"key_name": "some-key-name-2"}}}}, DataType: "list(object)"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunDASolutionSchematics(t *testing.T) {
	t.Parallel()

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
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "resource_group_name", Value: options.Prefix, DataType: "string"},
		{Name: "service_plan", Value: "trial", DataType: "string"},
		{Name: "service_endpoints", Value: "private", DataType: "string"},
		{Name: "existing_kms_guid", Value: permanentResources["hpcs_south"], DataType: "string"},
		{Name: "kms_region", Value: "us-south", DataType: "string"}, // KMS instance is in us-south
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}
