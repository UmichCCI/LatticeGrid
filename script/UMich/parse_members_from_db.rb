require "rubygems"
require "bundler/setup"

require 'fastercsv'
require 'set'

if ARGV.empty? || !ARGV[0..1].all?
	$stderr.puts "Usage: all_members output"
	$stderr.puts
	$stderr.puts "This file parses a record dumped from the database view.  It has a member_type column, but we need to adjust the values and identify the primary department."
	exit
end


def read_file(name)
	returnval = Set.new
	headers = nil

	FasterCSV.foreach(name, :col_sep => "\t", :headers => true) do |row|
		headers ||= row.headers
		returnval.add(row.to_hash)
	end

	[headers, returnval]
end

all_headers, all_members = read_file(ARGV[0])

FasterCSV.open(ARGV[1], "w", :headers => ['member_type'] + all_headers, :col_sep => "\t", :write_headers => true) do |csv|
	all_members.each do |row|
		if row['program_num'] == row['home_department_id']
			apt_type = 'Primary'
		else
			apt_type = 'Secondary'
		end

		if row['assoc_name'] == 'Member'
			apt_name = 'AssociateMember'
		elsif row['assoc_name'] = 'Core Member'
			apt_name = 'Member'
		else
			raise "Invalid association name: #{row['assoc_name']}."
		end

		row['member_type'] = apt_type + apt_name

		csv << row
	end
end
