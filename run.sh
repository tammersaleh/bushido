#!/bin/bash

set -e

clear 

rm -f gold/log/*.log
rm -f gold/db/schema.rb

cd /tmp
  rm -rf test-app 
  rails test-app -m /Users/tsaleh/code/tsaleh-instant-rails-app/template.rb
cd -

./diff.sh
