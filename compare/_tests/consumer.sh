#!/bin/bash
set -euo pipefail

BROKER_DIR=$1
TOPIC=$2

BROKER_CONFIG="${BROKER_DIR}/broker.config"
BOOTSTRAP_SERVER=$(grep -oP 'bootstrap.servers=\K.*' "${BROKER_CONFIG}")

CONSUMER_CONFIG=$(mktemp)
cat <<EOF > "${CONSUMER_CONFIG}"
$(<$BROKER_CONFIG)
EOF

"${KAFKA_BIN}/kafka-consumer-perf-test.sh" --print-metrics \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --consumer.config "${CONSUMER_CONFIG}" \
  --messages 10000 \
  --topic "${TOPIC}" 
