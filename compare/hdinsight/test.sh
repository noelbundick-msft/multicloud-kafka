#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
BROKERINFO="${SCRIPT_DIR}/.brokerinfo"

SSH_ENDPOINT=$(grep -oP 'SSH_ENDPOINT=\K.*' "${BROKERINFO}")
PASSWORD=$(grep -oP 'PASSWORD=\K.*' "${BROKERINFO}")

sshpass -p "${PASSWORD}" scp "${SCRIPT_DIR}/_hdi_test.sh" "azureuser@${SSH_ENDPOINT}:/home/azureuser/_hdi_test.sh"
sshpass -p "${PASSWORD}" ssh "azureuser@${SSH_ENDPOINT}" password=${PASSWORD} ./_hdi_test.sh
