#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
export KAFKA_BIN="${SCRIPT_DIR}/_kafka/bin"

ACTION=""

help()  {
  cat <<EOF
  Usage: $(basename $0) [-b|--broker broker_configuration]

  Required arguments:
    -b, --broker        The name of a directory relative to this script that contains broker lifecycle scripts

  Optional arguments:
    --action            (Optional) Name of a script to run only that action. Standard actions: [deploy, test, teardown]
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -b|--broker)
      BROKER=$2
      shift # past argument
      shift # past value
      ;;
    --action)
      ACTION=$2
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      echo "Unexpected option: $1"
      help
      exit 1
      ;;
  esac
done

validate_args() {
  # allow vars to go unset here because we're validating their existence/values
  set +u

  if [ -z "${BROKER}" ]; then
    echo "Missing required argument: --broker"
    help
    exit 1
  fi
  BROKER_DIR="${SCRIPT_DIR}/${BROKER}"

  if [ ! -d "${BROKER_DIR}" ]; then
    echo "Invalid broker directory: ${BROKER_DIR}"
    exit 1
  fi

  BROKER_DEPLOY_SCRIPT="${BROKER_DIR}/deploy.sh"
  if [ ! -f "${BROKER_DEPLOY_SCRIPT}" ]; then
    echo "Missing broker deployment script: ${BROKER_DEPLOY_SCRIPT}"
    exit 1
  fi

  BROKER_TEST_SCRIPT="${BROKER_DIR}/test.sh"
  if [ ! -f "${BROKER_TEST_SCRIPT}" ]; then
    echo "Missing broker test script: ${BROKER_TEST_SCRIPT}"
    exit 1
  fi

  BROKER_TEARDOWN_SCRIPT="${BROKER_DIR}/teardown.sh"
  if [ ! -f "${BROKER_TEARDOWN_SCRIPT}" ]; then
    echo "Missing broker teardown script: ${BROKER_TEARDOWN_SCRIPT}"
    exit 1
  fi

  # back to variable safety
  set -u
}

deploy_broker() {
  echo "Deploying broker: ${BROKER}"
  . "${BROKER_DEPLOY_SCRIPT}"
}

run_test() {
  echo "Running a test: ${BROKER}"
  . "${BROKER_TEST_SCRIPT}"
}

teardown_broker() {
  echo "Tearing down: ${BROKER_TEARDOWN_SCRIPT}"
  . "${BROKER_TEARDOWN_SCRIPT}"
}

run_action() {
  ACTION_SCRIPT="${BROKER_DIR}/${ACTION}.sh"
  if [ ! -f "${ACTION_SCRIPT}" ]; then
    echo "Missing broker action script: ${ACTION_SCRIPT}"
    exit 1
  fi

  . "${ACTION_SCRIPT}"
}

validate_args

if [ ! -z "${ACTION}" ]; then
  run_action
else
  deploy_broker
  run_test
  teardown_broker
fi
