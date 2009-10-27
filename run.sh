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
  rails tsaleh-test-app \
        -m /Users/tsaleh/code/tsaleh-bushido/template.rb \
        -- \
        --hoptoad_key=HOPTOAD_KEY \
        --gmail_username=GMAIL_USERNAME \
        --gmail_password=GMAIL_PASSWORD \
        --s3_key=S3_KEY \
        --s3_secret=S3_SECRET
cd -

./diff.sh
