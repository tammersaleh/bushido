#!/bin/bash

set -e

clear 

rm gold/log/*.log
rm gold/db/schema.rb

cd /tmp
  rm -rf test-app 
  rails test-app -m /Users/tsaleh/code/tsaleh-instant-rails-app/template.rb
cd -

./diff.sh
