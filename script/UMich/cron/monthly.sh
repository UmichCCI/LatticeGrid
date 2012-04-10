#!/bin/bash

# Runs the monthly build task.  This is a very long-running job that updates MESH stuff.
# According to customization.txt, this should be run after nightly build.

# REMEMBER: Set PATH such that `bundle` and `ruby` are both visible.
# On the production server, we use Ruby Enterprise Edition, which installs itself in /opt.

# Sample cron line: (Every month on the 3rd)
# 10 3 3 * * adorack (PATH=/usr/local/bin:$PATH; cd /var/www/apps/umich_latticegrid/ && script/UMich/cron/monthly.sh 2>&1 >> log/cron.log)

echo "Beginning monthly build on $(date)"

bundle exec rake RAILS_ENV=production monthlyBuild >> log/monthly_rake.log
bundle exec rake RAILS_ENV=production db:vacuum

echo "Finished building mesh on $(date)"

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

echo "Finished monthly build on $(date)"
