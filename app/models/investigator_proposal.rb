class InvestigatorProposal < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :proposal
  named_scope :by_role, 
    :order => "investigator_proposals.role DESC, proposals.project_start_date DESC", :joins => :proposal
  named_scope :distinct_roles, 
    :order => "role", :select => 'role, count(*) as count', :group => 'role'
  named_scope :pis, 
    :conditions=>"role = 'PD/PI'"
  
end
