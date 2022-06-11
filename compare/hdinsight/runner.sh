#!/bin/bash
set -euo pipefail

TEST_SCRIPT=$1

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
BROKERINFO="${SCRIPT_DIR}/.brokerinfo"

SSH_ENDPOINT=$(grep -oP 'SSH_ENDPOINT=\K.*' "${BROKERINFO}")
PASSWORD=$(grep -oP 'PASSWORD=\K.*' "${BROKERINFO}")

# copy the remote runner
sshpass -p "${PASSWORD}" scp "${SCRIPT_DIR}/_hdi_runner.sh" "azureuser@${SSH_ENDPOINT}:/home/azureuser/_hdi_runner.sh"

# copy .brokerinfo
sshpass -p "${PASSWORD}" scp "${SCRIPT_DIR}/.brokerinfo" "azureuser@${SSH_ENDPOINT}:/home/azureuser/.brokerinfo"

# copy the test
REMOTE_TEST_SCRIPT="/home/azureuser/$(basename ${TEST_SCRIPT})"
sshpass -p "${PASSWORD}" scp "${TEST_SCRIPT}" "azureuser@${SSH_ENDPOINT}:${REMOTE_TEST_SCRIPT}"

# execute the test
sshpass -p "${PASSWORD}" ssh "azureuser@${SSH_ENDPOINT}" "password='${PASSWORD}' ./_hdi_runner.sh ${REMOTE_TEST_SCRIPT}"
