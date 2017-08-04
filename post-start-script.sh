#!/bin/bash
#
# some setting can't be done from addons, but need to be made after cdk / minishift start
#

# change master-config.yaml for cfme
cdk openshift config set --patch '{"imagePolicyConfig":{"maxImagesBulkImportedPerRepository": 100}}'

### Configure Cloud Provider 

# CF needs to be up and running
#   ? delay this until CF is up
oc login -u system:admin -n cloudforms
while ! oc get pod cloudforms-0 -o yaml | grep -q "ready: true" ; do oc get pod cloudforms-0 | tail -1; sleep 10; done

# oc descrbibe pod cloudforms-0

# activate roles in CF
#   Smart Proxy
#   

# configure provider in CF

# get token
#   # base64 -d not working on mac
# TOKEN=$(oc get -n management-infra secrets $(oc get -n management-infra sa/management-admin --template='{{range .secrets}}{{printf "%s\n" .name}}{{end}}' | grep management-admin-token) --template='{{.data.token}}' | base64 -d)


# get masterURL / IP

# get metricsURL


