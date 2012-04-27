#!/bin/bash

# Import investigators and organizations.

# - Backup db
# - Import organizations
# - Import investigators
# - Clean investigators and appointments
# - insertAllAbstracts
# - clear cache
# - rebuild cache
# - restart servers
# - backup db

trap "echo Quitting; exit" INT

echo "Beginning to import orgs and investigators on $(date)"

# Run the DB scripts.  NOTE: This will need to run at a somewhat privileged level.
ruby script/UMich/get_orgs_from_db.rb > db/imports/UMich/db_organizations.txt

if [[ $? -ne 0 ]]; then
	echo "Pulling orgs from the database was unsuccessful.  Exiting."
	exit -1
fi

ruby script/UMich/get_members_from_db.rb > db/imports/UMich/db_members.txt

if [[ $? -ne 0 ]]; then
	echo "Pulling members from the database was unsuccessful.  Exiting."
	exit -1
fi

bundle exec rake importOrganizations file=db/imports/UMich/db_organizations.txt
bundle exec rake purgeUnupdatedOrganizations
bundle exec rake importInvestigators file=db/imports/UMich/db_members.txt
bundle exec rake cleanup:purgeUnupdatedFaculty
bundle exec rake cleanup:purgeOldMemberships

bundle exec rake --trace insertAllAbstracts

# A nightlybuild should probably follow.  Whatever cron script is running this will take care of it.
echo "Done importing things on $(date).  Remember to run nightlyBuild for the full effect."
