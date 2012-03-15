class JournalsController < ApplicationController

	def set_high_impact
		# Request method is restricted to either get or post.

		if request.method == :post
			Journal.transaction do
				Journal.update_all :include_as_high_impact => false
				Journal.update_all :include_as_high_impact => true, :id => params[:journal_id]
			end
		else
			
		end
	end

end
