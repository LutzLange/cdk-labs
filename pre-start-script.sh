#
# Enable add ons and prefill minishift cache
# 
ADDONS="registry-console cfme"
IMARCH="/nfsdata/cdk3-cache.tar"

cd ~/git/cdk-labs/

cdk config set memory 12288 
cdk config set disk-size 40g
cdk config set image-caching true

for ADDON in $ADDONS
do
	cdk addons install $ADDON
	cdk addons enable $ADDON
done	

# pre fill cache - is not picked up by nightly cdk 12-July-17
# tar xvf $IMARCH -C $HOME

