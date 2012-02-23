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

# Assumes that it's been given three files:
# - Latest division_lookup.txt
# - Latest all_members.txt
# - Latest core_members.txt
# 
# These files should be in db/imports/UMich/

trap "echo Quitting; exit" INT

if [ ! -f "db/imports/UMich/division_lookup.txt" ] || [ ! -f "db/imports/UMich/all_members.txt" ] \
	|| [ ! -f "db/imports/UMich/core_members.txt" ]; then
	echo "Did not find the three files we expected to find.  Aborting."
	exit -1
fi

ruby script/UMich/parse_members.rb "db/imports/UMich/all_members.txt" "db/imports/UMich/core_members.txt" "db/imports/UMich/member_output.txt"

bundle exec rake importOrganizations file=db/imports/UMich/division_lookup.txt
bundle exec rake purgeUnupdatedOrganizations
bundle exec rake importInvestigators file=db/imports/UMich/member_output.txt
bundle exec rake cleanup:purgeUnupdatedFaculty
bundle exec rake cleanup:purgeOldMemberships

bundle exec rake --trace insertAllAbstracts
bundle exec rake --trace nightlyBuild
