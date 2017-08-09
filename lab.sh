#!/bin/bash
#
# do it again

# specify -q as parameter for quick mode and skip intro
QMODE="$1"
OCP_VER="v3.5"

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
  config["MEM"]=$[14*1024]
  config["REG"]=yes
  config["ADDONS"]="cns"
  config["STACKS"]=""
}

full_lab () {
  ## full setup
  config["VMDISC"]=40G
  config["MEM"]=$[16*1024]
  config["REG"]=yes
  config["ADDONS"]="registry-console cfme cns"
  config["STACKS"]="--metrics"
}

pre_start_func () {
  # replace pre_start_script
  echo "Not implemented yet"
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

###
# initialize vars

# TODO use getopts
lab_part_two

STOP_OPT=""
START_OPT="--ocp-tag=$OCP_VER ${config["STACKS"]}"

# set stop and start args
test "${config["REG"]}" = "no" && STOP_OPT="$STOP_OPT --skip-unregistration"
test "${config["REG"]}" = "no" && START_OPT="$START_OPT --skip-registration" 

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
  echo test "$(cdk status)" = "Running" && cdk stop $STOP_OPT

  # delete minishift vm
  cdk delete

  # empty out minishift config dir
  test -d ~/.minishift && { 
    test -f ~/.minishift/cdk && rm -rf ~/.minishift || { 
      echo "existing ~/.minishift moved to ~/minishift-saved"
      mv ~/.minishift ~/minishift-saved 
      }
  }

  # run new setup ( config dir and tools )
  cdk setup-cdk
  touch ~/.minishift/cdk

  # install addons and set vm options
  pre_start_func ${config["ADDONS"]} 

  # start the new vm with all options 
  cdk start $START_OPT

  # do things that are needed post start ( adjust master-config.yaml )
  ~/git/cdk-labs/post-start-script.sh
}
