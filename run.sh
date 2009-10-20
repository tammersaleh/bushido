#!/bin/bash

set -e

clear 

rm -f gold/log/*.log
rm -f gold/db/schema.rb

cd /tmp
  if (heroku list | grep -x tsaleh-test-app-staging); then
    heroku destroy --app tsaleh-test-app-staging
  fi
  rm -rf tsaleh-test-app 
  rails tsaleh-test-app -m /Users/tsaleh/code/tsaleh-instant-rails-app/template.rb
cd -

./diff.sh
