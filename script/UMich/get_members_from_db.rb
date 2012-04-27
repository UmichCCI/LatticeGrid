require 'rubygems'
require "bundler/setup"

require 'oci8'

require './db/cto_oracle_settings'
include Settings  # Defines the USER, PASSWORD, DSN, and TABLE_* constants.

conn = OCI8.new(USER, PASSWORD, DSN)
cur = conn.exec("SELECT * FROM %s.%s" % [TABLE_OWNER, MEMBER_TABLE_NAME])

hdict = {'LAST_NAME' => 'last_name', 'FIRST_NAME' => 'first_name', 'MIDDLE_NAME' => 'middle_name', 'DEGREE' => 'degrees', 'TITLE_NAME' => 'rank', 'DEPARTMENT_NAME' => 'department', 'PROGRAM_CODE' => 'program_num', 'PROGRAM_NAME' => 'program', 'PUBMED_SEARCH_NAME' => 'pubmed_search_name', 'PUBMED_LIMIT_TO_INSTITUTION' => 'pubmed_limit_to_institution', 'EMAIL_ADDRESS' => 'email', 'UNIQNAME' => 'username', 'EMPID' => 'employee_id', 'ASSOCIATION_NAME' => 'assoc_name', 'PRIMARY_PROGRAM_CODE' => 'home_department_id'}

headers = cur.get_col_names
header_out = headers.select{|h| hdict.has_key? h }

puts header_out.map{|h| hdict[h] }.join("\t")

while row = cur.fetch_hash()
	puts row.values_at(*header_out).join("\t")
end

cur.close()
conn.logoff()
