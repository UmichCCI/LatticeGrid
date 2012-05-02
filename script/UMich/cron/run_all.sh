#!/bin/bash

# This script is run daily by cron.  It takes care of nightlyBuild, runs monthlyBuild if it needs to, and then does caching.  This way, all the scripts are guaranteed to finish before the next one begins, and caching only happens once when running monthlyBuild.

# This script shouldn't be run by root--it's owned by a normal user.  However, the cache script should only run after everything here finishes.  This makes the crontab entry complicated:
# 10 1 * * * root (cd /var/www/apps/umich_latticegrid/ && su --shell=/bin/bash --session-command='env PATH=/opt/ruby-enterprise-1.8.7-2012.02/bin/:$PATH script/UMich/cron/run_all.sh' adorack 2>&1 >> log/cron.log && su --shell=/bin/bash --session-command='env PATH=/opt/ruby-enterprise-1.8.7-2012.02/bin/:$PATH script/UMich/cron/cache.sh' nobody 2>&1 > log/cache.log)

# In contrast, say the cache directories didn't need to be owned by "nobody".  Then, can just run this script directly as a normal user:
# 10 1 * * * adorack (PATH=/opt/ruby-enterprise-1.8.7-2012.02/bin:$PATH; cd /var/www/apps/umich_latticegrid/ && script/UMich/cron/run_all.sh 2>&1 >> log/cron.log)

# The monthly build task will run on this day (DD format):
mday="07"

# Automatically load investigators on this day (DD format):
iday="06"

# Don't keep going if a command fails.
set -e
set -o pipefail

if [[ `date "+%d"` -eq $iday ]]; then
	echo "Importing investigators on $(date)"
	script/UMich/import_investigators_from_db.sh 2>&1 >> log/import_investigators.log
fi

echo "Running daily script on $(date)"
script/UMich/cron/daily.sh 2>&1 > log/rake.log

if [[ `date "+%d"` -eq $mday ]]; then
	echo "Running monthlyBuild on $(date)"
	script/UMich/cron/monthly.sh 2>&1 > log/monthly_rake.log
fi

# Cron will run the cache script next as a different user.
echo "Main tasks finished on $(date).  Cache build is next."

# If you were running this script as root and wanted to run the cache, here's what you'd do:
# su --shell=/bin/bash --session-command='env PATH=/opt/ruby-enterprise-1.8.7-2012.02/bin/:$PATH script/UMich/cron/cache.sh' nobody 2>&1 > log/cache.log
