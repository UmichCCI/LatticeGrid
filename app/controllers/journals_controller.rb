class JournalsController < ApplicationController

	def set_high_impact_journals
		# Request method is restricted to post.

		if params[:commit] == "Set High Impact Journals"
			Journal.transaction do
				Journal.update_all(:include_as_high_impact => false)
				Journal.update_all({:include_as_high_impact => true}, {:journal_abbreviation => params[:journal_abbrs]})
			end
		elsif params[:commit] == "Restore Defaults"
			Journal.transaction do
				Journal.update_all(:include_as_high_impact => false)
				Journal.update_all({:include_as_high_impact => true}, {:issn => LatticeGridHelper.high_impact_issns})
			end
		else
			# Being strict about this because checking submit button values isn't too common.
			render :text => "Commit value not supported: #{params[:commit]}", :status => 400, :type => 'text/plain'
			return
		end

		# Displays on the CCSG page, currently.  Need to fix this because of caching.
		cookies[:ccsg_notice] = "High-impact journals successfully updated."

		# Technically, it's possible that someone could go to /journals/high_impact_journals.
		# It will render correctly, and they could set high-impact journals from there.
		# But the real interface is through CCSG.
		# So we'll redirect back there and worry about this if it actually becomes a problem.
		redirect_to '/ccsg'
	end

	def high_impact_journals
		@journals = Journal.find(:all, :order => "journal_abbreviation")

		# TODO: Maybe not even support this request?  It would simplify the code.
		# Leaving it in for now because who knows how the CCSG page will change.
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
