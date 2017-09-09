#!/bin/bash
#
# Lab Setup on Linux ( tested on Fedora )
#

# helper header out for better readability

bold=$(tput bold)
normal=$(tput sgr0)
ACOUNT=0

# helper output function for action headers
hout () {
  message=$1
  ACOUNT=$[ACOUNT+1]
  echo -e "\n${bold}${ACOUNT}. $message ${normal}"
}

# what do I need to set for 
# Ubuntu?
# Debian?
# SuSE?
INSTALLCMD="dnf install -y"

cat <<ENDMESSAGE
You are running the OpenShift CDK Lab Installer for Linux (Fedora). The following actions will be taken :

1. Check / Install git 
2. Create ~/git directory and check out cdk-lab into ~/git/cdk-labs
3. Create ~/bin and extend your PATH to include ~/bin
4. Create a bash alias for oc to point to the latest minishift oc
5. Check / Install wget
6. Get the latest CDK ( currently nightly builds for cdk-3.1 ) and put it in ~/bin
7. Install a cdk wrapper script that allows for stop and start of labs
8. Check / Install kvm 
9. Install olab command in ~/bin

You will need to enter your password for prviledged actions.

ENDMESSAGE

read -p "Do you want to proceed ? (Y/N)" ANSWER
test "$ANSWER " != "Y " && { echo "Found \"$ANSWER\" expecting \"Y\" installation averted"; exit 1 ; }

# kick off install of CMDLine dev tools
hout "Check and install git" 
git --version &>/dev/null && echo git was already installed || sudo $INSTALLCMD git

# Clone / update the repo
hout "Create ~/git directory and check out cdk-lab into ~/git/cdk-labs"
test -d ~/git && echo "~/git is already there" || mkdir ~/git
if test -d ~/git/cdk-labs; then
       echo "cdk-labs is already checked out, updating cdk-labs instead"
       cd ~/git/cdk-labs; git pull
       cd
else
       cd ~/git; git clone https://github.com/LutzLange/cdk-labs.git
fi

# Create bin folder
hout "Create ~/bin/cdkshift and extend your PATH to include ~/bin"
test -d ~/bin/cdkshift && echo "~/bin/cdkshift was there already" || mkdir -p ~/bin/cdkshift

# extend PATH if required
{ echo $PATH | grep -q $HOME/bin; } || echo 'export PATH=$PATH:$HOME/bin' >> ~/.bash_profile

hout "Create a bash alias for oc to point to the latest minishift oc"
# create an alias for oc to use latest minishift oc version
grep -q 'alias oc' $HOME/.bashrc || echo 'alias oc=$HOME/.minishift/cache/oc/*/oc' >> $HOME/.bashrc

# Installing wget
hout "Installing wget"
wget --help &>/dev/null && echo "wget already installed" || $INSTALLCMD wget

# Get CDK (ToDo official CDK when released) 
# get this every time
# - only transfer if newer
# - link to cdk to preserve existing minishift
#
hout "Get CDK devel- this can be a slow download of ~400MB"
SKIP="NO"
test -f ~/bin/cdkshift/minishift && {
	# check and rm Mac if not the same
	SHANEW=$(curl http://sademo.de/linux/minishift.sha256sum 2>/dev/null | awk '{ print $1; }' )
	SHAOLD=$(sha256sum ~/bin/cdkshift/minishift | awk '{ print $1 }' )
	test "$SHANEW " = "$SHAOLD " && SKIP="YES" || { echo "SHA does not match remove existing minishift - removing to get new"; rm ~/bin/cdkshift/minishift; }
}
# SKIP or download CDK
test "$SKIP" = YES && echo CDK is current || wget -r --tries=15 --continue -nH --cut-dirs=1 -P ~/bin/cdkshift http://sademo.de/linux/minishift

# replace link with shell wrapper script to enable start & stop of lab
hout "Install CDK Wrapper"
test -L ~/bin/cdk && rm  ~/bin/cdk
test -f ~/bin/cdk || cp $HOME/git/cdk-labs/cdk-wrapper $HOME/bin/cdk
chmod +x ~/bin/cdk
echo "~/bin/cdk installed as a wrapper script for ~/bin/cdkshift/minishift"

# Install KVM 
hout "Install KVM"
# what package to check?
# make sure user has kvm access
LOGOUT=0
id | grep -q libvirt && echo $USER is in libvirt || { sudo -i gpasswd -a $USER libvirt; echo Added $USER to libvirt; }
test -f /usr/local/bin/docker-machine-driver-kvm && echo "Nothing to do docker-machine-kvm is installed" || {
  echo "Downloading and installing docker-machine-kvm driver requires root privs we assume sudo works on your machine. Enter your user password (twice)"
  sudo curl -L https://github.com/dhiltgen/docker-machine-kvm/releases/download/v0.7.0/docker-machine-driver-kvm -o /usr/local/bin/docker-machine-driver-kvm
  sudo chmod +x /usr/local/bin/docker-machine-driver-kvm
}
# 

# Install the olab Command in ~/bin
hout "Installing olab Script"
test -f ~/bin/olab && echo olab already there skipping copy || cp ~/git/cdk-labs/olab ~/bin

# You are ready to roll now
cat <<ENDMESSAGE

----------------------------------------------------------------------------
You are ready to check your environment and start the OpenShift environment.
You will have all the necessary tools installed now. 

${bold}Next steps :${normal}
${bold}1.${normal} Check your environment with : $ cdk version
${bold}2.${normal} Build or reset your lab environment with : $ olab -l1 

NOTES : 
 fast internet connection to download docker images highly recommended
 16 GB RAM recommended for lab 2

ENDMESSAGE


