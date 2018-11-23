#!/usr/bin/env bash


#####################################################################################################################
# https://github.com/sborenst/ansible_agnostic_deployer/tree/development/ansible/roles/ocp-workload-3scale-multitenant
#####################################################################################################################

WORKLOAD="ocp-workload-3scale-multitenant"
SUBDOMAIN_BASE=`oc whoami --show-server | cut -d'.' -f 2,3,4,5 | cut -d':' -f 1`
ADM_USERNAME=api0


# API manager provision
ansible-playbook -i localhost, -c local ./configs/ocp-workloads/ocp-workload.yml \
                    -e"ANSIBLE_REPO_PATH=`pwd`" \
                    -e"ocp_workload=${WORKLOAD}" \
                    -e"ACTION=create" \
                    -e"subdomain_base=$SUBDOMAIN_BASE" \
                    -e"admin_username=$ADM_USERNAME"


# Tenant management
START_TENANT=1
END_TENANT=1
CREATE_GWS_WITH_EACH_TENANT=true

# Tenant Management
ansible-playbook -i localhost, -c local ./configs/ocp-workloads/ocp-workload.yml \
                    -e"ANSIBLE_REPO_PATH=`pwd`" \
                    -e"ocp_workload=${WORKLOAD}" \
                    -e"ACTION=tenant_mgmt" \
                    -e"start_tenant=$START_TENANT" \
                    -e"end_tenant=$END_TENANT" \
                    -e"subdomain_base=$SUBDOMAIN_BASE" \
                    -e"create_gws_with_each_tenant=$CREATE_GWS_WITH_EACH_TENANT" \
                    -e"admin_username=$ADM_USERNAME"


#####################################################################################################################
# https://github.com/sborenst/ansible_agnostic_deployer/tree/development/ansible/roles/ocp-workload-istio-community
#####################################################################################################################

WORKLOAD="ocp-workload-istio-community"

ansible-playbook -i localhost, -c local ./configs/ocp-workloads/ocp-workload.yml \
                    -e"ANSIBLE_REPO_PATH=`pwd`" \
                    -e"ocp_workload=${WORKLOAD}" \
                    -e"ACTION=create"

ansible-playbook -i localhost, -c local ./configs/ocp-workloads/ocp-workload.yml \
                    -e"ANSIBLE_REPO_PATH=`pwd`" \
                    -e"ocp_workload=${WORKLOAD}" \
                    -e"ACTION=remove"


#####################################################################################################################
#https://github.com/sborenst/ansible_agnostic_deployer/tree/development/ansible/roles/ocp-workload-rhte-mw-api-mesh
#####################################################################################################################

WORKLOAD="ocp-workload-rhte-mw-api-mesh"
GUID=a1001
OCP_USERNAME="developer"
ansible-playbook -i localhost, -c local ./configs/ocp-workloads/ocp-workload.yml \
                    -e"ANSIBLE_REPO_PATH=`pwd`" \
                    -e"ocp_username=${OCP_USERNAME}" \
                    -e"ocp_workload=${WORKLOAD}" \
                    -e"guid=${GUID}" \
                    -e"ACTION=create"

ansible-playbook -i localhost, -c local ./configs/ocp-workloads/ocp-workload.yml \
                    -e"ANSIBLE_REPO_PATH=`pwd`" \
                    -e"ocp_username=${OCP_USERNAME}" \
                    -e"ocp_workload=${WORKLOAD}" \
                    -e"guid=${GUID}" \
                    -e"ACTION=remove"
                    
                    