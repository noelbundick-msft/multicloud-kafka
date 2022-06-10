#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
BROKERINFO="${SCRIPT_DIR}/.brokerinfo"

# TODO: SSH to head node and run tests
exit 1
