#!/bin/bash
set -euo pipefail

export clusterName=$(curl -u admin:$password -sS -G "http://headnodehost:8080/api/v1/clusters" | jq -r '.items[].Clusters.cluster_name')

export KAFKABROKERS=$(curl -sS -u admin:$password -G https://$clusterName.azurehdinsight.net/api/v1/clusters/$clusterName/services/KAFKA/components/KAFKA_BROKER | jq -r '["\(.host_components[].HostRoles.host_name):9092"] | join(",")' | cut -d',' -f1,2);
echo "Brokers: ${KAFKABROKERS}"

KAFKA_BIN="/usr/hdp/current/kafka-broker/bin"

"${KAFKA_BIN}/kafka-producer-perf-test.sh" --print-metrics \
  --topic topic1 \
  --num-records 1000000 \
  --throughput -1 \
  --record-size 1024 \
  --producer-props "bootstrap.servers=${KAFKABROKERS}" \
      batch.size=16384 \
      linger.ms=500
