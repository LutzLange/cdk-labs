#!/bin/bash
#
# After setting up the Red Hat Container Development Kit (CDK), create a symlink 'cdk' to it.
#

time { 
  # stop running TODO check before this
  cdk stop 

  # delete minishift vm
  cdk delete

  # empty out minishift config dir
  test -d ~/.minishift && rm -rf ~/.minishift

  # set minimum requirements for VM
  cdk config set cpu 7
  cdk config set memory 12288

  # run new setup ( config dir and tools )
  cdk setup-cdk

  # install addons and set vm options
  ~/git/cdk-labs/pre-start-script.sh

  # start the new vm with all options TODO change registration to use VARS
  cdk start --metrics --ocp-tag=v3.5 

  # do things that are needed post start ( adjust master-config.yaml )
  ~/git/cdk-labs/post-start-script.sh
}
