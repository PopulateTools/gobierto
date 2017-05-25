# frozen_string_literal: true

module GobiertoCommon
  module ModuleHelper
    extend ActiveSupport::Concern

    private

    def module_enabled!(site, module_namespace)
      raise_module_not_enabled unless site.configuration.modules.include?(module_namespace.to_s)
    end
  end
end
