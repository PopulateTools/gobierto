# frozen_string_literal: true

module GobiertoCommon
  module GobiertoSeeder
    class ModuleSeeder
      def self.seed(module_name, site)
        module_path = module_name.underscore
        module_seeds_path = Rails.root.join("db/seeds/modules/#{module_path}")
        return unless Dir.exist?(module_seeds_path)

        return unless site.configuration.modules.include?(module_name)

        require "#{module_seeds_path}/seeds"
        GobiertoSeeds::Recipe.run(site)
      end
    end
  end
end
