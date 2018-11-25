#!/usr/bin/env bash

cd $HOME/lab/

git clone \
      --branch rhte-2018 \
      https://github.com/gpe-mw-training/istio-integration.git \
      $HOME/lab/istio-integration

oc create -f $HOME/lab/istio-integration/3scaleAdapter/openshift -n istio-system --as=system:admin

oc set env dc/3scale-istio-adapter --containers="3scale-istio-adapter" -e "THREESCALE_LOG_LEVEL=debug" -n istio-system --as=system:admin

oc set env dc/3scale-istio-adapter --containers="3scale-istio-httpclient" -e "APICAST_LOG_LEVEL=debug" -n istio-system --as=system:admin


cd $HOME/istio-3scale







