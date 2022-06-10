#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
BROKERINFO="${SCRIPT_DIR}/.brokerinfo"

export KAFKA_OPTS="-Djava.security.auth.login.config=${SCRIPT_DIR}/jaas.conf"
BOOTSTRAP_SERVER=$(grep -oP 'BOOTSTRAP_SERVER=\K.*' "${BROKERINFO}")
TOPIC=$(grep -oP 'TOPIC=\K.*' "${BROKERINFO}")

"${KAFKA_BIN}/kafka-producer-perf-test.sh" --print-metrics \
  --topic "${TOPIC}" \
  --num-records 1000000 \
  --throughput -1 \
  --record-size 1024 \
  --producer-props "bootstrap.servers=${BOOTSTRAP_SERVER}" \
      security.protocol=SASL_SSL \
      sasl.mechanism=PLAIN \
      batch.size=16384 \
      linger.ms=500
