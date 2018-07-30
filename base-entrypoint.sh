#!/bin/bash

echo "executing base-entryppint.sh"

function waitForService() {

    local servicePort=$1
    local service=${servicePort%%:*}
    local port=${servicePort#*:}
    local retrySeconds=5
    local max_try=100
    let i=1

    nc -z ${service} ${port}
    result=$?

    until [ ${result} -eq 0 ]; do

      echo "[$i/$max_try] ${service}:${port} is not available yet"

      if (( $i == $max_try )); then
        echo "[$i/$max_try] ${service}:${port} is still not available; giving up after ${max_try} tries. :/"
        exit 1
      fi

      let "i++"
      sleep ${retrySeconds}

      nc -z ${service} ${port}
      result=$?
    done

    echo "[$i/$max_try] $service:${port} is available."
}

for i in ${SERVICE_PRECONDITION[@]}
do
    waitForService ${i}
done

exec $@
