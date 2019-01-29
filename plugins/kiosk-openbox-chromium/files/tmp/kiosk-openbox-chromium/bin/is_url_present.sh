#!/bin/bash

url="$1"

status=$( curl -o /dev/null --silent --head --write-out '%{http_code}' "${url}" )

if [ "${status}" -eq  "200" ] ; then
    exit 0
fi

exit 1

