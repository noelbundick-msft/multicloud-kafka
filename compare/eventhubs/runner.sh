#!/bin/bash
set -euo pipefail

TEST_SCRIPT=$1

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
BROKERINFO="${SCRIPT_DIR}/.brokerinfo"
TOPIC=$(grep -oP 'TOPIC=\K.*' "${BROKERINFO}")

export KAFKA_OPTS="-Djava.security.auth.login.config=${SCRIPT_DIR}/jaas.conf"

$TEST_SCRIPT "${SCRIPT_DIR}" "${TOPIC}"
