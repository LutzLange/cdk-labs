#!/bin/bash
#
# some setting can't be done from addons, but need to be made after cdk / minishift start
#

# change master-config.yaml for cfme
cdk openshift config set --patch '{"imagePolicyConfig":{"maxImagesBulkImportedPerRepository": 100}}'
