require 'rubygems'
require "bundler/setup"

require 'fastercsv'
require 'oci8'

require './db/cto_oracle_settings'
include Settings  # Defines the USER, PASSWORD, DSN, and TABLE_* constants.

conn = OCI8.new(USER, PASSWORD, DSN)
cur = conn.exec("SELECT * FROM %s.%s" % [TABLE_OWNER, MEMBER_TABLE_NAME])

hmap = {'LAST_NAME' => 'last_name', 'FIRST_NAME' => 'first_name', 'MIDDLE_NAME' => 'middle_name', 'DEGREE' => 'degrees', 'TITLE_NAME' => 'rank', 'DEPARTMENT_NAME' => 'department', 'PROGRAM_CODE' => 'program_num', 'PROGRAM_NAME' => 'program', 'PUBMED_SEARCH_NAME' => 'pubmed_search_name', 'PUBMED_LIMIT_TO_INSTITUTION' => 'pubmed_limit_to_institution', 'EMAIL_ADDRESS' => 'email', 'UNIQNAME' => 'username', 'EMPID' => 'employee_id', 'ASSOCIATION_NAME' => 'assoc_name', 'PRIMARY_PROGRAM_CODE' => 'home_department_id'}

headers = cur.get_col_names  # SOMETHING_PK, LAST_NAME, FIRST_NAME, ...
header_out = headers.select{|h| hmap.has_key? h }  # LAST_NAME, FIRST_NAME, ...
human_headers = header_out.map{|h| hmap[h] }  #  last_name, first_name, ...
file_headers = ['member_type'] + human_headers - ['assoc_name']

FasterCSV($stdout, :headers => file_headers, :col_sep => "\t", :write_headers => true) do |csv|
	while dbrow = cur.fetch_hash()

		row = Hash[*human_headers.zip(dbrow.values_at(*header_out)).flatten]

		if row['program_num'] == row['home_department_id']
			apt_type = 'Primary'
		else
			apt_type = 'Secondary'
		end

		if row['assoc_name'] == 'Member'
			apt_name = 'NonCore'
		elsif row['assoc_name'] = 'Core Member'
			apt_name = 'Core'
		else
			raise "Invalid association name: #{row['assoc_name']}."
		end

		row['member_type'] = apt_type + apt_name

		# Not strictly necessary to delete this, but it's unnecessary.
		row.delete('assoc_name')

		csv << row
	end
end

cur.close()
conn.logoff()
