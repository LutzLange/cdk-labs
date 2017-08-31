#!/bin/bash
#
# Lab Setup on Linux ( tested on Fedora )
#
bold=$(tput bold)
normal=$(tput sgr0)
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
4. Check / Install wget
5. Get the latest CDK ( currently nightly builds for cdk-3.1 ) and put it in ~/bin
6. Check / Install kvm 
7. Install olab command in ~/bin

You will need to enter your password for prviledged actions.

ENDMESSAGE

read -p "Do you want to proceed ? (Y/N)" ANSWER
test "$ANSWER " != "Y " && { echo "Found \"$ANSWER\" expecting \"Y\" installation averted"; exit 1 ; }

# kick off install of CMDLine dev tools
echo -e "\n${bold}1. Check installing git ${normal}" 
git --version &>/dev/null && echo git was already installed || sudo $INSTALLCMD git

# Clone / update the repo
echo -e "\n${bold}2. Create ~/git directory and check out cdk-lab into ~/git/cdk-labs${normal}"
test -d ~/git && echo "~/git is already there" || mkdir ~/git
if test -d ~/git/cdk-labs; then
       echo "cdk-labs is already checked out, updating cdk-labs instead"
       cd ~/git/cdk-labs; git pull
       cd
else
       cd ~/git; git clone https://github.com/LutzLange/cdk-labs.git
fi

# Create bin folder
echo -e "\n${bold}3. Create ~/bin/cdkshift and extend your PATH to include ~/bin${normal}"
test -d ~/bin/cdkshift && echo "~/bin/cdkshift was there already" || mkdir -p ~/bin/cdkshift

# extend PATH if required
{ echo $PATH | grep -q $HOME/bin; } || echo 'export PATH=$PATH:$HOME/bin' >> ~/.bash_profile

# Installing wget
echo -e "\n${bold}4. Installing wget${normal}"
wget --help &>/dev/null && echo "wget already installed" || $INSTALLCMD wget

# Get CDK (ToDo official CDK when released) 
# get this every time
# - only transfer if newer
# - link to cdk to preserve existing minishift
#
echo -e "\n${bold}5. Getting latest CDK and CDK devel- this can be a slow download of ~400MB${normal}"
SKIP="NO"
test -f ~/bin/cdkshift/minishift && {
	# check and rm Mac if not the same
	SHANEW=$(curl http://sademo.de/linux/minishift.sha256sum 2>/dev/null | awk '{ print $1; }' )
	SHAOLD=$(sha256sum ~/bin/cdkshift/minishift | awk '{ print $1 }' )
	test "$SHANEW " = "$SHAOLD " && SKIP="YES" || { echo "SHA does not match remove existing minishift - removing to get new"; rm ~/bin/cdkshift/minishift; }
}
# implement SKIP?
wget -r --tries=15 --continue -nH --cut-dirs=1 -P ~/bin/cdkshift http://sademo.de/linux/minishift
test -L ~/bin/cdk || ln -s ~/bin/cdkshift/minishift ~/bin/cdk
chmod +x ~/bin/cdk

# Install KVM 
echo -e "\n${bold}6. Install KVM${normal}"
# what package to check?
# make sure user has kvm access
LOGOUT=0
id | grep -q libvirt && echo $USER is in libvirt || { sudo -i gpasswd -a $USER libvirt; echo Added $USER to libvirt; }
sudo curl -L https://github.com/dhiltgen/docker-machine-kvm/releases/download/v0.7.0/docker-machine-driver-kvm -o /usr/local/bin/docker-machine-driver-kvm
sudo chmod +x /usr/local/bin/docker-machine-driver-kvm
# 

# Install the olab Command in ~/bin
echo -e "\n${bold}7. Installing olab Script${normal}"
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


