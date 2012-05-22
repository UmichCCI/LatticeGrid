require 'yaml'
require 'singleton'

class ReportState
	include Singleton
	# This maintains the YAML state file across scraping.
	# Eventually, it's serialized into a hash for processing by the actionmailer.

	STATE_FILE = 'db/imports/UMich/import_state.yml'

	def initialize
		@content = Hash.new do |h, k|
			case k
			when :new_inv, :del_inv, :pubmed_inv
				h[k] = Array.new
			when :new_papers, :new_valid_papers, :old_valid_papers, :new_invalid_papers, :old_invalid_papers
				h[k] = Hash.new do |h2, k2|
					h2[k2] = 0  # I think I might just be able to use the shorthand, but whatever.
				end
			when :warnings
				h[k] = {}
			when :usernames
				h[k] = nil
			else
				raise "Unrecognized key: #{k.inspect}."
			end
		end

		if File.exists? STATE_FILE
			YAML.load_file(STATE_FILE).each_pair do |k, v|
				@content[k] = v
			end
		end
	end

	def investigator_record(inv, firstname, lastname, mi)
		@content[:usernames][inv] = ("%s, %s %s" % [firstname, lastname, mi]).strip
	end

	def new_investigator(inv)
		@content[:new_inv] << inv
	end

	def del_investigator(inv)
		@content[:del_inv] << inv
	end

	def pubmed_changed(inv, old_str, new_str)
		@content[:pubmed_inv] << {
			:inv => inv,
			:old_str => old_str,
			:new_str => new_str,
		}
	end

	def new_paper(inv)
		@content[:new_papers][inv] += 1
	end

	def valid_paper(inv, new_paper)
		if new_paper
			@content[:new_valid_papers][inv] += 1
		else
			@content[:old_valid_papers][inv] += 1
		end
	end

	def invalid_paper(inv, new_paper)
		if new_paper
			@content[:new_invalid_papers][inv] += 1
		else
			@content[:old_invalid_papers][inv] += 1
		end
	end

	def few_papers(inv, count)
		@content[:warnings][inv] = "Found #{count} papers, which seems like too few.  Inserted them anyway."
	end

	def excessive_papers(inv, count)
		@content[:warnings][inv] = "Found #{count} papers, which seems excessive.  Inserted none."
	end

	def write_state
		File.open(STATE_FILE, 'w') do |f|
			f.write @content.to_yaml
		end
	end

end
