require 'graph_generator'
def generate_cytoscape_schema()
{
    :nodes => [{:name => "label", :type => "string"}, {:name => "tooltiptext", :type => "string"}, {:name => "weight", :type => "number"}, {:name => "depth", :type => "number"} ],
    :edges => [{:name => "label", :type => "string"}, {:name => "tooltiptext", :type => "string"}, {:name => "weight", :type => "number"}, {:name => "directed", :type => "boolean", :defValue => true} ]
}
end

def generate_cytoscape_data(investigator, max_depth)
  node_array_hash = generate_cytoscape_nodes(investigator, max_depth)
{
    :nodes => node_array_hash,
    :edges => generate_cytoscape_edges(investigator, max_depth, node_array_hash)
}
end

def generate_cytoscape_nodes(investigator, max_depth, node_array=[], depth=0)
  #         nodes: [ { id: "n1", label: "Node 1", score: 1.0 },
  #                  { id: "n2", label: "Node 2", score: 2.2 },
  #                  { id: "n3", label: "Node 3", score: 3.5 } ]
  max_weight=max_colleague_pubs(investigator)
  node_array << cytoscape_investigator_node_hash(investigator, max_weight+10, depth ) unless cytoscape_array_has_key?(node_array, investigator.id)
  depth +=1
  investigator.co_authors.each { |connection| 
    node_array << cytoscape_investigator_node_hash(connection.colleague, connection.colleague.total_pubs, depth) unless cytoscape_array_has_key?(node_array, connection.colleague_id)
  }
  if max_depth > depth
    investigator.co_authors.each { |connection| 
      node_array = generate_cytoscape_nodes(connection.colleague, max_depth, node_array, depth)
    }
  end
  node_array
end

def max_colleague_pubs(investigator)
  max_pubs = investigator.total_pubs
  investigator.co_authors.each { |connection| 
    max_pubs = connection.colleague.total_pubs if connection.colleague.total_pubs > max_pubs
  }
  max_pubs
end

def cytoscape_investigator_node_hash(investigator, weight=10, depth=1,investigator_awards=nil)
 {
   :id => investigator.id.to_s,
   :label => investigator.name,
   :weight => weight,
   :depth => depth,
   :tooltiptext => investigator_tooltip(investigator, depth, investigator_awards)
 }
end

def investigator_tooltip(investigator, depth, investigator_awards=nil)
    "Publications: #{investigator.total_pubs}; <br/>" + 
    "First author pubs: #{investigator.num_first_pubs}; <br/>" +
    "Last author pubs: #{investigator.num_last_pubs}; <br/>" +
    "intra-unit collab: #{investigator.num_intraunit_collaborators}; <br/>" +
    "inter-unit collabs: #{investigator.num_extraunit_collaborators}; <br/>" +
    "NetID: #{investigator.username}; <br/>" +
    (investigator_awards.blank? ? "" : "PI awards: $#{award_info(investigator_awards,'pd/pi')}; <br/>") +
    (investigator_awards.blank? ? "" : "All awards: $#{award_info(investigator_awards)}; <br/>") +
    ((investigator.home_department.blank?) ? "" : "primary appointment: #{investigator.home_department.name}; <br/>") + 
    ((investigator.memberships.blank?) ? "" : "memberships: #{investigator.memberships.collect(&:name).join(', <br/>&nbsp; &nbsp; &nbsp; &nbsp; ')}")
end


def generate_cytoscape_edges(investigator, depth, nodes_array_hash, edge_array=[], include_intra_node_connections=false)
  #         edges: [ { id: "e1", label: "Edge 1", weight: 1.1, source: "n1", target: "n3" },
  #                  { id: "e2", label: "Edge 2", weight: 3.3, source:"n2", target:"n1"} ]
  investigator_index = investigator.id.to_s
  investigator.co_authors.each { |connection| 
    colleague_index = connection.colleague_id.to_s
    if colleague_index and ! cytoscape_edge_array_has_key?(edge_array, colleague_index, investigator_index)
      tooltiptext=investigator_colleague_edge_tooltip(connection,investigator,connection.colleague)
      edge_array << cytoscape_edge_hash(edge_array.length, investigator_index, colleague_index, connection.publication_cnt.to_s, connection.publication_cnt, tooltiptext)
      # go one more layer down to add all the intermediate edges
      if include_intra_node_connections
        connection.colleague.co_authors.each { |cc|
          cc_index = cc.colleague_id.to_s
          if cc_index and cytoscape_array_has_key?(nodes_array_hash, cc_index) and ! cytoscape_edge_array_has_key?(edge_array, colleague_index, cc_index)
            tooltiptext=investigator_colleague_edge_tooltip(cc,connection.colleague,cc.colleague)
            edge_array << cytoscape_edge_hash(edge_array.length, colleague_index, cc_index, cc.publication_cnt.to_s, cc.publication_cnt, tooltiptext)
          end
        }
      end
    end
    if (depth > 1)
      edge_array = generate_cytoscape_edges(connection.colleague, (depth-1), nodes_array_hash, edge_array, include_intra_node_connections)
    end
  }
  edge_array
