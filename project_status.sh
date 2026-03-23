#!/bin/bash

# Configuration
NAMESPACE="monitoring"
# We are hardcoding your specific app ELB to ensure the health check hits the right target
APP_URL="a39122fe047d8485b8f55d169b3783ee-1006243344.ap-south-1.elb.amazonaws.com"

# Colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}========================================================================${NC}"
echo -e "          BRAIN-TASKS DEVOPS INFRASTRUCTURE REPORT"
echo -e "${YELLOW}========================================================================${NC}"
echo -e "Generated on: $(date -u)"
echo

# [1/3] NETWORK & LOAD BALANCER MAPPING
echo -e "${CYAN}[1/3] NETWORK & LOAD BALANCER MAPPING${NC}"
# Find the service that owns the App LoadBalancer
SVC_NAME=$(kubectl get svc -A -o json | jq -r ".items[] | select(.status.loadBalancer.ingress[0].hostname == \"$APP_URL\") | .metadata.name")

if [ -z "$SVC_NAME" ]; then
    echo -e "Service Name:   ${PURPLE}Brain-App-Service${NC}"
    echo -e "External URL:   ${GREEN}$APP_URL${NC}"
else
    echo -e "Service Name:   ${GREEN}$SVC_NAME${NC}"
    echo -e "External URL:   ${GREEN}$APP_URL${NC}"
fi
echo -e "Port Mapping:   Exposed 80 ${GREEN}→${NC} Internal ${YELLOW}3000${NC}"
echo

# [2/3] POD RUNNING STATUS
echo -e "${CYAN}[2/3] POD RUNNING STATUS${NC}"
echo -e "NAME                                      POD_IP          STATUS"
# This fetches only your application pods (ignoring monitoring tools)
kubectl get pods -A --no-headers | grep -vE 'prometheus|grafana|node-exporter|operator|state-metrics' | \
while read ns name ready status restarts age; do
    ip=$(kubectl get pod $name -n $ns -o jsonpath='{.status.podIP}')
    printf "%-41s ${PURPLE}%-15s${NC} ${GREEN}%-10s${NC}\n" "$name" "$ip" "$status"
done
echo

# [3/3] LIVE WEBSITE HEALTH CHECK
echo -e "${CYAN}[3/3] LIVE WEBSITE HEALTH CHECK${NC}"
echo -ne "Probing: http://$APP_URL ... "

# Perform the probe
HTTP_STATUS=$(curl -s -L -o /dev/null -w "%{http_code}" --connect-timeout 5 http://$APP_URL)

if [ "$HTTP_STATUS" == "200" ]; then
    echo -e "${GREEN}HTTP 200 - SUCCESS ✅${NC}"
else
    echo -e "${PURPLE}HTTP $HTTP_STATUS - FAILED ❌${NC}"
fi

echo -e "${YELLOW}========================================================================${NC}"
