require "rubygems"
require "bundler/setup"

require 'fastercsv'
require 'set'

if !ARGV[0..2].all?
	$stderr.puts "Usage: all_members core_members output"
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
core_headers, core_members = read_file(ARGV[1])

if all_headers != core_headers
	$stderr.puts "File headers do not match:"
	$stderr.puts all_headers.inspect
	$stderr.puts core_headers.inspect
	exit
end

noncore_members = all_members - core_members

$stderr.puts "#{all_members.length} member(s), #{core_members.length} core member(s), #{noncore_members.length} noncore member(s)."

FasterCSV.open(ARGV[2], "w", :headers => ['member_type'] + all_headers, :col_sep => "\t", :write_headers => true) do |csv|
	{'Core' => core_members, 'NonCore' => noncore_members}.each do |type, set|
		set.each do |row|
			if row['program_num'] == row['home_department_id']
				apt_type = 'Primary'
			else
				apt_type = 'Secondary'
			end

			row['member_type'] = apt_type + type

			csv << row
		end
	end
end
