#!/bin/bash
#
# stolen from https://github.com/openshift/ansible-service-broker
#
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

