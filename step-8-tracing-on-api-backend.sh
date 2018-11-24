#!/usr/bin/env bash

oc get deploy catalog-service -n $MSA_PROJECT -o yaml > $HOME/lab/catalog-service.yml

sed -i "s/ catalog-service/ $OCP_USERNAME-cat-service-istio/" $HOME/lab/catalog-service.yml

sed -i "s/replicas:\ 1/replicas: 1\n  paused: true/" $HOME/lab/catalog-service.yml

istioctl kube-inject \
           -f $HOME/lab/catalog-service.yml \
           > $HOME/lab/catalog-service-istio.yml

echo "service-name: $OCP_USERNAME-catalog-service
catalog.http.port: 8080
connection_string: mongodb://catalog-mongodb:27017
db_name: catalogdb
username: mongo
password: mongo
sampler-type: const
sampler-param: 1
reporter-log-spans: True
collector-endpoint: \"http://jaeger-collector.istio-system.svc:14268/api/traces\"
" > $HOME/lab/app-config.yaml

oc delete configmap app-config -n $MSA_PROJECT

oc create configmap app-config --from-file=$HOME/lab/app-config.yaml -n $MSA_PROJECT

oc create \
     -f $HOME/lab/catalog-service-istio.yml \
     -n $MSA_PROJECT
     
oc set env deploy/$OCP_USERNAME-cat-service-istio APP_CONFIGMAP_NAME=app-config  -n $MSA_PROJECT


oc set env deploy/$OCP_USERNAME-cat-service-istio APP_CONFIGMAP_KEY=app-config.yaml  -n $MSA_PROJECT

oc set env deploy/$OCP_USERNAME-cat-service-istio JAVA_DEBUG=true  -n $MSA_PROJECT
oc set env deploy/$OCP_USERNAME-cat-service-istio JAVA_DEBUG_PORT=8787  -n $MSA_PROJECT     

oc patch deploy/$OCP_USERNAME-cat-service-istio \
   --patch '{"spec":{"template":{"spec":{"containers":[{"name":"istio-proxy", "resources": {   "limits":{"cpu": "500m","memory": "128Mi"},"requests":{"cpu":"50m","memory":"32Mi"}   }}]}}}}' \
   -n $MSA_PROJECT

oc patch deploy/$OCP_USERNAME-cat-service-istio \
   --patch '{"spec":{"template":{"spec":{"initContainers":[{"name":"istio-init", "resources": {   "limits":{"cpu": "500m","memory": "128Mi"},"requests":{"cpu":"50m","memory":"32Mi"}   }}]}}}}' \
   -n $MSA_PROJECT

oc patch deploy/$OCP_USERNAME-cat-service-istio \
   --patch '{"spec":{"template":{"spec":{"containers":[{"name":"'$OCP_USERNAME'-cat-service-istio", "image": "docker.io/rhtgptetraining/catalog-service-tracing:1.0.17" }]}}}}' \
   -n $MSA_PROJECT

oc rollout resume deploy/$OCP_USERNAME-cat-service-istio -n $MSA_PROJECT

oc patch service/catalog-service \
   --patch '{"spec":{"selector":{"deployment":"'$OCP_USERNAME'-cat-service-istio"}}}' \
   -n $MSA_PROJECT

oc scale deploy/catalog-service --replicas=0 -n $MSA_PROJECT





