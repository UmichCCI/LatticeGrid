#!/usr/bin/ksh
IMPORTDIRECTORY=/var/www/apps/umich_latticegrid/db/imports/UMich
WORKINGDIRECTORY=/var/www/apps/umich_latticegrid/script/UMich
LOGDIR=/var/www/apps/umich_latticegrid/log

if [[ $# -eq 0 ]];then
print "No Arguments passed, please sent the file name"
exit
fi

mv $LOGDIR/buildCache.txt $LOGDIR/buildCache_`date '+%d-%h-%Y:%H-%M'`.txt
mv $LOGDIR/rakelog.log $LOGDIR/rake_`date '+%d-%h-%Y:%H-%M'`.log
incomingfile=$1
echo  $IMPORTDIRECTORY/$incomingfile
#cleanup the sql file
rm $WORKINGDIRECTORY/updateHomeDept.sql
echo "*******************IMPORT INVESTIGATORS**************"
rake RAILS_ENV=production importInvestigators file=$IMPORTDIRECTORY/$incomingfile >> $LOGDIR/rakelog.log

awk -F "\t" '{print $13,$14;}' $IMPORTDIRECTORY/$incomingfile | while read empid prognum; do echo "update investigators set home_department_id = (select id from organizational_units where division_id = $prognum ) where employee_id = $empid; " >>updateHomeDept.sql ; done

#psql -U latticegrid -d umich_latticegrid_development -f $WORKINGDIRECTORY/updateHomeDept.sql 
echo "*************STARTING INSERTALLABSTRACTS********************"
#rake RAILS_ENV=production insertAllAbstracts >>$LOGDIR/rakelog.log
echo "*************STARTING NIGHTLYBUILD********************"
#rake RAILS_ENV=production nightlyBuild >>$LOGDIR/rakelog.log

echo "*************CLEAN DB********************"
#clean up the database to keep queries running smoothly
#vacuumdb -fz umich_latticegrid_development -U latticegrid

echo "*************CLEARING CACHE********************"
#rake RAILS_ENV=production cache:clear >> $LOGDIR/rakelog.log
echo "*************BUILDING CACHE********************"


#rebuild the application cache
#rake RAILS_ENV=production cache:populate taskname=abstracts > $LOGDIR/buildCache.txt
#rake RAILS_ENV=production cache:populate taskname=investigators >> $LOGDIR/buildCache.txt
#rake RAILS_ENV=production cache:populate taskname=orgs >> $LOGDIR/buildCache.txt
#rake RAILS_ENV=production cache:populate taskname=investigator_graphs >> $LOGDIR/buildCache.txt
#rake RAILS_ENV=production cache:populate taskname=org_graphs >> $LOGDIR/buildCache.txt
#rake RAILS_ENV=production cache:populate taskname=investigator_graphviz >> $LOGDIR/buildCache.txt
#rake RAILS_ENV=production cache:populate taskname=org_graphviz >> buildCache.txt


echo "*************RESTARTING HTTPD********************"
#service httpd restart
