#!/bin/bash
#
# stolen from https://github.com/openshift/ansible-service-broker
#
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

oc delete broker ansible-service-broker

ASB_ROUTE=`oc get routes | grep ansible-service-broker | awk '{print $2}'`

cat <<EOF | oc create -f -
    apiVersion: servicecatalog.k8s.io/v1alpha1
    kind: Broker
    metadata:
      name: ansible-service-broker
    spec:
      url: https://${ASB_ROUTE}
      authInfo:
        basicAuthSecret:
          namespace: ansible-service-broker
          name: asb-auth-secret
EOF

