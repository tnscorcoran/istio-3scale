#!/usr/bin/env bash

echo "Jaeger URL:"
echo      $(oc get route/tracing -n istio-system -o template --template {{.spec.host}})
echo
echo "Grafana URL:"
echo      $(oc get route/grafana -n istio-system -o template --template {{.spec.host}})
echo
