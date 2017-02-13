module GobiertoSeeds
  class Recipe
    def self.run(site)
      GobiertoPeople::Setting.find_or_create_by! site: site, key: "home_text_ca"
      GobiertoPeople::Setting.find_or_create_by! site: site, key: "home_text_es"
    end
  end
end
