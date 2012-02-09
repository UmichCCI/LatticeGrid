class OrganizationalUnit < ActiveRecord::Base
  acts_as_nested_set
  attr_accessor :collaboration_matrix

  has_many :investigator_appointments,
      :conditions => ['investigator_appointments.end_date is null or investigator_appointments.end_date >= :today', {:today => Date.today }]
  has_many :joint_appointments,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'Joint' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :secondary_appointments,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'Secondary' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :memberships,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type IN ('Member', 'PrimaryMember', 'SecondaryMember', 'TertiaryMember') and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :primary_memberships,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'PrimaryMember' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :secondary_memberships,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'SecondaryMember' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :tertiary_memberships,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'TertiaryMember' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :associate_memberships,
       :class_name => "InvestigatorAppointment",
       :conditions => ["investigator_appointments.type IN ('AssociateMember', 'PrimaryAssociateMember', 'SecondaryAssociateMember', 'TertiaryAssociateMember') and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :primary_associate_memberships,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'PrimaryAssociateMember' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :secondary_associate_memberships,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'SecondaryAssociateMember' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :tertiary_associate_memberships,
      :class_name => "InvestigatorAppointment",
      :conditions => ["investigator_appointments.type = 'TertiaryAssociateMember' and (investigator_appointments.end_date is null or investigator_appointments.end_date >= :today)", {:today => Date.today }]
  has_many :primary_faculty,  
    :class_name => "Investigator",
    :foreign_key => "home_department_id"
  has_many :primary_faculty_publications,  
    :source => :investigator_abstracts,
    :conditions => ['investigator_abstracts.is_valid = true'],
    :through => :primary_faculty
  has_many :associated_faculty,  
    :source => :investigator,
    :through => :investigator_appointments
  has_many :joint_faculty,  
    :source => :investigator,
    :through => :joint_appointments
  has_many :secondary_faculty,  
    :source => :investigator,
    :through => :secondary_appointments
  has_many :members,
    :source => :investigator,
    :through => :memberships
  has_many :primary_members,
    :source => :investigator,
    :through => :primary_memberships
  has_many :secondary_members,
    :source => :investigator,
    :through => :secondary_memberships
  has_many :tertiary_members,
    :source => :investigator,
    :through => :tertiary_memberships
  has_many :associate_members,
    :source => :investigator,
    :through => :associate_memberships
  has_many :primary_associate_members,
    :source => :investigator,
    :through => :primary_associate_memberships
  has_many :secondary_associate_members,
    :source => :investigator,
    :through => :secondary_associate_memberships
  has_many :tertiary_associate_members,
    :source => :investigator,
    :through => :tertiary_associate_memberships
  has_many :organization_abstracts,
    :conditions => ['organization_abstracts.end_date is null']
  has_many :abstracts,
    :through => :organization_abstracts

    # cache this query in a class instance
    @@all_units = nil
    @@head_node = nil
    @@menu_nodes = nil
    def self.all_units
      @@all_units ||= OrganizationalUnit.find( :all, :order => "sort_order, search_name, name" )
    end
    
    def self.head_node(node_name)
      @@head_node ||= OrganizationalUnit.find_by_abbreviation( node_name ) || OrganizationalUnit.find_by_name( node_name ) 
    end
    
    def self.menu_nodes(node_name)
      @@menu_nodes ||= (OrganizationalUnit.find_by_abbreviation( node_name ) || OrganizationalUnit.find_by_name( node_name )).self_and_descendants
    end
    
    def all_organization_abstracts
      self.self_and_descendants.collect{|unit| unit.organization_abstracts}.flatten.sort_by(&:abstract_id).uniq
    end

    def all_abstract_ids
      self.self_and_descendants.collect{|unit| unit.organization_abstracts.map(&:abstract_id)}.flatten.uniq
    end

    def all_abstracts
      self.self_and_descendants.collect{|unit| unit.abstracts}.flatten.sort {|x,y| y.year+y.pubmed <=> x.year+x.pubmed }.uniq
    end

    def all_members
      self.self_and_descendants.collect{|unit| unit.members}.flatten.sort {|x,y| x.sort_name <=> y.sort_name }.uniq
    end

    def all_primary_members
      self.self_and_descendants.collect(&:primary_members).flatten.sort {|x,y| x.sort_name <=> y.sort_name }.uniq
    end

    def all_primary_associate_members
      self.self_and_descendants.collect(&:primary_associate_members).flatten.sort {|x,y| x.sort_name <=> y.sort_name }.uniq
    end

    def all_secondary_members
      self.self_and_descendants.collect(&:secondary_members).flatten.sort {|x,y| x.sort_name <=> y.sort_name }.uniq
    end

    def all_secondary_associate_members
      self.self_and_descendants.collect(&:secondary_associate_members).flatten.sort {|x,y| x.sort_name <=> y.sort_name }.uniq
    end

    def all_tertiary_members
      self.self_and_descendants.collect(&:tertiary_members).flatten.sort {|x,y| x.sort_name <=> y.sort_name }.uniq
    end

    def all_tertiary_associate_members
      self.self_and_descendants.collect(&:tertiary_associate_members).flatten.sort {|x,y| x.sort_name <=> y.sort_name }.uniq
    end

    def all_associate_members
      self.self_and_descendants.collect(&:associate_members).flatten.sort {|x,y| x.sort_name <=> y.sort_name }.uniq
    end

    def faculty
      (self.primary_faculty + self.associated_faculty).sort {|x,y| x.sort_name <=> y.sort_name }.uniq
    end

    def all_primary_faculty
      self.self_and_descendants.collect(&:primary_faculty).flatten.sort {|x,y| x.sort_name <=> y.sort_name }.uniq
    end

    def all_joint_faculty
      self.self_and_descendants.collect(&:joint_faculty).flatten.sort {|x,y| x.sort_name <=> y.sort_name }.uniq
    end

    def all_secondary_faculty
      self.self_and_descendants.collect(&:secondary_faculty).flatten.sort {|x,y| x.sort_name <=> y.sort_name }.uniq
    end

    # associated_faculty includes joint, secondary and members
    def all_associated_faculty
      self.self_and_descendants.collect(&:associated_faculty).flatten.sort {|x,y| x.sort_name <=> y.sort_name }.uniq
    end

    def primary_or_member_faculty
      (self.primary_faculty + self.members).sort {|x,y| x.sort_name <=> y.sort_name }.uniq
     end

    def all_primary_or_member_faculty
      (all_primary_faculty + all_members).sort {|x,y| x.sort_name <=> y.sort_name }.uniq
    end

    def all_faculty
      (all_primary_faculty + all_associated_faculty).sort {|x,y| x.sort_name <=> y.sort_name }.uniq
    end

    def get_ccsg_faculty_count(column, codes)
      logger.debug "Running get_faculty_count for column #{column} and codes #{codes.inspect}."

      case column
      when :primary
        codes -= ['SecondaryTertiary']
      when :other
        codes -= ['Primary']
        codes += ['SecondaryTertiary']
      when :total
        # Keep the codes the same.
      else
        raise "Unknown column type #{column}."
      end

      codes.uniq!

      logger.debug "Passing codes #{codes.inspect}."

      get_faculty_by_types(codes).length
    end

    def get_faculty_by_types(affiliation_types=nil, ranks=nil)
      #have not implemented rank selectors yet

      # Possible codes:
      # CM, AM, P, ST
      # Calculates an intersection?

      if affiliation_types.blank? or affiliation_types.length == 0
        # Should never happen.
        raise "Unexpected: empty affiliation_types in get_faculty_by_types."
      else
        faculty = []

        if affiliation_types.include? 'CoreMember'
          faculty += all_primary_members if affiliation_types.include? 'Primary'
          if affiliation_types.include? 'SecondaryTertiary'
            faculty += all_secondary_members
            faculty += all_tertiary_members
          end
        end

        if affiliation_types.include? 'AssociateMember'
          faculty += all_primary_associate_members if affiliation_types.include? 'Primary'
          if affiliation_types.include? 'SecondaryTertiary'
            faculty += all_secondary_associate_members
            faculty += all_tertiary_associate_members
          end
        end

        faculty = faculty.sort {|x,y| x.sort_name <=> y.sort_name }.uniq
      end

      faculty
    end

    def all_faculty_publications
      faculty = (all_primary_faculty + all_associated_faculty).uniq
      faculty.collect(&:abstracts).flatten.uniq
    end

    def highimpactall_ccsg_publications_by_date( faculty, start_date, end_date, exclude_letters=nil )
      if exclude_letters.blank? or ! exclude_letters
        faculty.collect{|f| f.abstracts.hightimpactccsg_abstracts_by_date(start_date, end_date)}.flatten.uniq
      else
        faculty.collect{|f| f.abstracts.exclude_letters.highimpactccsg_abstracts_by_date(start_date, end_date)}.flatten.uniq
      end
    end

    def shared_with_org( org_id )
       abs = self.all_abstracts
       OrganizationalUnit.find(org_id).all_abstracts & abs
    end
      
    def abstract_data( page=1 )
       self.all_abstracts.paginate(:page => page,
        :per_page => 20, 
        :order => "year DESC, abstracts.publication_date DESC, electronic_publication_date DESC, authors ASC")
    end

    def display_year_data( year=2008 )
      self.abstracts.all(
        :order => "investigators.last_name ASC,authors ASC",
        :include => [:investigators],
    		:conditions => ['year = :year', 
     		      {:year => year }])
    end

    def display_data_by_date( start_date, end_date )
      self.abstracts.all(
        :order => "year DESC, investigators.last_name ASC,authors ASC",
        :include => [:investigators],
    		:conditions => [' abstracts.publication_date between :start_date and :end_date', 
     		      {:start_date => start_date, :end_date => end_date }])
    end

    def get_minimal_all_data( )
      self.all_abstracts
    end

  #    def investigator_abstracts
  #      proxy_target.collect(&:investigator_abstract).uniq
  #      def abstract
  #        proxy_target.collect(&:abstract)
  #      end
  #    end
  #  has_many :investigator_abstracts, :through => :investigators
  #  has_many :abstracts, :through => :investigator_abstracts

  def self.collaborations( start_date=nil, end_date=nil )
    abstracts=nil
    if end_date.blank? and start_date.blank?
      abstracts=Abstract.find(:all)
    elsif start_date.blank?
      abstracts=Abstract.find(:all,
     		:conditions => [' abstracts.publication_date <= :end_date or electronic_publication_date <= :end_date ', 
     		      {:end_date => end_date }])
    elsif end_date.blank?
      abstracts=Abstract.find(:all,
     		:conditions => [' abstracts.publication_date >= :start_date or electronic_publication_date >= :start_date ', 
     		      {:start_date => start_date}])
    else
      abstracts=Abstract.find(:all,
     		:conditions => [' abstracts.publication_date between :start_date and :end_date or electronic_publication_date between :start_date and :end_date ', 
     		      {:start_date => start_date, :end_date => end_date }])
    end
    primary_orgs = find(:all, :include => [:primary_faculty], :conditions => [' investigators.id > 0'])
    orgs=find(:all, :order => "id", 
      :include => [:primary_faculty_publications], 
      :conditions => [' id IN (:org_ids) ', 
 		      {:org_ids => primary_orgs.collect(&:id) }])
    init_matrix(orgs,abstracts)
    build_matrix(orgs)
  end
  
  private
  
  def self.init_matrix(orgs, abstracts)
    abstractids=abstracts.collect(&:id)
    orgs.each do |org|
      org.collaboration_matrix = Hash.new if org.collaboration_matrix.nil?
      org.collaboration_matrix[org.id] = abstractids & org.all_faculty_publications.collect(&:abstract_id)
    end
  end
  def self.build_matrix(orgs)
    orgs.each do |org_outer|
      orgs.each do |org_inner|
          org_outer.collaboration_matrix[org_inner.id] = org_outer.collaboration_matrix[org_outer.id] & org_inner.collaboration_matrix[org_inner.id] 
      end
    end
  end

end