end

 def cytoscape_edge_hash(edge_index, source_index, target_index, label="edge", value=1, tooltiptext="")
   {
     :id => edge_index.to_s,
     :label => "#{label}",
     :tooltiptext => tooltiptext,
     :source => source_index,
     :target => target_index,
     :weight  => value
   }
 end

 def investigator_colleague_edge_tooltip(connection, root, leaf)
   "#{connection.publication_cnt} shared publications between #{leaf.name} and #{root.name};<br/> " + 
   "MeSH similarity score: #{connection.mesh_tags_ic.round};" + " "
   #"<br/> tags: "+ trunc_and_join_array(root.tag_list & leaf.tag_list, 16, ", ", 4)
 end

def cytoscape_array_has_key?(head_array, key)
  head_array.each { |element|
    return true if element[:id].to_s == key.to_s
  }
  return false
end

def cytoscape_edge_array_has_key?(edge_array, idx1, idx2)
  edge_array.each { |element|
    return true if element[:source] == idx1 and element[:target] == idx2
    return true if element[:source] == idx2 and element[:target] == idx1
  }
  return false
end

def generate_cytoscape_award_data(investigator, max_depth)
    node_array_hash = generate_cytoscape_award_nodes(investigator, max_depth)
  {
      :nodes => node_array_hash,
      :edges => generate_cytoscape_award_edges(investigator, max_depth, node_array_hash)
  }
end

def cytoscape_award_node_hash(award, weight=10, depth=1)
 {
   :id => "A_#{award.id}",
   :label => award.institution_award_number,
   :weight => award_weight(weight),
   :depth => depth,
   :tooltiptext => award_tooltip(award, depth)
 }
end

def award_tooltip(award, depth)
  "Title: #{award.title}; <br/>" + 
  "OR Award number: #{award.institution_award_number}; <br/>" + 
  "Award number: #{award.sponsor_award_number}; <br/>" + 
  "Award start: #{award.award_start_date.to_s}; <br/>" + 
  "Award end: #{award.award_end_date.to_s}; <br/>" + 
  "Project start: #{award.project_start_date.to_s}; <br/>" + 
  "Project end: #{award.project_end_date.to_s}; <br/>" + 
  "Amount: #{number_to_humanized(award.total_amount)}; <br/>" +
    "Sponsor: #{award.sponsor_name}; <br/>" +
    "Sponsor type: #{award.sponsor_type_name}; <br/>" +
    ((award.investigator_proposals.blank?) ? "" : "Collaborators: #{award.investigator_proposals.length}; <br/>" )
end


def generate_cytoscape_award_nodes(investigator, max_depth, node_array=[], depth=0)
  #         nodes: [ { id: "n1", label: "Node 1", score: 1.0 },
  #                  { id: "n2", label: "Node 2", score: 2.2 },
  #                  { id: "n3", label: "Node 3", score: 3.5 } ]
  node_array << cytoscape_investigator_node_hash(investigator, 75, depth, investigator.investigator_proposals ) unless cytoscape_array_has_key?(node_array, investigator.id)
  depth +=1
  investigator.proposals.each { |award| 
    node_array << cytoscape_award_node_hash(award, award.total_amount, depth) unless cytoscape_array_has_key?(node_array, "A_#{award.id}")
    award.investigators.each { |award_investigator|
      node_array << cytoscape_investigator_node_hash(award_investigator, 55, depth, award_investigator.investigator_proposals ) unless cytoscape_array_has_key?(node_array, award_investigator.id)
    }
  }
  if max_depth > depth
    investigator.proposals.each { |award| 
      award.investigators.each { |award_investigator|
        node_array = generate_cytoscape_award_nodes(award_investigator, max_depth, node_array, depth)
      }
    }
  end
  node_array
end


