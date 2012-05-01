#!/bin/bash

# This script is run daily by cron.  It takes care of nightlyBuild, runs monthlyBuild if it needs to, and then does caching.  This way, all the scripts are guaranteed to finish before the next one begins, and caching only happens once when running monthlyBuild.

# Sample crontab entry:
# 10 1 * * * nobody (PATH=/opt/ruby-enterprise-1.8.7-2012.02/bin:$PATH; cd /var/www/apps/umich_latticegrid/ && script/UMich/cron/run_all.sh 2>&1 >> log/cron.log)

# The monthly build task will run on this day (DD format):
mday="07"

# Automatically load investigators on this day (DD format):
iday="06"

# Don't keep going if a command fails.
set -e
set -o pipefail

if [[ `date "+%d"` -eq $iday ]]; then
	echo "Importing investigators..."
	script/UMich/import_investigators_from_db.sh
fi

script/UMich/daily.sh

if [[ `date "+%d"` -eq $mday ]]; then
	echo "Running monthlyBuild..."
	script/UMich/monthly.sh
fi

# The cache script does output the time it starts, but that goes into cache.log not cron.log.
echo "Starting to build cache on $(date)"

script/UMich/cron/cache.sh > log/cache.log

echo "Finished cron jobs on $(date)"