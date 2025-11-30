package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {

	var validRegions = []string{
		"eu-de",
		"eu-gb",
		"au-syd",
	}

	var region = validRegions[common.CryptoIntn(len(validRegions))]

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: dir,
		Prefix:       prefix,
		Region:       region,
		/*
		 Comment out the 'ResourceGroup' input to force this tests to create a unique resource group. This is because
		 there is a restriction with the Event Notification service, which allows only one Lite plan instance per resource group.
		*/
		// ResourceGroup:      resourceGroup,
	})

	return options
}

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "sm-adv", "examples/basic")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunAdvancedExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "sm-adv", "examples/advanced")

	// need to ignore because of a provider issue: https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4719
	options.IgnoreUpdates = testhelper.Exemptions{
		List: []string{
			"module.code_engine_job.ibm_code_engine_job.ce_job",
		},
	}
	// all tests using KMS should run in the same region https://github.ibm.com/GoldenEye/issues/issues/12725
	options.Region = "eu-de"

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
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
			"modules/secrets/*.tf",
		},
		/*
		 Comment out the 'ResourceGroup' input to force this tests to create a unique resource group. This is because
		 there is a restriction with the Event Notification service, which allows only one Lite plan instance per resource group.
		*/
		// ResourceGroup:          resourceGroup,
		TemplateFolder:         fscloudExampleTerraformDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
		TerraformVersion:       terraformVersion,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: validRegions[common.CryptoIntn(len(validRegions))], DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "kms_key_crn", Value: permanentResources["hpcs_south_root_key_crn"], DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}
