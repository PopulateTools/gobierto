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
      @cached_data = {}
    end

    def action_allowed?(admin:, action_name:, resource: nil)
      return true if admin.managing_user?
      return action_name.any? { |single_name| action_allowed?(admin:, action_name: single_name, resource:) } if action_name.is_a?(Array)

      admin.managing_user? || admin.send(module_name + "_permissions").on_site(site).where(action_name:).any?
    end

    def action_names(**_args)
      []
    end

    private

    def modules
      @modules ||= site.configuration.modules.map(&:underscore)
    end

    def cache_data(cache_key)
      return @cached_data[cache_key] if @cached_data.key?(cache_key)

      result = yield
      @cached_data[cache_key] = result
      result
    end
  end
end
