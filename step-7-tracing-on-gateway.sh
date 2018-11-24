#!/usr/bin/env bash

oc project $GW_PROJECT

oc rollout pause deploy $OCP_USERNAME-prod-apicast-istio

cat <<EOF > $HOME/lab/jaeger_config.json
{
    "service_name": "$OCP_USERNAME-prod-apicast-istio",
    "disabled": false,
    "sampler": {
      "type": "const",
      "param": 1
    },
    "reporter": {
      "queueSize": 100,
      "bufferFlushInterval": 10,
      "logSpans": false,
      "localAgentHostPort": "jaeger-agent.istio-system:6831"
    },
    "headers": {
      "jaegerDebugHeader": "debug-id",
      "jaegerBaggageHeader": "baggage",
      "TraceContextHeaderName": "uber-trace-id",
      "traceBaggageHeaderPrefix": "testctx-"
    },
    "baggage_restrictions": {
        "denyBaggageOnInitializationFailure": false,
        "hostPort": "jaeger-agent.istio-system:5778",
        "refreshInterval": 60
    }
}
EOF

oc create configmap jaeger-config --from-file=$HOME/lab/jaeger_config.json -n $GW_PROJECT

oc volume deploy/$OCP_USERNAME-prod-apicast-istio --add -m /tmp/jaeger/ --configmap-name jaeger-config -n $GW_PROJECT

oc env deploy/$OCP_USERNAME-prod-apicast-istio \
         OPENTRACING_TRACER=jaeger \
         OPENTRACING_CONFIG=/tmp/jaeger/jaeger_config.json \
         -n $GW_PROJECT
         
oc patch deploy/$OCP_USERNAME-prod-apicast-istio \
   --patch '{"spec":{"template":{"spec":{"containers":[{"name":"'$OCP_USERNAME'-prod-apicast-istio", "image": "quay.io/3scale/apicast:master" }]}}}}'

oc rollout resume deploy $OCP_USERNAME-prod-apicast-istio

         	

