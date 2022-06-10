#!/bin/bash
set -euo pipefail

# Tests accept args: test_script.sh ${BROKER_DIR} ${TOPIC}
# Tests are allowed to access broker.config
# Tests are NOT allowed to access .brokerinfo. The broker's runner.sh should configure all env vars / etc. beforehand

BROKER_DIR=$1
TOPIC=$2

BROKER_CONFIG="${BROKER_DIR}/broker.config"

PRODUCER_CONFIG=$(mktemp)
cat <<EOF > "${PRODUCER_CONFIG}"
$(<$BROKER_CONFIG)
batch.size=16384
linger.ms=500
compression.type=gzip
EOF

"${KAFKA_BIN}/kafka-producer-perf-test.sh" --print-metrics \
  --topic "${TOPIC}" \
  --num-records 100 \
  --throughput -1 \
  --record-size 1024 \
  --producer.config "${PRODUCER_CONFIG}"
