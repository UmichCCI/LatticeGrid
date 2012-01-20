#!/bin/ksh
# UNIX shell script. written Warren Kibbe, 2009
LOGDIR=/var/www/apps/umich_latticegrid/log

#clean up the database to keep queries running smoothly
vacuumdb -fz umich_latticegrid_development -U latticegrid

mv $LOGDIR/buildCache.txt $LOGDIR/buildCache_`date '+%d-%h-%Y:%H-%M'`.txt
#rebuild the application cache
rake RAILS_ENV=production tmp:cache:clear 
rake RAILS_ENV=production cache:clear
rake RAILS_ENV=production cache:populate taskname=abstracts > $LOGDIR/buildCache.txt
rake RAILS_ENV=production cache:populate taskname=investigators >> $LOGDIR/buildCache.txt
rake RAILS_ENV=production cache:populate taskname=orgs >> $LOGDIR/buildCache.txt
rake RAILS_ENV=production cache:populate taskname=investigator_graphs >> $LOGDIR/buildCache.txt
rake RAILS_ENV=production cache:populate taskname=org_graphs >> $LOGDIR/buildCache.txt
rake RAILS_ENV=production cache:populate taskname=investigator_graphviz >> $LOGDIR/buildCache.txt
rake RAILS_ENV=production cache:populate taskname=org_graphviz >> buildCache.txt

# in development

rake tmp:cache:clear 
rake cache:clear
rake cache:populate taskname=abstracts > buildCache.txt
rake cache:populate taskname=investigators >> buildCache.txt
rake cache:populate taskname=orgs >> buildCache.txt
rake cache:populate taskname=investigator_graphs >> buildCache.txt
rake cache:populate taskname=org_graphs >> buildCache.txt
rake cache:populate taskname=investigator_graphviz >> buildCache.txt
rake cache:populate taskname=org_graphviz >> buildCache.txt
