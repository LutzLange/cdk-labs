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

post_startup_func () {
 case $LAB in 
  1)  echo "Lab 1 is set up" ;;
	2)  oc login -u system:admin -n cloudforms
	    while ! oc get pod cloudforms-0 -o yaml | grep -q "ready: true" ; do oc get pod cloudforms-0 | tail -1; sleep 10; done
      echo "Lab 2 is set up" ;;
  3)  echo "Lab 3 is set up" ;;
  *)  echo "full lab is set up" ;;
 esac
}

###
# parse startopts 
# initialize vars

# look for starting options
while getopts qhl: OPTS; do
  case $OPTS in 
   l) LAB=$OPTARG ;;
   q) QMODE="yes" ;;
	 h) cat <<-EHELP

			This tool let you set up the OpenShift Lab environment 
		
			The following Options are recognized :
		   -q      - quiet mode ( skip warnings and chatter )
		   -l LAB  - setup LAB nummber 1, 2 or 3 ( default is full lab = maximum resource consumption )
			
			EHELP
			exit 0
			;;
   ?) echo "Option "$1" is not recognized, -h for help" ;;
  esac
done

case $LAB in 
  1) lab_part_one;;
  2) lab_part_two;;
	3) lab_part_three;;
	*) full_lab;;
esac

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
test "$QMODE" != "yes" && { echo $QMODE; intro; }

################################
# This is where we do the work #
################################
time { 
  # stop running TODO check before this
  test "$(cdk status)" = "Running" && cdk stop $STOP_OPT

  # delete minishift vm
  cdk delete

  # empty out minishift config dir
  test -d $HOME/.minishift && { 
    test -f $HOME/.minishift/cdk && rm -rf $HOME/.minishift || { 
      echo "existing $HOME/.minishift moved to $HOME/minishift-saved"
      mv $HOME/.minishift $HOME/minishift-saved 
      }
  }

  # run new setup ( config dir and tools )
  cdk setup-cdk
  touch $HOME/.minishift/cdk

  # install addons and set vm options
  pre_start_func ${config["ADDONS"]} 

  # start the new vm with all options 
  cdk start $START_OPT

  # do things that are needed post start
  post_startup_func 
}
