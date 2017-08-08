#!/bin/bash
source bash-spec.sh
set +x

cwd=$(pwd)
provider_pidfile="${cwd}/provider.pid"

function start_service {
  cd ${PROJECT_ROOT}
  node provider/provider.js &
  pid="$!"
  echo $pid > ${provider_pidfile}
  sleep 2s
}

function stop_service {
  pid=$(cat ${provider_pidfile})
  kill ${pid}
  # rm ${provider_pidfile}
}

function run_consumer {
  cd ${PROJECT_ROOT}
  node consumer/consumer.js
}

function run_test_consumer {
  cd ${PROJECT_ROOT}
  output=$(npm run test:consumer)
  echo ${output}
}

function checkout_step {
  cd ${PROJECT_ROOT}
  git checkout "step${1}"
}

function run_server_and_consumer {
  start_service
  output=$(run_consumer)
  stop_service
  echo ${output}
}

describe "step1" "$(
  checkout_step 1

  it "runs consumer/consumer.js successfully" "$(
    output=$(run_server_and_consumer)
    expect "${output}" to_match "validDate"
  )"
)"

describe "step2" "$(
  checkout_step 2

  it "runs consumer/consumer.js successfully" "$(
    output=$(run_server_and_consumer)
    expect "${output}" to_match "date: undefined"
  )"

  it "runs test:consumer successfully" "$(
    output=$(run_test_consumer)
    expect "${output}" to_match "1 passing"
  )"
)"

describe "step3" "$(
  checkout_step 3

  it "runs consumer/consumer.js successfully" "$(
    output=$(run_server_and_consumer)
    expect "${output}" to_match "date: undefined"
  )"

  it "runs test:consumer successfully" "$(
    output=$(run_test_consumer)
    expect "${output}" to_match "1 passing"
  )"
)"
