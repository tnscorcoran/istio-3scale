#!/usr/bin/env bash

echo "export CATALOG_API_GW_HOST=`oc get route/catalog-prod-apicast-$OCP_USERNAME -n $GW_PROJECT -o template --template {{.spec.host}}`" >> ~/.bashrc

echo \
    "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: catalog-istio-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "$CATALOG_API_GW_HOST"" \
 > $HOME/lab/catalog-istio-gateway.yml
 
oc create -f $HOME/lab/catalog-istio-gateway.yml -n $GW_PROJECT --as=system:admin

echo \
    "apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: catalog-istio-gateway-vs
spec:
  hosts:
  - "$CATALOG_API_GW_HOST"
  gateways:
  - catalog-istio-gateway
  http:
  - match:
    - uri:
        prefix: /products
    route:
    - destination:
        port:
          number: 8080
        host: prod-apicast" \
> $HOME/lab/catalog-istio-gateway-vs.yml

oc create -f $HOME/lab/catalog-istio-gateway-vs.yml -n $GW_PROJECT --as=system:admin

echo "export INGRESS_HOST=$(oc -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')" >> ~/.bashrc

echo "export INGRESS_PORT=$(oc -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}') " >> ~/.bashrc
