# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class CustomFieldForm < BaseForm
      attr_accessor(
        :id,
        :site_id,
        :resource_name,
        :name_translations,
        :field_type,
        :options_translations
      )

      attr_writer(
        :options,
        :uid
      )

      delegate :persisted?, to: :custom_field

      validates :name_translations, :site, :klass, :field_type, presence: true

      def custom_field
        @custom_field ||= custom_fields_relation.find_by(id: id) || build_custom_field
      end

      def build_custom_field
        custom_fields_relation.new
      end

      def save
        save_custom_field if valid?
      end

      def class_name
        @class_name ||= custom_field.class_name || resource_name&.tr("-", "/")&.camelize
      end

      def resource_param
        class_name.underscore.tr("/", "-")
      end

      def human_class_name
        klass.model_name.human
      end

      def available_field_types
        ::GobiertoCommon::CustomField.field_types
      end

      def options
        @options ||= options_translations ? options_translations.except("new_option") : {}
      end

      def uid
        @uid.presence && @uid.tr("_", " ").parameterize
      end

      def types_with_options
        @types_with_options ||= ::GobiertoCommon::CustomField.field_types_with_options.keys
      end

      def valid_resource_name?
        klass.present?
      rescue NameError
        false
      end

      private

      def save_custom_field
        @custom_field = custom_field.tap do |attributes|
          attributes.site_id = site_id
          attributes.class_name = klass.name
          attributes.name_translations = name_translations
          attributes.field_type = field_type
          attributes.options = options
          attributes.uid = uid
        end

        return @custom_field if @custom_field.save

        promote_errors(@custom_field.errors)
        false
      end

      def klass
        @klass ||= begin
                     return unless class_name

                     module_name = class_name.deconstantize
                     klass = class_name.constantize
                     return unless site.configuration.modules.include?(module_name) && module_name.constantize.try(:classes_with_custom_fields)&.include?(klass)

                     klass
                   end
      end

      def custom_fields_relation
        site ? site.custom_fields : ::GobiertoCommon::CustomField.none
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end
    end
  end
end
