# frozen_string_literal: true

module GobiertoCommon
  module GobiertoSeeder
    class ModuleSiteSeeder
      def self.seed(gobierto_site, module_name, site)
        module_path = module_name.underscore
        site_seeds_path = Rails.root.join("db/seeds/sites/#{gobierto_site}")
        return unless Dir.exist?(site_seeds_path)

        site_module_seeds_path = Rails.root.join("db/seeds/sites/#{gobierto_site}/#{module_path}")
        return unless Dir.exist?(site_module_seeds_path)

        return unless site.configuration.modules.include?(module_name)

        require "#{site_module_seeds_path}/seeds"
        GobiertoSeeds::Recipe.run(site)
      end
    end
  end
end