def generate_cytoscape_award_edges(investigator, depth, nodes_array_hash, edge_array=[], include_intra_node_connections=false)
  #         edges: [ { id: "e1", label: "Edge 1", weight: 1.1, source: "n1", target: "n3" },
  #                  { id: "e2", label: "Edge 2", weight: 3.3, source:"n2", target:"n1"} ]
  investigator_index = investigator.id.to_s
  investigator.investigator_proposals.each { |i_award| 
    award_index = "A_#{i_award.proposal_id}"
    if award_index and ! cytoscape_edge_array_has_key?(edge_array, award_index, investigator_index)
      tooltiptext=investigator_award_edge_tooltip(i_award,investigator,depth)
      edge_array << cytoscape_edge_hash(edge_array.length, investigator_index, award_index, i_award.role, i_award.proposal.total_amount, tooltiptext)
      # now add all the investigator - award connections
      edge_array = generate_cytoscape_award_investigator_edges(i_award.proposal,edge_array,depth)
      # go one more layer down to add all the intermediate edges
      if include_intra_node_connections
        i_award.proposal.investigator_proposals.each { |inv_award|
          inv_award_index = inv_award.investigator_id.to_s
          if inv_award_index and cytoscape_array_has_key?(nodes_array_hash, inv_award_index) and ! cytoscape_edge_array_has_key?(edge_array, award_index, inv_award_index)
            tooltiptext=investigator_award_edge_tooltip(i_award,inv_award.investigator,depth)
            edge_array << cytoscape_edge_hash(edge_array.length, award_index, inv_award_index, inv_award.role, i_award.proposal.total_amount, tooltiptext)
          end
        }
      end
    end
    if (depth > 1)
      i_award.proposal.investigators.each { |inv| 
        edge_array = generate_cytoscape_award_edges(inv, (depth-1), nodes_array_hash, edge_array, include_intra_node_connections)
      }
    end
  }
  edge_array
end

def generate_cytoscape_award_investigator_edges(award,edge_array, depth)
  #         edges: [ { id: "e1", label: "Edge 1", weight: 1.1, source: "n1", target: "n3" },
  #                  { id: "e2", label: "Edge 2", weight: 3.3, source:"n2", target:"n1"} ]
  award_index = "A_#{award.id}"
  award.investigator_proposals.each { |inner_inv_award| 
    investigator_index = inner_inv_award.investigator_id.to_s
    
    if investigator_index and ! cytoscape_edge_array_has_key?(edge_array, award_index, investigator_index)
      tooltiptext=investigator_award_edge_tooltip(inner_inv_award,inner_inv_award.investigator,depth)
      edge_array << cytoscape_edge_hash(edge_array.length, investigator_index, award_index, inner_inv_award.role, award.total_amount, tooltiptext)
    end
  }
  edge_array
end


def investigator_award_edge_tooltip(i_award,investigator,depth)
   "Investigator #{investigator.name}; <br/>" + 
   "Role: #{i_award.role}; <br/>" + 
   "Award: #{i_award.proposal.title}; <br/>" 
end

def award_weight(value)
  value = 1 if value.blank?
  value = 1 if value.to_i.blank?
  value = value.to_i/100000
  # value is in 100K increments
  case value.to_i
  when 400..200000
    220
  when 200..400
    180
  when 100..200
    150
  when 50..100
    80
  when 25..50
    50
  when 10..25
    35
  when 5..10
    25
  else
    10
  end

end

def current_award_info(investigator_awards,role="", split_allocations=false)
  return "" if investigator_awards.blank? or investigator_awards.length < 1
  total = award_total(investigator_awards,role, Date.today, split_allocations)
  number_to_humanized(total)
end

def award_info(investigator_awards,role="", split_allocations=false)
  return "" if investigator_awards.blank? or investigator_awards.length < 1
  total = award_total(investigator_awards,role, "", split_allocations)
  number_to_humanized(total)
end

def award_total(investigator_awards,role="", by_date="", split_allocations=false)
  total = 0
  if !role.blank? and role.class.to_s =~ /string/i
    role = role.split(",")
  end
  investigator_awards.each { |inv_award|
    if role.blank? or (!inv_award.role.blank? and role.include?(inv_award.role.downcase)) 
      if by_date.blank? or inv_award.proposal.project_end_date.blank? or inv_award.proposal.project_end_date >= by_date
        this_total = inv_award.proposal.total_amount.to_i
        this_total = this_total/inv_award.proposal.investigator_proposals.count if split_allocations
        total+= this_total
      end
    end
  }
  total
end

def number_to_humanized(amount)
  case amount.to_i
  when 1..10000
    amount
  when 10000..500000
    "#{(amount.to_i/100).to_f/10} thousand"
  when 500000..5000000
    "#{(amount.to_i/10000).to_f/100} million"
  when 5000000..500000000
    "#{(amount.to_i/100000).to_f/10} million"
  when 500000000..5000000000000
    "#{(amount.to_i/100000000).to_f/10} billion"
  else
    amount
  end
end
