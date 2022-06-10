#!/bin/bash
set -euo pipefail

"${KAFKA_BIN}/kafka-consumer-perf-test.sh" --print-metrics \
  --bootstrap-server localhost:9092 \
  --messages 1000000 \
  --topic topic1 
