#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
cd $SCRIPT_DIR/terraform

terraform init
terraform apply -auto-approve

BOOTSTRAP_SERVER=$(terraform output -json | jq -r .bootstrap_server.value)
TOPIC=$(terraform output -json | jq -r .topic.value)
PASSWORD=$(terraform output -json | jq -r .primary_connection_string.value)

cat <<EOF > "${SCRIPT_DIR}/jaas.conf"
KafkaClient { 
    org.apache.kafka.common.security.plain.PlainLoginModule required username="\$ConnectionString" password="${PASSWORD}";
};
EOF

cat <<EOF > "${SCRIPT_DIR}/.brokerinfo"
BOOTSTRAP_SERVER=${BOOTSTRAP_SERVER}
TOPIC=${TOPIC}
PASSWORD=${PASSWORD}
EOF
