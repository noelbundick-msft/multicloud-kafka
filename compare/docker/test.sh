#!/bin/bash
set -euo pipefail

"${KAFKA_BIN}/kafka-producer-perf-test.sh" --print-metrics \
  --topic topic1 \
  --num-records 1000000 \
  --throughput -1 \
  --record-size 1024 \
  --producer-props bootstrap.servers=localhost:9092 \
      batch.size=16384 \
      linger.ms=500 \
      compression.type=gzip \

