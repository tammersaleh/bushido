#!/bin/bash

set -e

if [ $# == 1 ]; then
  echo "gold vs test-app"
  diff -wB {gold,test-app}/$1 | less
else
  diff -wBrq -x '*.swp' gold test-app | less
fi


