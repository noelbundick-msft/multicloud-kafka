#!/bin/bash
set -euo pipefail

TEST_SCRIPT=$1

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

export clusterName=$(curl -u admin:${password} -sS -G "http://headnodehost:8080/api/v1/clusters" | jq -r '.items[].Clusters.cluster_name')
export KAFKABROKERS=$(curl -sS -u admin:${password} -G https://${clusterName}.azurehdinsight.net/api/v1/clusters/${clusterName}/services/KAFKA/components/KAFKA_BROKER | jq -r '["\(.host_components[].HostRoles.host_name):9092"] | join(",")' | cut -d',' -f1,2);

# TODO: ensure tests use same version of kafka tools
export KAFKA_BIN="${SCRIPT_DIR}/_kafka/bin"

BROKERINFO="${SCRIPT_DIR}/.brokerinfo"
TOPIC=$(grep -oP 'TOPIC=\K.*' "${BROKERINFO}")

cat <<EOF >"${SCRIPT_DIR}/broker.config"
bootstrap.servers=${KAFKABROKERS}
EOF

$TEST_SCRIPT "${SCRIPT_DIR}" "${TOPIC}"
