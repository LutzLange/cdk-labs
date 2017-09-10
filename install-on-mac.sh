#!/bin/bash
#
# CDK OpenShift Lab Setup on MacOS
#  Convert to Ansible?
# 
bold=$(tput bold)
normal=$(tput sgr0)
ACOUNT=0

# helper output function for action headers
hout () {
  message=$1
  ACOUNT=$[ACOUNT+1]
  echo -e "\n${bold}${ACOUNT}. $message ${normal}"
}

cat <<ENDMESSAGE
You are running the OpenShift CDK Lab Installer for MacOS. The following actions will be taken :

1. Install XCode Developer Toolset for git usage
2. Create ~/git directory and check out cdk-lab into ~/git/cdk-labs
3. Create ~/bin and extend your PATH to include ~/bin
4. Create a bash alias for oc to point to the latest minishift oc
5. Install Homebrew
6. Check for Google Chrome && Install Homebrew Cask & Google Chrome if not found
7. Install wget
8. Get the latest CDK ( currently nightly builds for cdk-3.1 ) and put it in ~/bin
9. Install docker-machine-driver-xhyve
10. Install olab command in ~/bin
11. Install bash 4

You will need to enter your password for prviledged actions.

ENDMESSAGE

read -p "Do you want to proceed ? (Y/N)" ANSWER
test "$ANSWER " != "Y " && { echo "Found \"$ANSWER\" expecting \"Y\" installation averted"; exit 1 ; }

# kick off install of CMDLine dev tools
hout "Installing XCode Developer Toolset" 
sudo xcode-select --install

# Accept License agreement for xcode
echo "   Accepting XCode License Agreement"
sudo /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -license accept

# prefered way to install ansible on MacOS is pip
#echo "Installing Pip for Ansible"
#pip &>/dev/null || sudo easy_install pip

# install ansible
#echo "Installing Ansible"
#ansible --version &>/dev/null || sudo pip install ansible

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
{ echo $PATH | grep -q $HOME/bin; } || echo "export PATH=$PATH:$HOME/bin" >> ~/.bash_profile
cp ~/.bash_profile ~/.bashrc

hout "Create a bash alias for oc to point to the latest minishift oc"
# create an alias for oc to use latest minishift oc version
grep -q 'alias oc' $HOME/.bashrc || echo 'alias oc=$HOME/.minishift/cache/oc/*/oc' >> $HOME/.bashrc

# Install homebrew
hout "Checking / Installing homebrew"
brew --version &>/dev/null && echo "homebrew already installed" || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# check for Chrome
hout "Checking / Installing Google Chrome"
test -d '/Applications/Google Chrome.app' && { echo found Google Chrome skipping install; } || {

	# Install homebrew cask
	echo -e "\nChecking / Installing Homebrew Cask"
	brew list brew-cask &>/dev/null && echo "brew-cask already installed" || brew install brew-cask

	# Install google-chrome
	echo -e "\nInstalling Google Chrome"
	brew cask install google-chrome
}

# Installing wget
hout "Installing wget"
brew list wget &>/dev/null && echo "wget already installed" || brew install wget

# Get CDK (ToDo official CDK when released) 
# get this every time
# - only transfer if newer
# - link to cdk to preserve existing minishift
#
hout "Getting latest CDK - this can be a slow download of ~400MB"

SKIP="NO"
test -f ~/bin/cdkshift/minishift && {
	# check and rm Mac if not the same
	SHANEW=$(curl http://sademo.de/mac/minishift.sha256sum 2>/dev/null | awk '{ print $1; }' )
	SHAOLD=$(shasum -a 256 ~/bin/cdkshift/minishift | awk '{ print $1 }' )
	test "$SHANEW " = "$SHAOLD " && SKIP="YES" || { echo "SHA does not match remove existing minishift - removing to get new"; rm ~/bin/cdkshift/minishift; }
}

# SKIP or download new CDK
test "$SKIP" = YES && echo CDK is current || wget -r --tries=15 --continue -nH --cut-dirs=1 -P ~/bin/cdkshift http://sademo.de/mac/minishift
chmod +x ~/bin/cdkshift/minishift

# replace link with shell wrapper script to enable start & stop of lab
hout "Install CDK Wrapper"
test -L ~/bin/cdk && rm  ~/bin/cdk
test -f ~/bin/cdk || cp $HOME/git/cdk-labs/cdk-wrapper $HOME/bin/cdk
chmod +x ~/bin/cdk
echo "~/bin/cdk installed as a wrapper script for ~/bin/cdkshift/minishift"

# Install docker-machine-driver-xhyve
hout "Installing docker-machine-driver-xhyve"
brew list docker-machine-driver-xhyve &>/dev/null && echo "xhyve was installed" || brew install docker-machine-driver-xhyve
sudo chown root:wheel /usr/local/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
sudo chmod u+s /usr/local/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve

# Install the olab Command in ~/bin
hout "Installing olab Script"
test -f ~/bin/olab && echo olab already there skipping copy || cp ~/git/cdk-labs/olab ~/bin

# Install bash 4
hout "Install Bash 4"
brew list bash &>/dev/null && echo "bash installed via brew already" || brew install bash

# You are ready to roll now
cat <<ENDMESSAGE

----------------------------------------------------------------------------
You are ready to check your environment and start the OpenShift environment.
You will have all the necessary tools installed now. 

${bold}Next steps :${normal}
${bold}1.${normal} Check your environment with : $ cdk version
${bold}2.${normal} Build or reset your lab environment with : $ olab 

NOTES : 
 fast internet connection to download docker images highly recommended
 16 GB RAM recommended ( tuning required if you have less )

ENDMESSAGE


