#!/bin/bash

# Common script for the caching.
# Generally run as `script/UMich/cron/cache.sh > log/cache.log

echo "Starting to build the cache on $(date)."

bundle exec rake tmp:cache:clear
bundle exec rake cache:clear
bundle exec rake RAILS_ENV=production cache:populate taskname=abstracts
bundle exec rake RAILS_ENV=production cache:populate taskname=investigators
bundle exec rake RAILS_ENV=production cache:populate taskname=orgs
bundle exec rake RAILS_ENV=production cache:populate taskname=investigator_graphs
bundle exec rake RAILS_ENV=production cache:populate taskname=org_graphs
bundle exec rake RAILS_ENV=production cache:populate taskname=investigator_graphviz
bundle exec rake RAILS_ENV=production cache:populate taskname=org_graphviz
bundle exec rake RAILS_ENV=production cache:populate taskname=mesh

echo "Done building the cache on $(date)."
