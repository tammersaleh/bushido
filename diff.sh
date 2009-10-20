#!/bin/bash

set -e

if [ $# == 1 ]; then
  echo "gold vs tsaleh-test-app"
  diff -wB gold/$1 /tmp/tsaleh-test-app/$1 | less
else
  diff -wBrq -x '*.swp' \
             -x '.git' \
             -x 'hoptoad.rb' \
             -x 'session_store.rb' \
             -x 'database.yml' \
             gold /tmp/tsaleh-test-app | less
fi


