#!/bin/bash
##############################################################################
# Reference:
# https://www.logicmonitor.com/support/rest-api-developers-guide/v2/rest-api-v2-overview
# https://www.logicmonitor.com/support/rest-api-developers-guide/overview/using-logicmonitors-rest-api
# https://www.logicmonitor.com/support/rest-api-developers-guide/v1/alerts/get-alerts
##############################################################################

SCRIPTDIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function usage() {
  echo
  echo "Usage: basename $0 [alert filter]"
  echo
  exit 1
}

function die() {
  echo $1
  exit 1
}

if [ $# -eq 0 ]; then
  usage
else
  filter=${1} 
fi

# TODO: Check for dependencies.  jq, openssl, base64.

# Set variables from environment variables.
if [[ -z "${LM_ID}" ]]; then
  die "Please set the LM_ID environment variable and try again."
elif [[ -z "${LM_KEY}" ]]; then
  die "Please set the LM_KEY environment variable and try again."
fi
id="${LM_ID}"
key="${LM_KEY}"

# Prepare the API call to LogicMonitor based on documentation.
# https://www.logicmonitor.com/support/rest-api-developers-guide/v1/alerts/get-alerts
verb='GET'
epoch=$(date +"%s000")
path='/alert/alerts'
requestVars="${verb}${epoch}${path}"
hmac=$(echo -n "${requestVars}" | openssl sha256 -hmac "${key}" | sed -e 's/.* //')
b64=$(echo -n ${hmac} | base64)
auth="LMV1 ${id}:${b64}:${epoch}"

url="https://five9.logicmonitor.com/santaba/rest${path}?filter=_all~${filter}"
curl -s \
  -H "Content-Type: application/json" \
  -H "Authorization: ${auth}" \
  "${url}" \
  | jq -r '.data.items[].monitorObjectName'           

#signature=base64(HMAC-SHA256(Access Key,HTTP VERB + TIMESTAMP (in epoch milliseconds) + POST/PUT DATA (if any) + RESOURCE PATH) )
