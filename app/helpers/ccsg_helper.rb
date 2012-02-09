module CcsgHelper

  CCSGOptions = [
    ["Core Members (Primary)", "CoreMember Primary"],
    ["Core Members (All)", "CoreMember Primary SecondaryTertiary"],
    ["Members (Primary)", "CoreMember AssociateMember Primary"],
    ["Members (All)", "CoreMember AssociateMember Primary SecondaryTertiary"]
  ]
  CCSGDefault = 'Core Members (Primary)'


  def affiliation_types_list(prefix='')
    out = '<ul class="noBullets">'
    CCSGOptions.each do |text, value|
      common_id = prefix + '_affiliation_types_' + sanitize_to_id(value)

      out += '<li>'
      out += radio_button_tag 'affiliation_types', value, text == CCSGDefault, :id => common_id
      out += label_tag common_id, text
      out += '</li>'
    end
    out += '</ul>'
    out
  end
end
