#!/bin/bash

# Runs the monthly build task.  This is a very long-running job that updates MESH stuff.
# According to customization.txt, this should be run after nightly build.

# REMEMBER: Set PATH such that `bundle` and `ruby` are both visible.
# On the production server, we use Ruby Enterprise Edition, which installs itself in /opt.

# Sample crontab entry (if you're not using run_all.sh): (Every month on the 3rd at 4:10 AM)
# 10 4 3 * * nobody (PATH=/opt/ruby-enterprise-1.8.7-2012.02/bin:$PATH; cd /var/www/apps/umich_latticegrid/ && script/UMich/cron/monthly.sh 2>&1 >> log/cron.log)

echo "Beginning monthly build on $(date)"

bundle exec rake --trace RAILS_ENV=production monthlyBuild
bundle exec rake RAILS_ENV=production db:vacuum

echo "Finished building mesh on $(date)"
