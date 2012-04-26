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

echo "Finished nightly rake task on $(date)"
echo "Starting to build the cache."

script/UMich/cron/cache.sh > log/cache.log

echo "Finished nightly build on $(date)"
