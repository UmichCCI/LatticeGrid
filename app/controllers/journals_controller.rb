class JournalsController < ApplicationController

	def set_high_impact_journals
		# Request method is restricted to post.

		if request.method == :post

			render :text => Journal.find(:all, :conditions => {:id => params[:journal_ids]}).map(&:journal_abbreviation).join("\n"), :content_type => 'text/plain'
			return

			Journal.transaction do
				Journal.update_all :include_as_high_impact => false
				Journal.update_all :include_as_high_impact => true, :id => params[:journal_id]
			end
		else
			# The CCSG page includes this page and 
		end
	end

	def high_impact_journals
		@journals = Journal.find(:all, :order => "journal_abbreviation")

		if not request.xhr?
			@javascripts_add = ['jquery.min', 'jquery.dualListBox-1.3']
			@configure_boxes = true
			layout = true
		else
			layout = false
		end

		render :layout => layout
	end

end
