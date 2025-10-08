# frozen_string_literal: true

module GobiertoAdmin
  class AdminActionsManager
    attr_reader :module_name, :site

    MANAGERS = {
      "gobierto_plans" => ::GobiertoPlans::AdminActionsManager
    }.freeze

    def self.for(module_name, site)
      normalized_module_name = module_name.to_s.underscore

      manager_class = MANAGERS[normalized_module_name] || self

      if manager_class == self
        new(normalized_module_name, site)
      else
        manager_class.new(normalized_module_name, site)
      end
    end

    def initialize(module_name, site)
      @site = site
      raise ArgumentError, "Invalid module name" unless modules.include?(module_name)

      @module_name = module_name
    end

    def action_allowed?(admin:, action_name:, resource: nil)
      admin.managing_user? || admin.send(module_name + "_permissions").on_site(site).where(action_name:).any?
    end

    def action_names
      []
    end

    private

    def modules
      @modules ||= site.configuration.modules.map(&:underscore)
    end
  end
end
