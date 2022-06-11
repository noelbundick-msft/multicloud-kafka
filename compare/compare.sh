#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
LOG="${SCRIPT_DIR}/output.log"

export KAFKA_BIN="${SCRIPT_DIR}/_kafka/bin"
if [ ! -d "${KAFKA_BIN}" ]; then
  mkdir -p "${KAFKA_BIN}"
  pushd "${KAFKA_BIN}/../"
  curl -L 'https://dlcdn.apache.org/kafka/3.2.0/kafka_2.13-3.2.0.tgz' -o kafka.tgz
  tar xvf kafka.tgz --strip-components=1
  popd
fi

ACTION=""
TEST="default"

help()  {
  cat <<EOF
  Usage: $(basename $0) [-b|--broker broker_configuration]

  Required arguments:
    -b, --broker        The name of a directory relative to this script that contains broker lifecycle scripts

  Optional arguments:
    --action            (Optional) Name of a script to run only that action. Standard actions: [deploy, test, teardown]
    --test              (Optional) Name of a specific test case to run. Implies --action=test
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
    -t|--test)
      TEST=$2
      if [ "${ACTION}" = "" ]; then
        ACTION="test"
      elif [ "${ACTION}" != "test" ]; then
        echo "You can't specify --test with an --action != 'test'"
        exit 1
      fi
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

  BROKER_TEST_RUNNER_SCRIPT="${BROKER_DIR}/runner.sh"
  if [ ! -f "${BROKER_TEST_RUNNER_SCRIPT}" ]; then
    echo "Missing broker test runner script: ${BROKER_TEST_RUNNER_SCRIPT}"
    exit 1
  fi

  TEST_SCRIPT="${SCRIPT_DIR}/_tests/${TEST}.sh"
  if [ ! -f "${TEST_SCRIPT}" ]; then
    echo "Missing test script: ${TEST_SCRIPT}"
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
  . "${BROKER_DEPLOY_SCRIPT}" | tee -a "${LOG}"
}

run_test() {
  echo "Running a test: ${BROKER}"
  . "${BROKER_TEST_RUNNER_SCRIPT}" "${TEST_SCRIPT}" | tee -a "${LOG}"
}

teardown_broker() {
  echo "Tearing down: ${BROKER_TEARDOWN_SCRIPT}"
  . "${BROKER_TEARDOWN_SCRIPT}" | tee -a "${LOG}"
}

run_action() {
  if [ "${ACTION}" == "test" ]; then
    run_test
  else
    ACTION_SCRIPT="${BROKER_DIR}/${ACTION}.sh"
    if [ ! -f "${ACTION_SCRIPT}" ]; then
      echo "Missing broker action script: ${ACTION_SCRIPT}"
      exit 1
    fi

    . "${ACTION_SCRIPT}" | tee -a "${LOG}"
  fi
}

validate_args

# clear old logs
rm "${LOG}"

if [ ! -z "${ACTION}" ]; then
  run_action
else
  deploy_broker
  run_test
  teardown_broker
fi
