package main

import (
	"fmt"
	"os"

	"github.com/cloudfoundry/infrastructure-ci/scripts/deploy-aws-manifests/awsdeployer"
	"github.com/cloudfoundry/infrastructure-ci/scripts/deploy-aws-manifests/clients"
	"github.com/cloudfoundry/infrastructure-ci/scripts/deploy-aws-manifests/flags"
	"github.com/cloudfoundry/infrastructure-ci/scripts/deploy-aws-manifests/subnetchecker"
	"github.com/pivotal-cf-experimental/bosh-test/bosh"
)

func main() {
	configuration, err := flags.ParseFlags(os.Args[1:])
	if err != nil {
		fmt.Fprintf(os.Stderr, "\n\n%s\n", err)
		os.Exit(1)
	}

	boshConfig := bosh.Config{
		URL:              configuration.BoshDirector,
		Password:         configuration.BoshPassword,
		Username:         configuration.BoshUser,
		AllowInsecureSSL: true,
	}

	aws := clients.NewAWS(configuration.AWSAccessKeyID, configuration.AWSSecretAccessKey,
		configuration.AWSRegion, configuration.AWSEndpointOverride)
	bosh := clients.NewBOSH(bosh.NewClient(boshConfig), os.Stdout)
	subnetChecker := subnetchecker.NewSubnetChecker(aws)

	awsDeployer := awsdeployer.NewAWSDeployer(bosh, subnetChecker, os.Stdout)

	err = awsDeployer.Deploy(configuration.ManifestPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "\n\n%s\n", err)
		os.Exit(1)
	}

	os.Exit(0)
}
