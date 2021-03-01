# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    module CustomFields
      class CustomFieldsController < GobiertoCommon::CustomFields::BaseController
        before_action :check_permissions!
        before_action :check_class, except: :create_option

        def index
          set_class_name

          @custom_field_form = form_class.new(
            resource_name: params[:module_resource_name],
            instance_class_name: params[:instance_type],
            instance_id: params[:instance_id]
          )
          @decorated_instance = ::GobiertoAdmin::BaseResourceDecorator.new(@custom_field_form.instance) if @custom_field_form.instance
          @class_human_name = @class_name.constantize.model_name.human(count: 2)

          @localized_custom_fields = current_site.custom_fields.where(class_name: @class_name, instance: @custom_field_form.instance).localized.sorted
          @not_localized_custom_fields = current_site.custom_fields.where(class_name: @class_name, instance: @custom_field_form.instance).not_localized.sorted
        end

        def new
          @custom_field_form = form_class.new(
            site_id: current_site.id,
            resource_name: params[:module_resource_name],
            instance_class_name: params[:instance_type],
            instance_id: params[:instance_id]
          )
          @decorated_instance = ::GobiertoAdmin::BaseResourceDecorator.new(@custom_field_form.instance) if @custom_field_form.instance
          set_options
        end

        def create
          @custom_field_form = form_class.new(custom_field_params.merge(site_id: current_site.id, resource_name: params[:module_resource_name]))
          if @custom_field_form.save
            touch_instance
            redirect_to(
              admin_common_custom_fields_module_resource_custom_fields_path(
                module_resource_name: @custom_field_form.resource_param,
                instance_type: @custom_field_form.instance_class_name,
                instance_id: @custom_field_form.instance_id
              ),
              notice: t(".success")
            )
          else
            set_options
            @decorated_instance = ::GobiertoAdmin::BaseResourceDecorator.new(@custom_field_form.instance) if @custom_field_form.instance
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
          @decorated_instance = ::GobiertoAdmin::BaseResourceDecorator.new(@custom_field_form.instance) if @custom_field_form.instance
          set_options
        end

        def update
          find_custom_field

          @custom_field_form = form_class.new(custom_field_params.merge(id: @custom_field.id, site_id: current_site.id))
          if @custom_field_form.save
            touch_instance
            redirect_to(
              admin_common_custom_fields_module_resource_custom_fields_path(
                module_resource_name: @custom_field_form.resource_param,
                instance_type: @custom_field_form.instance_class_name,
                instance_id: @custom_field_form.instance_id
              ),
              notice: t(".success")
            )
          else
            set_options
            @decorated_instance = ::GobiertoAdmin::BaseResourceDecorator.new(@custom_field_form.instance) if @custom_field_form.instance
            render :edit
          end
        end

        def destroy
          find_custom_field

          @custom_field_form = form_class.new(id: @custom_field.id, site_id: current_site.id)
          module_resource_name = @custom_field_form.resource_param

          if @custom_field.destroy
            touch_instance
            redirect_to(
              admin_common_custom_fields_module_resource_custom_fields_path(
                module_resource_name: module_resource_name,
                instance_type: @custom_field_form.instance_class_name,
                instance_id: @custom_field_form.instance_id
              ),
              notice: t(".success")
            )
          else
            redirect_to(
              admin_common_custom_fields_module_resource_custom_fields_path(
                module_resource_name: module_resource_name,
                instance_type: @custom_field_form.instance_class_name,
                instance_id: @custom_field_form.instance_id
              ),
              alert: t(".failed")
            )
          end
        end

        private

        def touch_instance
          @custom_field_form&.instance&.touch
        end

        def check_permissions!
          raise_module_not_allowed unless current_admin.can_edit_custom_fields?
        end

        def custom_field_params
          params.require(:custom_field).permit(
            :field_type,
            :uid,
            :vocabulary_id,
            :vocabulary_type,
            :plugin_type,
            :date_type,
            :unit_type,
            :instance_class_name,
            :instance_id,
            :plugin_configuration,
            :multiple,
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
          %w(created_at updated_at class_name site_id mandatory position vocabulary_id instance_type instance_id)
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

        def set_options
          @types_with_options = @custom_field_form.types_with_options
          @types_with_vocabulary = @custom_field_form.types_with_vocabulary
          @types_with_multiple_setting = @custom_field_form.types_with_multiple_setting
        end

        def check_class
          form = form_class.new(resource_name: params[:module_resource_name], id: params[:id], site_id: current_site.id)
          raise_module_not_allowed unless form.valid_resource_name? && current_admin.module_allowed?(form.class_name.deconstantize, current_site)
        end
      end
    end
  end
end
