#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
BROKERINFO="${SCRIPT_DIR}/.brokerinfo"
TOPIC=$(grep -oP 'TOPIC=\K.*' "${BROKERINFO}")

# adapted from https://docs.microsoft.com/en-us/azure/hdinsight/kafka/apache-kafka-get-started

sudo apt-get update
sudo apt-get install -y jq

export clusterName=$(curl -u admin:${password} -sS -G "http://headnodehost:8080/api/v1/clusters" | jq -r '.items[].Clusters.cluster_name')

export KAFKAZKHOSTS=$(curl -sS -u admin:${password} -G https://${clusterName}.azurehdinsight.net/api/v1/clusters/${clusterName}/services/ZOOKEEPER/components/ZOOKEEPER_SERVER | jq -r '["\(.host_components[].HostRoles.host_name):2181"] | join(",")' | cut -d',' -f1,2);
echo "ZK hosts: ${KAFKAZKHOSTS}"

export KAFKABROKERS=$(curl -sS -u admin:${password} -G https://${clusterName}.azurehdinsight.net/api/v1/clusters/${clusterName}/services/KAFKA/components/KAFKA_BROKER | jq -r '["\(.host_components[].HostRoles.host_name):9092"] | join(",")' | cut -d',' -f1,2);
echo "Brokers: ${KAFKABROKERS}"

export KAFKA_BIN="${SCRIPT_DIR}/_kafka/bin"
if [ ! -d "${KAFKA_BIN}" ]; then
  mkdir -p "${KAFKA_BIN}"
  pushd "${KAFKA_BIN}/../"
  curl -L 'https://dlcdn.apache.org/kafka/3.2.0/kafka_2.13-3.2.0.tgz' -o kafka.tgz
  tar xvf kafka.tgz --strip-components=1
  popd
fi

/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --create --replication-factor 3 --partitions 8 --topic "${TOPIC}" --zookeeper "${KAFKAZKHOSTS}" --if-not-exists
