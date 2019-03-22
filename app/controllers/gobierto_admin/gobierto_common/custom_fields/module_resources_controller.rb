# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    module CustomFields
      class ModuleResourcesController < BaseController
        before_action :check_permissions!

        def index
          @available_resources = modules_with_custom_fields.reject { |module_name, resources| resources.blank? || !current_admin.module_allowed?(module_name, current_site) }
        end

        def check_permissions!
          raise_module_not_allowed unless current_admin.can_edit_custom_fields?
        end

        private

        def modules_with_custom_fields
          @modules_with_custom_fields ||= current_site.configuration.modules.map do |module_name|
            [module_name, module_name.constantize.try(:classes_with_custom_fields)]
          end.to_h
        end
      end
    end
  end
end
