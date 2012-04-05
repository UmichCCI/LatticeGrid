#!/bin/bash

# Runs the monthly build task.  This is a very long-running job that updates MESH stuff.
# According to customization.txt, this should be run after nightly build.

# Sample cron line: (Every month on the 3rd)
# 10 3 3 * * adorack /var/www/apps/umich_latticegrid/script/UMich/cron/monthly.sh

cd /var/www/apps/umich_latticegrid/

bundle exec rake RAILS_ENV=production monthlyBuild >> log/monthly_rake.log
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
