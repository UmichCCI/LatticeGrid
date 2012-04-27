require 'rubygems'
require "bundler/setup"

require 'oci8'

require './db/cto_oracle_settings'
include Settings  # Defines the USER, PASSWORD, DSN, and TABLE_* constants.

conn = OCI8.new(USER, PASSWORD, DSN)
cur = conn.exec("SELECT * FROM %s.%s" % [TABLE_OWNER, ORG_TABLE_NAME])

hdict = {
	'APPOINT_FLAG' => "0",
	'CENTER_FLAG' => "0",
	'DEPT_ID' => "401000",
	'DIVISION_ID' => :program_code,
	'DV_ABBR' => :program_abbr,
	'DV_NAME' => :program_name,
	'DV_TYPE' => :program_division_name,
	'DV_URL' => "",
	'LABEL_NAME' => :program_name,
	'SEARCH_NAME' => :program_name,
	'CURRENT_STATUS_NAME' => :current_status_name
}

# headers = cur.get_col_names
header_out = ['APPOINT_FLAG', 'CENTER_FLAG', 'DEPT_ID', 'DIVISION_ID', 'DV_ABBR', 'DV_NAME', 'DV_TYPE', 'DV_URL', 'LABEL_NAME', 'SEARCH_NAME', 'CURRENT_STATUS_NAME']

puts header_out.join("\t")

puts "1\t1\t401000\t401010\tUMCCC\tUniversity of Michigan Comprehensive Cancer Center\tClinical\thttp://www.cancer.med.umich.edu/\tUniversity of Michigan Comprehensive Cancer Center\tUniversity of Michigan Comprehensive Cancer Center\tFull"

while row = cur.fetch_hash()
	# puts row.values_at(*header_out).join("\t")
	rowhash = header_out.map do |hkey|
		out_val = hdict[hkey]
		if out_val.is_a? Symbol
			row[out_val.to_s.upcase]
		else
			out_val
		end
	end

	puts rowhash.join("\t")
end

cur.close()
conn.logoff()
