#!/bin/bash

set -e

if [ $# == 1 ]; then
  echo "gold vs test-app"
  diff -wB gold/$1 /tmp/test-app/$1 | less
else
  diff -wBrq -x '*.swp' \
             -x '.git' \
             -x 'hoptoad.rb' \
             -x 'session_store.rb' \
             gold /tmp/test-app | less
fi


