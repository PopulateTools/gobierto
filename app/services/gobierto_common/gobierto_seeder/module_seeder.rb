module GobiertoCommon
  module GobiertoSeeder
    class ModuleSeeder
      def self.seed(module_name, site)
        return unless site.configuration.modules.include?(module_name)

        seeder = "GobiertoSeeds::#{module_name.camelize}::Recipe".safe_constantize
        seeder.run(site) if seeder && defined?(seeder)
      end
    end
  end
end
