#!/usr/bin/env bash

echo "Private Base URL:"
echo "		http://catalog-service.$MSA_PROJECT.svc.cluster.local:8080"
echo
echo "Staging URL:"
echo "     \n`oc get route catalog-stage-apicast-$OCP_USERNAME -n $GW_PROJECT --template "https://{{.spec.host}}"`:443"   
echo
echo "Production URL:"
echo "     \n`oc get route catalog-prod-apicast-$OCP_USERNAME -n $GW_PROJECT --template "https://{{.spec.host}}"`:443\n\n"
echo
