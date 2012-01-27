
# does CCSG access require authentication?
def LatticeGridHelper.require_authentication?
  return false
end

# support editing investigator profiles? Implies that authentication is supported!
def LatticeGridHelper.allow_profile_edits?
  return false
end

def LatticeGridHelper.include_summary_by_member?
  return false
end

# show research description
def LatticeGridHelper.show_research_description?
  return false
end

# for cancer centers to 'deselect' publications from inclusion in the CCSG report
def LatticeGridHelper.show_cancer_related_checkbox?
  return true
end

def LatticeGridHelper.page_title
  return 'U of M Cancer Faculty Publications'
end

def LatticeGridHelper.header_title
  return 'Cancer Center Member Publications and Abstracts Site'
end

def LatticeGridHelper.menu_head_abbreviation
  "University of Michigan Comprehensive Cancer Center"
end

def LatticeGridHelper.high_impact_issns
  ["1097-6256", "1740-1526", "1471-0072", "0006-4971", "1535-6108", "0732-183X", "0140-6736", "0025-7079", "0028-0836", "0022-1007", "0017-9124", "0022-1767", "0883-6612", "0027-8874", "1550-4131", "1471-0048", "0031-6997", "0090-0036", "1471-0056", "0008-5472", "1529-2908", "0002-9297", "1087-0156", "1057-9249", "1553-4006", "0092-8674", "0306-4603", "1074-7613", "1078-0432", "0027-8424", "0896-6273", "0964-4563", "0003-9926", "0965-2140", "1462-2203", "1545-9985", "0884-8734", "1474-175X", "0002-9262", "0021-9738", "1534-5807", "1934-5909", "0277-9536", "0036-8075", "1946-6234", "1061-4036", "1474-1776", "0091-7435", "0278-6133", "0021-9525", "1748-3387", "0028-4793", "0890-9369", "0016-5085", "0105-2896", "1470-2045", "1465-7392", "0098-7484", "1097-2765", "1474-1733", "1072-8368", "1553-7390", "1078-8956"]
end

def LatticeGridHelper.GetDefaultSchool()
  "UM"
end

def LatticeGridHelper.home_url
  "http://www.cancer.med.umich.edu"
end

def LatticeGridHelper.curl_host
my_env = Rails.env
my_env = 'home' if public_path =~ /Users/ 
case 
  when my_env == 'home': 'localhost:3000'
  when my_env == 'development': 'rails-staging2.nubic.northwestern.edu'
  when my_env == 'staging': 'rails-staging2.nubic.northwestern.edu'
  when my_env == 'production': 'latticegrid-dev.med.umich.edu'
  else 'latticegrid.umich.edu/cancer'
end 
end

def LatticeGridHelper.curl_protocol
my_env = Rails.env
my_env = 'home' if public_path =~ /Users/ 
case 
  when my_env == 'home': 'http'
  when my_env == 'development': 'http'
  when my_env == 'staging': 'http'
  when my_env == 'production': 'http'
  else 'http'
end 
end

def profile_example_summaries()
  ""
end

def LatticeGridHelper.do_ldap?
 (is_admin? and Rails.env != 'production') ? false : true
 false
end


def LatticeGridHelper.ldap_perform_search?
 false
end

def LatticeGridHelper.ldap_host
 "directory.umich.edu"
end

def LatticeGridHelper.ldap_treebase 
 "ou=People, dc=michigan,dc=edu"
end

def LatticeGridHelper.include_awards?
 false
end

def LatticeGridHelper.allowed_ips
 # childrens: 199.125.
 # nmff: 209.107.
 # nmh: 165.20.
 # enh: 204.26
 # ric: 69.216
 [':1','127.0.*','165.124.*','129.105.*','199.125.*','209.107.*','165.20.*','204.26.*','69.216.*']
end

# build LatticeGridHelper.institutional_limit_search_string to identify all the publications at your institution 

def LatticeGridHelper.institutional_limit_search_string 
 # '((mott[ad]) AND (hospital[ad])) OR (University of Michigan[ad])'
  '(University of Michigan[ad])'
end

# limit searches to include the institutional_limit_search_string
def LatticeGridHelper.global_limit_pubmed_search_to_institution?
#  true
 false 
end

def LatticeGridHelper.do_ldap?
  false
end

def LatticeGridHelper.member_types_map
  {
    'PrimaryCore' => PrimaryMember,
    'PrimaryNonCore' => PrimaryAssociateMember,
    'SecondaryCore' => SecondaryMember,
    'SecondaryNonCore' => SecondaryAssociateMember
  }
end
