#!/bin/bash
set -euo pipefail

BROKER_DIR=$1
TOPIC=$2

BROKER_CONFIG="${BROKER_DIR}/broker.config"

PRODUCER_CONFIG=$(mktemp)
cat <<EOF > "${PRODUCER_CONFIG}"
$(<$BROKER_CONFIG)
batch.size=16384
linger.ms=500
EOF

"${KAFKA_BIN}/kafka-producer-perf-test.sh" --print-metrics \
  --topic "${TOPIC}" \
  --num-records 10000 \
  --throughput -1 \
  --record-size 1024 \
  --producer.config "${PRODUCER_CONFIG}"
