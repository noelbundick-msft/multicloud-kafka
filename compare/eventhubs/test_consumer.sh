#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
BROKERINFO="${SCRIPT_DIR}/.brokerinfo"

export KAFKA_OPTS="-Djava.security.auth.login.config=${SCRIPT_DIR}/jaas.conf"
BOOTSTRAP_SERVER=$(grep -oP 'BOOTSTRAP_SERVER=\K.*' "${BROKERINFO}")
TOPIC=$(grep -oP 'TOPIC=\K.*' "${BROKERINFO}")

cat <<EOF >"${SCRIPT_DIR}/consumer.config"
security.protocol=SASL_SSL
sasl.mechanism=PLAIN
EOF

# TODO: fix messages, my EH has 1 TU
"${KAFKA_BIN}/kafka-consumer-perf-test.sh" --print-metrics \
  --bootstrap-server "${BOOTSTRAP_SERVER}" \
  --consumer.config "${SCRIPT_DIR}/consumer.config" \
  --messages 100 \
  --topic topic1 
