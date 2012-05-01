#!/bin/bash

# Run the nightly build task.  This file is best called from run_all.sh.
# Source: customization.txt

# REMEMBER: Set PATH such that `bundle` and `ruby` are both visible.
# On the production server, we use Ruby Enterprise Edition, which installs itself in /opt.

# Sample crontab entry (if you're not using run_all.sh):
# 10 1 * * * nobody (PATH=/opt/ruby-enterprise-1.8.7-2012.02/bin:$PATH; cd /var/www/apps/umich_latticegrid/ && script/UMich/cron/daily.sh 2>&1 >> log/cron.log)

# NOTE: If you run this file independently, you'll need to also call the cache script.

echo "Beginning nightly build on $(date)"

bundle exec rake --trace RAILS_ENV=production nightlyBuild
bundle exec rake RAILS_ENV=production db:vacuum

echo "Finished nightly rake task on $(date)"
