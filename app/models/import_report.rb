require 'date'

class ImportReport < ActionMailer::Base
  def report(state)
  	other_vars = {
  		:date => Date.today
  	}

    recipients 'adorack@med.umich.edu'
    subject    "[LatticeGrid] #{Date.today} Investigator Import Results"
    from       "latticegrid@latticegrid.med.umich.edu"
    body       state.merge(other_vars)
  end
end
