#!/bin/bash
#
# do it again

# specify -q as parameter for quick mode and skip intro
QMODE="$1"

intro () {

	cat <<-EMSG
	Welcome to the OpenShift CDK Lab.

	Please Note :
	This tool will setup the lab on your machine.
	This will take ~15min at least.
	This will clear out your existing ~/.minishift !

	You can skip this intro by using Quick Mode with -q.

	EMSG
	read -p "Are you sure to continue? (Y/N) : " ANSWER  
	test "$ANSWER " != "Y " && { echo "Found \"$ANSWER\" expecting \"Y\" Aborting Procedure now"; exit 1 ; }

}

# Skip or call the intro?
test "$QMODE" != "-q" && { echo $QMODE; intro; }

################################
# This is where we do the work #
################################
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
