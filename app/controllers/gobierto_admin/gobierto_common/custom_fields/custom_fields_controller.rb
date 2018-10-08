# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    module CustomFields
      class CustomFieldsController < BaseController
        before_action :check_permissions!
        before_action :check_class, except: :create_option

        def index
          set_class_name

          @class_human_name = @class_name.constantize.model_name.human(count: 2)
          @custom_fields = ::GobiertoCommon::CustomField.where(class_name: @class_name)
        end

        def new
          @custom_field_form = form_class.new(site_id: current_site.id, resource_name: params[:module_resource_name])
          @types_with_options = @custom_field_form.types_with_options
        end

        def create
          @custom_field_form = form_class.new(custom_field_params.merge(site_id: current_site.id, resource_name: params[:module_resource_name]))
          if @custom_field_form.save
            redirect_to(
              admin_common_custom_fields_module_resource_custom_fields_path(module_resource_name: @custom_field_form.resource_param),
              notice: t(".success")
            )
          else
            @types_with_options = @custom_field_form.types_with_options
            render :new
          end
        end

        def create_option
          @new_option_translations = new_option_translations
          generate_key
          render layout: false
        end

        def edit
          find_custom_field

          @custom_field_form = form_class.new(@custom_field.attributes.except(*ignored_custom_field_attributes).merge(site_id: current_site.id))
          @types_with_options = @custom_field_form.types_with_options
        end

        def update
          find_custom_field

          @custom_field_form = form_class.new(custom_field_params.merge(id: @custom_field.id, site_id: current_site.id))
          if @custom_field_form.save
            redirect_to(
              admin_common_custom_fields_module_resource_custom_fields_path(module_resource_name: @custom_field_form.resource_param),
              notice: t(".success")
            )
          else
            @types_with_options = @custom_field_form.types_with_options
            render :edit
          end
        end

        def destroy
          find_custom_field
          module_resource_name = form_class.new(id: params[:id], site_id: current_site.id).resource_param

          if @custom_field.destroy
            redirect_to(
              admin_common_custom_fields_module_resource_custom_fields_path(module_resource_name: module_resource_name),
              notice: t(".success")
            )
          else
            redirect_to(
              admin_common_custom_fields_module_resource_custom_fields_path(module_resource_name: module_resource_name),
              alert: t(".failed")
            )
          end
        end

        private

        def check_permissions!
          raise_module_not_allowed unless current_admin.can_edit_custom_fields?
        end

        def custom_field_params
          params.require(:custom_field).permit(
            :field_type,
            name_translations: [*I18n.available_locales],
            options_translations: {}
          )
        end

        def new_option_translations
          params.require(:translations).permit(I18n.available_locales)
        end

        def set_class_name
          @class_name = params[:module_resource_name].tr("-", "/").camelize
        end

        def ignored_custom_field_attributes
          %w(created_at updated_at class_name site_id uid mandatory position)
        end

        def find_custom_field
          @custom_field = current_site.custom_fields.find(params[:id])
        end

        def generate_key
          @key = SecureRandom.uuid
        end

        def form_class
          ::GobiertoAdmin::GobiertoCommon::CustomFieldForm
        end

        def check_class
          form = form_class.new(resource_name: params[:module_resource_name], id: params[:id], site_id: current_site.id)
          raise_module_not_allowed unless form.valid_resource_name? && current_admin.module_allowed?(form.class_name.deconstantize)
        end
      end
    end
  end
end
