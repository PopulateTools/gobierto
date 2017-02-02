Site.all.each do |site|
  # Site settings
  GobiertoPeople::Setting.find_or_create_by! site: site, key: "home_text_ca"
  GobiertoPeople::Setting.find_or_create_by! site: site, key: "home_text_es"
end
