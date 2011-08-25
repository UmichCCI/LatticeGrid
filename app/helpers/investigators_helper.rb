module InvestigatorsHelper
#  require 'ldap_utilities' #specific ldap methods
  require 'config' #heading configuration options
  
  def handle_member_name(merge_ldap=true)
    return if params[:id].blank?
    if !params[:format].blank? and (params[:format] !~ /json|xml|pdf|xls|doc/) then #reassemble the username
      params[:id]=params[:id]+"."+params[:format]
    end
    if params[:name].blank? then
      @investigator = Investigator.find_by_username_including_deleted(params[:id])
      if @investigator
        params[:investigator_id] = @investigator.id
        params[:name] =  @investigator.first_name + " " + @investigator.last_name
        merge_investigator_db_and_ldap(@investigator) if ( LatticeGridHelper.ldap_perform_search? and merge_ldap)
      else
        params[:investigator_id]=0
        logger.error("Attempt to access invalid username (netid) #{params[:id]}") 
        flash[:notice] = "Sorry - invalid username <i>#{params[:id]}</i>"
        params.delete(:id)
      end
    end
  end
  
  def merge_investigator_db_and_ldap(investigator)
    return investigator if investigator.blank? or investigator.username.blank?
    begin
      pi_data = GetLDAPentry(investigator.username)
      if pi_data.nil?
        logger.warn("Probable error reaching the LDAP server in GetLDAPentry: GetLDAPentry returned null for #{params[:name]} using netid #{investigator.username}.")
      elsif pi_data.blank?
          logger.warn("Entry not found. GetLDAPentry returned null using netid #{investigator.username}.")
      else
        ldap_rec=CleanPIfromLDAP(pi_data)
        investigator=MergePIrecords(investigator,ldap_rec)
      end
    rescue Exception => error
      logger.error("Probable error reaching the LDAP server in GetLDAPentry: #{error.message}")
    end
  end
  
  def nav_heading()
    out="<span id='nav_links'>"
    if not (controller.action_name == 'show' and controller.controller_name == 'investigators')
      out+= link_to('Publications', show_investigator_url(:id=>params[:id], :page=>1) ) 
      out+= " &nbsp;  &nbsp; " 
    end
    out+= " Publication Graphs: " 
    if not (controller.action_name == 'show_member' and controller.controller_name == 'graphs')
      out+= link_to('Flash', show_member_graph_url(params[:id]) ) 
      out+= " &nbsp;  &nbsp; " 
    end
    if not (controller.action_name == 'show_member' and controller.controller_name == 'graphviz')
      out+= link_to( "Graphviz", show_member_graphviz_url(params[:id]) )
      out+= " &nbsp;  &nbsp; " 
    end
    if not (controller.action_name == 'investigator_wheel' and controller.controller_name == 'graphviz')
      out+= link_to( "Wheel", investigator_wheel_graphviz_url(params[:id]) )
      out+= " &nbsp;  &nbsp; " 
    end
    if not (controller.action_name == 'show' and controller.controller_name == 'cytoscape')
      out+= link_to( "Cytoscape", cytoscape_url(params[:id]))
      out+= " &nbsp;  &nbsp; "  
    end
    out+"</span>"
  end

  def nav_heading2()
    out="<span id='nav_links2'>"
    if defined?(LatticeGridHelper.include_awards?) and LatticeGridHelper.include_awards?() then
      out+= " Award data: " 
	  if not (controller.action_name == 'awards' and controller.controller_name == 'cytoscape')
	    out+= link_to('Graph', awards_cytoscape_url(params[:id]) ) 
	    out+= " &nbsp;  &nbsp; " 
	  end
	  if not (controller.action_name == 'show' and controller.controller_name == 'awards')
	    out+= link_to( "Report", investigator_award_url(params[:id]) )
	    out+= " &nbsp;  &nbsp; " 
	  end
	end
    out+= " MeSH: " 
    if not (controller.action_name == 'show_member_mesh' and controller.controller_name == 'graphviz')
      out+= link_to( "similarities graph", show_member_mesh_graphviz_url(params[:id]))
      out+= " &nbsp;  &nbsp; "  
    end
    out+"</span>"
  end

  def investigator_bio_heading(investigator, all_abstracts=nil)
    out="<table class='borderless' width='100%'><tr><td style='vertical-align: top'>"
    if defined?(investigator) and ! investigator.blank?
      out+="<span id='full_name'>"
      out+=investigator.full_name
      out+="</span>"
    end
    out+=" &nbsp; </td><td>"
    out+= edit_profile_link()
    out+= " &nbsp;  &nbsp; "
    if defined?(all_abstracts) and ! all_abstracts.nil? and all_abstracts.length > 10
      publications_per_year=abstracts_per_year_as_string(all_abstracts)
      out+= "<span class='inlinebarchart' values='#{publications_per_year}' title='publications per year: #{publications_per_year}'>&nbsp;</span>"
      out+= sparkline_barchart_setup()
    end
    out+= "<br/>"
    out+=nav_heading()
    out+= "<br/>"
    out+= nav_heading2()
    out+= "</td></tr></table>"
    
    out
  end
  
end
