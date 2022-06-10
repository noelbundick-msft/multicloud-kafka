#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
cd $SCRIPT_DIR/terraform

terraform init
terraform apply -auto-approve

SSH_ENDPOINT=$(terraform output -json | jq -r .ssh_endpoint.value)

# TODO: configure broker via SSH connection to head node

cat <<EOF > "${SCRIPT_DIR}/.brokerinfo"
SSH_ENDPOINT=${SSH_ENDPOINT}
EOF
