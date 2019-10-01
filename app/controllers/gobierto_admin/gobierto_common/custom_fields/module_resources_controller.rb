# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    module CustomFields
      class ModuleResourcesController < GobiertoCommon::CustomFields::BaseController
        before_action :check_permissions!

        def index
          @available_resources = clean_modules_hash modules_with_custom_fields
          @available_instances = clean_modules_hash(models_with_custom_fields_at_instance_level).transform_values do |classes|
            classes.inject({}) do |hash, klass|
              hash.update(klass => CollectionDecorator.new(klass.where(site: current_site).all, decorator: ::GobiertoAdmin::BaseResourceDecorator))
            end
          end
        end

        def check_permissions!
          raise_module_not_allowed unless current_admin.can_edit_custom_fields?
        end

        private

        def models_with_custom_fields_at_instance_level
          @models_with_custom_fields_at_instance_level ||= current_site.configuration.modules.map do |module_name|
            [module_name, module_name.constantize.try(:classes_with_custom_fields_at_instance_level)]
          end.to_h
        end

        def modules_with_custom_fields
          @modules_with_custom_fields ||= current_site.configuration.modules.inject("global" => GobiertoCore.classes_with_custom_fields) do |modules, module_name|
            modules.update(
              module_name => module_name.constantize.try(:classes_with_custom_fields)
            )
          end
        end

        def clean_modules_hash(modules_hash)
          modules_hash.reject { |module_name, content| content.blank? || !current_admin.module_allowed?(module_name, current_site) }
        end
      end
    end
  end
end
