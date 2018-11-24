#!/usr/bin/env bash

echo "Jaeger URL:"
echo -en "         http://"$(oc get route/tracing -o template --template {{.spec.host}} -n istio-system)"\n\n"
echo
echo "Grafana URL:"
echo -en "         http://"$(oc get route/grafana -o template --template {{.spec.host}} -n istio-system)"\n\n"
echo
