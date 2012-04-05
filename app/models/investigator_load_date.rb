class InvestigatorLoadDate < ActiveRecord::Base

	class << self
		def latest_update
			ul = InvestigatorLoadDate.find(:first, :order => 'load_date DESC')
			if ul.blank?
				nil
			else
				ul.load_date
			end
		end
	end

end
