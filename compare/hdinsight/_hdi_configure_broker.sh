#!/bin/bash
set -euo pipefail

# adapted from https://docs.microsoft.com/en-us/azure/hdinsight/kafka/apache-kafka-get-started

sudo apt-get update
sudo apt-get install -y jq

export clusterName=$(curl -u admin:$password -sS -G "http://headnodehost:8080/api/v1/clusters" | jq -r '.items[].Clusters.cluster_name')

export KAFKAZKHOSTS=$(curl -sS -u admin:$password -G https://$clusterName.azurehdinsight.net/api/v1/clusters/$clusterName/services/ZOOKEEPER/components/ZOOKEEPER_SERVER | jq -r '["\(.host_components[].HostRoles.host_name):2181"] | join(",")' | cut -d',' -f1,2);
echo "ZK hosts: ${KAFKAZKHOSTS}"

export KAFKABROKERS=$(curl -sS -u admin:$password -G https://$clusterName.azurehdinsight.net/api/v1/clusters/$clusterName/services/KAFKA/components/KAFKA_BROKER | jq -r '["\(.host_components[].HostRoles.host_name):9092"] | join(",")' | cut -d',' -f1,2);
echo "Brokers: ${KAFKABROKERS}"

/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --create --replication-factor 3 --partitions 8 --topic topic1 --zookeeper $KAFKAZKHOSTS --if-not-exists
