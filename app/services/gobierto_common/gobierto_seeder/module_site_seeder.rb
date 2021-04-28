module GobiertoCommon
  module GobiertoSeeder
    class ModuleSiteSeeder
      def self.seed(gobierto_site, module_name, site)
        return unless site.configuration.modules.include?(module_name)

        seeder = "GobiertoSeeds::Sites::#{gobierto_site.camelize}::GobiertoPeople::Recipe".safe_constantize
        seeder.run(site) if seeder && site.configuration.modules.include?(module_name)
      end
    end
  end
end
