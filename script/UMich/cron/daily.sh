#!/bin/bash

# Run the nightly build task.
# Source: customization.txt

# REMEMBER: Set PATH such that `bundle` and `ruby` are both visible.
# On the production server, we use Ruby Enterprise Edition, which installs itself in /opt.

# Sample crontab entry:
# 10 1 * * * nobody (PATH=/opt/ruby-enterprise-1.8.7-2012.02/bin:$PATH; cd /var/www/apps/umich_latticegrid/ && script/UMich/cron/daily.sh 2>&1 >> log/cron.log)

echo "Beginning nightly build on $(date)"

bundle exec rake RAILS_ENV=production nightlyBuild 2>&1 >> log/rake.log
bundle exec rake RAILS_ENV=production db:vacuum

echo "Building cache on $(date)"

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

echo "Finished nightly build on $(date)"
