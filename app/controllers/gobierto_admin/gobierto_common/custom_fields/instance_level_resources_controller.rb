# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    module CustomFields
      class InstanceLevelResourcesController < BaseController
        before_action :check_permissions!

        def show
          @available_resources = models_with_custom_fields
          @decorated_instance = ::GobiertoAdmin::BaseResourceDecorator.new(@class_name.constantize.find_by(id: params[:id]))
        end

        def index
          @available_resources = modules_with_custom_fields.reject { |module_name, resources| resources.blank? || !current_admin.module_allowed?(module_name, current_site) }
        end

        def check_permissions!
          raise_module_not_allowed unless current_admin.can_edit_custom_fields? && current_admin.module_allowed?(module_name, current_site)
        end

        def class_name
          @class_name ||= params[:module_resource_name].tr("-", "/")&.camelize
        end

        def module_name
          @module_name ||= class_name.deconstantize
        end

        private

        def models_with_custom_fields
          @models_with_custom_fields ||= module_name.constantize.send(:classes_with_custom_fields)
        end
      end
    end
  end
end
