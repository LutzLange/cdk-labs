#!/bin/bash
#
# do it again
#

time { 
  # stop running TODO check before this
  cdk stop --skip-unregistration

  # delete minishift vm
  cdk delete

  # empty out minishift config dir
  test -d ~/.minishift && rm -rf ~/.minishift

  # run new setup ( config dir and tools )
  cdk setup-cdk

  # install addons and set vm options
  ~/git/cdk-labs/pre-start-script.sh

  # start the new vm with all options 
  cdk start --metrics --ocp-tag=v3.5 --skip-registration

  # do things that are needed post start ( adjust master-config.yaml )
  ~/git/cdk-labs/post-start-script.sh
}
