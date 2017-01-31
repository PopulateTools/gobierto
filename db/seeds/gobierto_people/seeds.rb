Site.all.each do |site|
  GobiertoPeople::Setting.create! site: site, key: "home_text_ca"
  GobiertoPeople::Setting.create! site: site, key: "home_text_es"
end
