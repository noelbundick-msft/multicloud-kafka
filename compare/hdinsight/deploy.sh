#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
cd $SCRIPT_DIR/terraform

terraform init
terraform apply -auto-approve

SSH_ENDPOINT=$(terraform output -json | jq -r .ssh_endpoint.value)
PASSWORD=$(terraform output -json | jq -r .password.value)

cat <<EOF > "${SCRIPT_DIR}/.brokerinfo"
SSH_ENDPOINT=${SSH_ENDPOINT}
PASSWORD=${PASSWORD}
EOF

# TODO: remove all sshpass and use keys
ssh-keyscan -H "${SSH_ENDPOINT}" >> ~/.ssh/known_hosts

sshpass -p "${PASSWORD}" scp "${SCRIPT_DIR}/_hdi_configure_broker.sh" "azureuser@${SSH_ENDPOINT}:/home/azureuser/_hdi_configure_broker.sh"
sshpass -p "${PASSWORD}" ssh "azureuser@${SSH_ENDPOINT}" password=${PASSWORD} ./_hdi_configure_broker.sh
