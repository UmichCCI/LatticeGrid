
# rs = YAML.load_file(ARGV[0])
Dir['/Users/Adorack/Documents/CCI/LatticeGrid/2012-05-mailings/production_samples_2/*.yaml'].each do |y|
	rs_yaml = YAML.load_file(y)
	rs = ReportState::Content.new.read_state! rs_yaml
	im = ImportReport.create_report(rs)  # => tmail object for testing
	File.open("/Users/Adorack/Documents/CCI/LatticeGrid/2012-05-mailings/production_samples_2/#{File.basename y}.txt", 'w') do |f|
		f.write im.body
	end
end
