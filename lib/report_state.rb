require 'yaml'
require 'singleton'
require 'date'

class ReportState
	include Singleton
	# This maintains the YAML state file across scraping.
	# Eventually, it's serialized into a hash for processing by the actionmailer.

	STATE_ROOT = 'db/imports/UMich/'

	class << self

		def ensure_write(finalize = false)
			begin
				yield
			rescue
				ReportState.instance.exception $!
				finalize = false  # It didn't actually make it through.
				raise
			ensure
				ReportState.instance.write_state(finalize)
			end
		end

	end

	def initialize
		@content = Hash.new do |h, k|
			case k
			when :new_inv, :del_inv, :pubmed_inv, :pubmed_limit_inv
				h[k] = Array.new
			when :new_papers, :new_valid_papers, :old_valid_papers, :new_invalid_papers, :old_invalid_papers
				h[k] = Hash.new do |h2, k2|
					h2[k2] = 0  # I think I might just be able to use the shorthand, but whatever.
				end
			when :new_aff, :del_aff
				h[k] = Hash.new do |h2, k2|
					h2[k2] = []
				end
			when :usernames, :warnings
				h[k] = {}
			when :ruby_exception, :exception_backtrace
				h[k] = nil
			when :finalized
				h[k] = false
			else
				raise "Unrecognized key: #{k.inspect}."
			end
		end

		if File.exists? state_file
			YAML.load_file(state_file).each_pair do |k, v|
				if v.is_a? Hash
					# Special processing to allow for the nested special hashes.
					# May need to change this if the hash depth increases.
					v.each_pair do |k2, v2|
						@content[k][k2] = v2
					end
				else
					@content[k] = v
				end
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

	def new_affiliation(inv, aff)
		@content[:new_aff][inv] << aff
	end

	def del_affiliation(inv, aff)
		@content[:del_aff][inv] << aff
	end

	def pubmed_changed(inv, old_str, new_str)
		@content[:pubmed_inv] << {
			:inv => inv,
			:old_str => old_str,
			:new_str => new_str,
		}
	end

	def pubmed_limit_changed(inv, old_val, new_val)
		@content[:pubmed_limit_inv] << {
			:inv => inv,
			:old_val => old_val,
			:new_val => new_val,
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
		@content[:warnings][inv] = "Found #{count} paper(s), which seems like too few.  Inserted anyway."
	end

	def excessive_papers(inv, count)
		@content[:warnings][inv] = "Found #{count} papers, which seems excessive.  Inserted none."
	end

	def exception(e)
		@content[:ruby_exception] = e.to_s
		@content[:exception_backtrace] = e.backtrace
	end

	def write_state(finalize = false)
		@content[:finalized] = finalize
		File.open(state_file, 'w') do |f|
			f.write @content.to_yaml
		end
	end

	private

	def state_file
		@statefile ||= STATE_ROOT + 'import_state-%s.yaml' % [Date.today.to_s]
	end

end
