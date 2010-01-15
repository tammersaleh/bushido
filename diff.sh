#!/bin/bash

set -e

if [ $# == 1 ]; then
  echo "gold vs ${USER}-test-app"
  diff -wB gold/$1 /tmp/${USER}-test-app/$1 | less
else
  diff -wBrq -x '*.swp' \
             -x '.git' \
             -x 'database.yml' \
             gold /tmp/${USER}-test-app | less
fi


