#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
cd $SCRIPT_DIR

docker compose up -d

BOOTSTRAP_SERVER="localhost:9092"

while :; do
  echo "waiting for broker to come online"
  sleep 1
  if "${KAFKA_BIN}/kafka-features.sh" --describe --bootstrap-server "${BOOTSTRAP_SERVER}" >/dev/null; then
    break
  fi
done

echo "broker is now available at: localhost:9092"

cat <<EOF >"${SCRIPT_DIR}/broker.config"
bootstrap.servers=${BOOTSTRAP_SERVER}
EOF
