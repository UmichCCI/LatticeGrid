class JournalsController < ApplicationController

	def set_high_impact_journals
		# Request method is restricted to post.

		Journal.transaction do
			Journal.update_all(:include_as_high_impact => false)
			Journal.update_all({:include_as_high_impact => true}, {:journal_abbreviation => params[:journal_abbrs]})
		end

		# Technically, it's possible that someone could go to /journals/high_impact_journals.
		# It will render correctly, and they could set high-impact journals from there.
		# But the real interface is through CCSG.
		# So we'll redirect back there and worry about this if it actually becomes a problem.
		flash[:ccsg_notice] = "High-impact journals successfully updated."
		redirect_to '/ccsg'

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
