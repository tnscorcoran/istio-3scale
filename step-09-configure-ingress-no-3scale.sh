#!/usr/bin/env bash

oc scale deploy/prod-apicast --replicas=0 -n $GW_PROJECT

oc scale deploy/$OCP_USERNAME-prod-apicast-istio --replicas=0 -n $GW_PROJECT

oc delete virtualservice catalog-istio-gateway-vs -n $GW_PROJECT --as=system:admin

oc delete gateway catalog-istio-gateway -n $GW_PROJECT --as=system:admin

echo \
    "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: catalog-direct-gw
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - \"*\"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: catalog-direct-vs
spec:
  hosts:
  - \"*\"
  gateways:
  - catalog-direct-gw
  http:
  - match:
    - uri:
        prefix: /products
    - uri:
        prefix: /product
    route:
    - destination:
        host: catalog-service
        port:
          number: 8080" \
 > $HOME/lab/catalog-direct-gw-vs.yml
 
oc create -f ~/lab/catalog-direct-gw-vs.yml -n $MSA_PROJECT --as=system:admin 

oc project istio-system
oc delete pod `oc get pod -n istio-system | grep "istio-policy" | awk '{print $1}'` \
     -n istio-system \
     --as=system:admin















