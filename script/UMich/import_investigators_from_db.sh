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

# If you hit Ctrl-C, the script exits as well as the subcommand.
trap "echo Quitting; exit" INT

# If any command fails, the script exits.
set -e
set -o pipefail


echo "Beginning to import orgs and investigators on $(date)"

echo "Backing up the database..."
/usr/pgsql-9.1/bin/pg_dump -U latticegrid umich_latticegrid_development | bzip -9 > db/backup/lg_production-$(date '+%Y-%m-%d').sql.bz2

# Run the DB scripts.  NOTE: This will need to run at a somewhat privileged level.
echo "Pulling organizations..."
ruby script/UMich/get_orgs_from_db.rb > db/imports/UMich/db_organizations.txt

echo "Pulling investigators..."
ruby script/UMich/get_members_from_db.rb > db/imports/UMich/db_members.txt

echo "Running rake tasks..."
set -x

bundle exec rake importOrganizations file=db/imports/UMich/db_organizations.txt
bundle exec rake purgeUnupdatedOrganizations
bundle exec rake importInvestigators file=db/imports/UMich/db_members.txt
bundle exec rake cleanup:purgeUnupdatedFaculty
bundle exec rake cleanup:purgeOldMemberships

bundle exec rake --trace insertAllAbstracts

set +x
# A nightlybuild should probably follow.  Whatever cron script is running this will take care of it.
echo "Done importing things on $(date).  Remember to run nightlyBuild for the full effect."
