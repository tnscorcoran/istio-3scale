#!/usr/bin/env bash

oc create -f $HOME/lab/istio-integration/3scaleAdapter/istio/authorization-template.yaml --as=system:admin

oc create -f $HOME/lab/istio-integration/3scaleAdapter/istio/threescale-adapter.yaml --as=system:admin

sed -i "s/service_id: .*/service_id: \"$CATALOG_SERVICE_ID\"/" \
      $HOME/lab/istio-integration/3scaleAdapter/istio/threescale-adapter-config.yaml

sed -i "s/system_url: .*/system_url: \"https:\/\/$TENANT_NAME-admin.$API_WILDCARD_DOMAIN\"/" \
      $HOME/lab/istio-integration/3scaleAdapter/istio/threescale-adapter-config.yaml

sed -i "s/access_token: .*/access_token: \"$API_ADMIN_ACCESS_TOKEN\"/" \
      $HOME/lab/istio-integration/3scaleAdapter/istio/threescale-adapter-config.yaml

oc create -f $HOME/lab/istio-integration/3scaleAdapter/istio/threescale-adapter-config.yaml --as=system:admin
