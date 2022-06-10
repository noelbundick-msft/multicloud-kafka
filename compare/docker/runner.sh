#!/bin/bash
set -euo pipefail

TEST_SCRIPT=$1

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

$TEST_SCRIPT "${SCRIPT_DIR}" "topic1"
