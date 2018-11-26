#!/usr/bin/env bash

mkdir $HOME/lab

oc get deploy prod-apicast -n $GW_PROJECT -o yaml > $HOME/lab/prod-apicast.yml

sed -i "s/prod-apicast/$OCP_USERNAME-prod-apicast-istio/" $HOME/lab/prod-apicast.yml

sed -i "s/replicas:\ 1/replicas: 1\n  paused: true/" $HOME/lab/prod-apicast.yml

istioctl kube-inject -f $HOME/lab/prod-apicast.yml > $HOME/lab/prod-apicast-istio.yml
           
oc create -f $HOME/lab/prod-apicast-istio.yml -n $GW_PROJECT
     
oc patch deploy/$OCP_USERNAME-prod-apicast-istio -n $GW_PROJECT\
   --patch '{"spec":{"template":{"spec":{"containers":[{"name":"istio-proxy", "resources": {   "limits":{"cpu": "500m","memory": "128Mi"},"requests":{"cpu":"50m","memory":"32Mi"}   }}]}}}}'

oc patch deploy/$OCP_USERNAME-prod-apicast-istio -n $GW_PROJECT \
   --patch '{"spec":{"template":{"spec":{"initContainers":[{"name":"istio-init", "resources": {   "limits":{"cpu": "500m","memory": "128Mi"},"requests":{"cpu":"50m","memory":"32Mi"}   }}]}}}}'                

oc adm policy add-scc-to-user privileged -z default -n $GW_PROJECT --as=system:admin

oc rollout resume deploy/$OCP_USERNAME-prod-apicast-istio -n $GW_PROJECT

oc patch service/prod-apicast -n $GW_PROJECT \
   --patch '{"spec":{"selector":{"app":"'$OCP_USERNAME'-prod-apicast-istio"}}}'
   
echo \
    "apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: $OCP_USERNAME-catalog-apicast-egress-rule
spec:
  hosts:
  - $TENANT_NAME-admin.$API_WILDCARD_DOMAIN
  location: MESH_EXTERNAL
  ports:
  - name: https-443
    number: 443
    protocol: HTTPS
  resolution: DNS" \
 > $HOME/lab/catalog-apicast-egressrule.yml
 
oc create -f $HOME/lab/catalog-apicast-egressrule.yml -n $GW_PROJECT --as=system:admin




















   