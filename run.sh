#!/bin/bash

set -e

clear 
rm -rf test-app 
rails test-app -m /Users/tsaleh/code/tsaleh-rails-templates/instantapp.rb 
./diff.sh
