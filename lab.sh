#!/bin/bash
#
# do it again

# specify -q as parameter for quick mode and skip intro
QMODE="$1"
CDK="$HOME/bin/cdkshift/minishift"
#OCP_VER="v3.6"

# declare config hashmap
declare -A config

lab_part_one () {
  ## Part 1
  config["VMDISC"]=20G
  config["MEM"]=$[4*1024]
  config["REG"]=no
  config["ADDONS"]="registry-console"
  config["STACKS"]=""
}

lab_part_two () {
  ## Part 2
  config["VMDISC"]=40G
  config["MEM"]=$[12*1024]
  config["REG"]=no
  config["ADDONS"]="registry-console cfme"
  config["STACKS"]="--metrics"
}

lab_part_three () {
  ## Part 3
  config["VMDISC"]=40G
  config["MEM"]=$[8*1024]
  config["REG"]=no
  config["ADDONS"]="registry-console"
  config["STACKS"]="--service-catalog"
}

## currently not used
full_lab () {
  ## full setup
  config["VMDISC"]=40G
  config["MEM"]=$[16*1024]
  config["REG"]=yes
  config["ADDONS"]="registry-console cfme"
  config["STACKS"]="--metrics --service-catlog"
}

pre_start_func () {
  # replace pre_start_script
  cd ~/git/cdk-labs/

  cdk config set memory ${config["MEM"]}
  cdk config set disk-size ${config["VMDISC"]}
  #cdk config set image-caching true

  for ADDON in ${config["ADDONS"]}
  do
	cdk addons install $ADDON
	cdk addons enable $ADDON
  done
}

install_ansible_service_broker () {
	DOCKERHUB_USER=${DOCKERHUB_USER:-"changeme"}
	DOCKERHUB_PASS=${DOCKERHUB_PASS:-"changeme"}
	DOCKERHUB_ORG=${DOCKERHUB_ORG:-"ansibleplaybookbundle"}

	#
	# Disabling basic auth allows "apb push" to work.
	#
	ENABLE_BASIC_AUTH="false"

	#
	#  Logging in as system:admin so we can create a clusterrolebinding
	#
	TEMPLATE_URL="https://raw.githubusercontent.com/openshift/ansible-service-broker/master/templates/deploy-ansible-service-broker.template.yaml"
	oc login -u system:admin
	oc new-project ansible-service-broker
	curl -s $TEMPLATE_URL \
  	| oc process \
	  -n ansible-service-broker \
	  -p DOCKERHUB_USER="$DOCKERHUB_USER" \
	  -p DOCKERHUB_PASS="$DOCKERHUB_PASS" \
	  -p DOCKERHUB_ORG="$DOCKERHUB_ORG" \
	  -p ENABLE_BASIC_AUTH="$ENABLE_BASIC_AUTH" -f - | oc create -f -

	if [ "$?" -ne 0 ]; then
	  echo "Error processing template and creating deployment"
	  exit
	fi
 
}


post_startup_func () {
 # check that the oc command is available otherwise create a link ( done by cdk / minishift usually )
 # test which oc &>/dev/null && echo oc was found || ln -s $(find ~/.minishift -name oc -type f) $HOME/bin/

 case $LAB in 
  1)  echo "Lab 1 is set up" ;;
	2)  cdk openshift config set --patch '{"imagePolicyConfig":{"maxImagesBulkImportedPerRepository": 100}}'
			oc login -u system:admin -n cloudforms
	    while ! oc get pod cloudforms-0 -o yaml | grep -q "ready: true" ; do oc get pod cloudforms-0 | tail -1; sleep 10; done
      echo "Lab 2 is set up" ;;
  3)  oc login -u system:admin
			oc adm policy add-cluster-role-to-group system:openshift:templateservicebroker-client system:unauthenticated system:authenticated
	    install_ansible_service_broker
			echo "Lab 3 is set up" ;;
  *)  echo "full lab is set up" ;;
 esac
}

###
# parse startopts 
# initialize vars

# look for starting options
while getopts dqhl: OPTS; do
  case $OPTS in 
   l) LAB=$OPTARG ;;
   q) QMODE="yes" ;;
   d) CDK="$HOME/bin/cdkshift/minishift-devel" ;;
	 h) cat <<-EHELP

			This tool let you set up the OpenShift Lab environment 
		
			The following Options are recognized :
		   -q      - quiet mode ( skip warnings and chatter )
		   -l LAB  - setup LAB nummber 1, 2 or 3 ( default is full lab = maximum resource consumption )
			
			EHELP
			exit 0
			;;
   ?) echo "Option $1 is not recognized, -h for help" ;;
  esac
done

case $LAB in 
  1) lab_part_one; echo "Starting Lab 1 Setup";;
  2) lab_part_two; echo "Starting Lab 2 Setup";;
	3) lab_part_three; echo "Starting Lab 3 Setup";;
	*) lab_part_one; echo "Starting Lab 1 Setup";;
esac

STOP_OPT=""
#START_OPT="--ocp-tag=$OCP_VER ${config["STACKS"]}"
START_OPT="${config["STACKS"]}"

# set stop and start args
#   we create a registered file to track prior registration
test "${config["REG"]}" = "no" && { test -f $HOME/.minishift/registered || STOP_OPT="$STOP_OPT --skip-unregistration"; }
test "${config["REG"]}" = "no" && START_OPT="$START_OPT --skip-registration" || touch $HOME/.minishift/registered

intro () {

	cat <<-EMSG
	Welcome to the OpenShift CDK Lab.

	Please Note :
	This tool will setup the lab on your machine.
	This will take ~15min at least.
	This will clear out your existing ~/.minishift !

	You can skip this intro by using Quick Mode with -q.
  You can select your target Lab environment with -l [123]

	EMSG
	read -p "Are you sure to continue? (Y/N) : " ANSWER  
	test "$ANSWER " != "Y " && { echo "Found \"$ANSWER\" expecting \"Y\" Aborting Procedure now"; exit 1 ; }

}

# Skip or call the intro?
test "$QMODE " != "yes " && { intro; }

################################
# This is where we do the work #
################################
time { 
  # stop running TODO check before this
  test "$($CDK status)" = "Running" && $CDK stop $STOP_OPT

  # delete minishift vm
  $CDK delete

  # empty out minishift config dir
  test -d $HOME/.minishift && { 
    test -f $HOME/.minishift/cdk && rm -rf $HOME/.minishift || { 
      echo "existing $HOME/.minishift moved to $HOME/minishift-saved"
      mv $HOME/.minishift $HOME/minishift-saved 
      }
  }

  # run new setup ( config dir and tools )
  $CDK setup-cdk
  touch $HOME/.minishift/cdk

  # install addons and set vm options
  pre_start_func ${config["ADDONS"]} 

  # start the new vm with all options 
  # -- remember how to start this instance ( used later by cdk start ) 
  echo MINISHIFT_ENABLE_EXPERIMENTAL=y $CDK start $START_OPT > $HOME/bin/cdk-start
  MINISHIFT_ENABLE_EXPERIMENTAL=y $CDK start $START_OPT

  # do things that are needed post start
  post_startup_func 
}
