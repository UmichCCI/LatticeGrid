module CcsgHelper

  CCSGOptions = [
    ["Core Members (Primary Appointments)", "CoreMember Primary"],
    ["Core Members (All Appointments)", "CoreMember Primary SecondaryTertiary"],
    ["All Members (Primary Appointments)", "CoreMember AssociateMember Primary"],
    ["All Members (All Appointments)", "CoreMember AssociateMember Primary SecondaryTertiary"]
  ]

  CCSGDefault = "CoreMember Primary"


  def affiliation_types_list(prefix='')
    out = '<ul class="noBullets">'
    CCSGOptions.each do |text, value|
      common_id = prefix + '_affiliation_types_' + sanitize_to_id(value)

      out += '<li>'
      out += radio_button_tag 'affiliation_types', value, value == CCSGDefault, :id => common_id
      out += label_tag common_id, text
      out += '</li>'
    end
    out += '</ul>'
    out
  end

  def affiliation_filter_string(typelist)
    # Typelist should be either a string or an array of strings.

    out = '<p style="font-weight:bold; margin-top: 6pt;">'
    if typelist.include?('CoreMember') && typelist.include?('AssociateMember')
      out << 'All members (core and non-core) '
    else # if typelist.include?('CoreMember')
      out << 'Only core members '
    end

    out << 'are included in this list.  '

    if typelist.include?('Primary') && typelist.include?('SecondaryTertiary')
      out << 'All appointment types (primary, secondary, and tertiary) '
    else # if typelist.include?('Primary')
      out << 'Only primary appointments '
    end

    out << 'are included in the statistics.'
    out << '</p>'
    out
  end
end
