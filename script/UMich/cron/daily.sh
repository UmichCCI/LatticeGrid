#!/bin/bash

# Run the nightly build task.
# Source: customization.txt

# Sample cron line:
# 10 1 * * * adorack /var/www/apps/umich_latticegrid/script/UMich/cron/daily.sh

cd /var/www/apps/umich_latticegrid/

bundle exec rake RAILS_ENV=production nightlyBuild >> log/rake.log
bundle exec rake RAILS_ENV=production db:vacuum

bundle exec rake tmp:cache:clear
bundle exec rake cache:clear
bundle exec rake RAILS_ENV=production cache:populate taskname=abstracts > log/cache.log
bundle exec rake RAILS_ENV=production cache:populate taskname=investigators >> log/cache.log
bundle exec rake RAILS_ENV=production cache:populate taskname=orgs >> log/cache.log
bundle exec rake RAILS_ENV=production cache:populate taskname=investigator_graphs >> log/cache.log
bundle exec rake RAILS_ENV=production cache:populate taskname=org_graphs >> log/cache.log
bundle exec rake RAILS_ENV=production cache:populate taskname=investigator_graphviz >> log/cache.log
bundle exec rake RAILS_ENV=production cache:populate taskname=org_graphviz >> log/cache.log
bundle exec rake RAILS_ENV=production cache:populate taskname=mesh >> log/cache.log
