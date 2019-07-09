# frozen_string_literal: true

module GobiertoPlans
  module ProjectDecoratorProgressAttachment

    extend ActiveSupport::Concern

    private

    def node_plugins_attributes
      super_result = super

      calculation_plugin = ::GobiertoPlans::Node.node_custom_field_records(plan, object).where(custom_field: site.custom_fields.with_plugin_type(:progress)).find_by(item: object)
      if calculation_plugin.present?
        super_result[:progress] = calculation_plugin.functions(version: published_version).progress&.*(100)
      end

      super_result
    end

  end
end
