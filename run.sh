#!/bin/bash

set -e

clear 
cd /tmp
rm -rf test-app 
rails test-app -m /Users/tsaleh/code/tsaleh-instant-rails-app/template.rb
./diff.sh
