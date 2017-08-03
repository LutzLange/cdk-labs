#!/bin/bash
#
# test Lab Setup with ansible an Mac OS
#  Convert to Ansible?
#
bold=$(tput bold)
normal=$(tput sgr0)

cat <<ENDMESSAGE
You are running the OpenShift CDK Lab Installer for MacOS. The following actions will be taken :

1. Install XCode Developer Toolset for git usage
2. Create ~/git directory and check out cdk-lab into ~/git/cdk-labs
3. Create ~/bin and extend your PATH to include ~/bin
4. Install Homebrew
5. Check for Google Chrome && Install Homebrew Cask & Google Chrome if not found
6. Install wget
7. Get the latest CDK ( currently nightly builds for cdk-3.1 ) and put it in ~/bin
8. Install docker-machine-driver-xhyve
9. Install olab command in ~/bin

You will need to enter your password for prviledged actions.

ENDMESSAGE

read -p "Do you want to proceed ? (Y/N)" ANSWER
test "$ANSWER" != Y && { echo "Found \"$ANSWER\" expecting \"Y\" installation averted"; exit 1 ; }

STEP=0

# kick off install of CMDLine dev tools
echo -e "\n${bold}1. Installing XCode Developer Toolset${normal}" 
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

# Install homebrew
echo -e "\n${bold}4. Checking / Installing homebrew${normal}"
brew --version &>/dev/null && echo "homebrew already installed" || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# check for Chrome
echo -e "\n${bold}5. Checking / Installing Google Chrome${normal}"
test -d '/Applications/Google Chrome.app' && { echo found Google Chrome skipping install; } || {

	# Install homebrew cask
	echo -e "\nChecking / Installing Homebrew Cask"
	brew list brew-cask &>/dev/null && echo "brew-cask already installed" || brew install brew-cask

	# Install google-chrome
	echo -e "\nInstalling Google Chrome"
	brew cask install google-chrome
}

# Installing wget
echo -e "\n${bold}6. Installing wget${normal}"
brew list wget &>/dev/null && echo "wget already installed" || brew install wget

# Get CDK (ToDo official CDK when released) 
# get this every time
# - only transfer if newer
# - link to cdk to preserve existing minishift
#
echo -e "\n${bold}7. Getting latest CDK - this can be a slow download of ~400MB${normal}"
wget -r --tries=15 --continue -nH --cut-dirs=1 -P ~/bin/cdkshift http://sademo.de/mac/minishift
test -L ~/bin/cdk || ln -s ~/bin/cdkshift/minishift ~/bin/cdk
chmod +x ~/bin/cdk

# Install docker-machine-driver-xhyve
echo -e "\n${bold}8. Installing docker-machine-driver-xhyve${normal}"
brew list docker-machine-driver-xhyve &>/dev/null && echo "xhyve was installed" || brew install docker-machine-driver-xhyve

# Install the olab Command in ~/bin
echo -e "\n${bold}9. Installing olab Script${normal}"
test -f ~/bin/olab && echo olab already there skipping copy || cp ~/git/cdk-labs/olab ~/bin

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


