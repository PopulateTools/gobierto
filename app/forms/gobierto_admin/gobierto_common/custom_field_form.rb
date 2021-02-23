# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class CustomFieldForm < BaseForm

      DEFAULT_FIELD_TYPES_ORDER = %w(localized_string string localized_paragraph paragraph numeric date image single_option multiple_options vocabulary_options color plugin).freeze

      attr_accessor(
        :id,
        :site_id,
        :resource_name,
        :name_translations,
        :field_type,
        :options_translations
      )

      attr_writer(
        :instance_class_name,
        :instance_id,
        :options,
        :uid,
        :vocabulary_id,
        :vocabulary_type,
        :plugin_type,
        :date_type,
        :unit_type,
        :plugin_configuration,
        :multiple
      )

      delegate :persisted?, :has_vocabulary?, :allow_multiple?, to: :custom_field

      validates :name_translations, :site, :klass, :field_type, presence: true
      validate :instance_type_is_enabled
      validate :plugin_configuration_format
      validate :plugin_configuration_valid

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

      def instance_class_name
        @instance_class_name ||= parameterize(custom_field.instance_type)
      end

      def instance_type
        @instance_type ||= instance_class_name&.tr("-", "/")&.camelize || custom_field.instance_type
      end

      def instance
        @instance ||= instance_class&.find_by(id: instance_id) || custom_field.instance
      end

      def instance_id
        @instance_id ||= custom_field.instance_id
      end

      def resource_param
        parameterize(class_name)
      end

      def instance_type_param
        parameterize(instance_class_name)
      end

      def human_class_name
        klass.model_name.human
      end

      def available_field_types
        Hash[DEFAULT_FIELD_TYPES_ORDER.product([nil])].merge(::GobiertoCommon::CustomField.field_types)
      end

      def available_vocabulary_options
        ::GobiertoCommon::CustomField.available_vocabulary_options
      end

      def available_date_options
        ::GobiertoCommon::CustomField.date_options
      end

      def available_unit_options
        ::GobiertoCommon::CustomField.unit_options
      end

      def options
        @options ||= {}.tap do |opts|
          opts[:configuration] ||= {}
          opts.merge!(options_translations.except("new_option")) if has_options? && options_translations
          if has_vocabulary?
            opts[:vocabulary_id] = vocabulary_id.to_i if vocabulary_id
            opts[:configuration][:vocabulary_type] = vocabulary_type if vocabulary_type.present?
          end
          if custom_field.date?
            opts[:configuration][:date_type] = date_type
          end
          if custom_field.numeric?
            opts[:configuration][:unit_type] = unit_type
          end
          if custom_field.plugin?
            opts[:configuration][:plugin_type] = plugin_type
            opts[:configuration][:plugin_configuration] = plugin_configuration_format
          end
          if allow_multiple?
            opts[:configuration][:multiple] = multiple?
          end
        end
      end

      def uid
        @uid.presence && @uid.tr("_", " ").parameterize
      end

      def types_with_options
        @types_with_options ||= ::GobiertoCommon::CustomField.field_types_with_options.keys
      end

      def types_with_vocabulary
        @types_with_vocabulary ||= ::GobiertoCommon::CustomField.field_types_with_vocabulary.keys
      end

      def types_with_multiple_setting
        @types_with_multiple_setting ||= ::GobiertoCommon::CustomField.field_types_with_multiple_setting
      end

      def has_options?
        @has_options ||= !has_vocabulary? && custom_field.has_options?
      end

      def valid_resource_name?
        klass.present?
      rescue NameError
        false
      end

      def vocabulary_id
        @vocabulary_id ||= custom_field.vocabulary_id
      end

      def vocabulary_type
        @vocabulary_type ||= custom_field.configuration.vocabulary_type || :single_select
      end

      def plugin_type
        return unless custom_field.plugin?

        @plugin_type ||= custom_field.configuration.dig("plugin_type")
      end

      def plugin_configuration
        return unless plugin&.has_configuration?

        @plugin_configuration ||= custom_field.configuration.plugin_configuration
      end

      def plugin_configuration_defaults
        ::GobiertoCommon::CustomFieldPlugin.all.inject({}) do |defaults, plugin|
          defaults.update(plugin.type => JSON.pretty_generate(plugin.default_configuration))
        end
      end

      def plugin
        ::GobiertoCommon::CustomFieldPlugin.find(plugin_type)
      end

      def unit_type
        @unit_type ||= custom_field.configuration.unit_type || :generic
      end

      def date_type
        @date_type ||= custom_field.configuration.date_type || :date
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def multiple
        @multiple ||= custom_field.configuration.multiple || false
      end

      def multiple?
        multiple == "1" || multiple == true
      end

      private

      def instance_type_is_enabled
        return if instance.blank? || classes_with_custom_fields_at_instance_level.include?(instance_class)

        errors.add(:instance_class_name, I18n.t("errors.messages.invalid"))
      end

      def save_custom_field
        @custom_field = custom_field.tap do |attributes|
          attributes.site_id = site_id
          attributes.class_name = klass.name
          attributes.name_translations = name_translations
          attributes.field_type = field_type
          attributes.options = options
          attributes.uid = uid
          attributes.instance = instance
        end

        return @custom_field if @custom_field.save

        promote_errors(@custom_field.errors)
        false
      end

      def parameterize(name)
        name&.underscore&.tr("/", "-")
      end

      def klass
        @klass ||= begin
                     return unless class_name

                     module_name = class_name.deconstantize
                     klass = class_name.constantize
                     return unless custom_fields_allowed?(module_name, klass)

                     klass
                   end
      end

      def instance_class
        @instance_class ||= begin
                              return unless instance_type

                              klass = instance_type.constantize
                              return unless classes_with_custom_fields_at_instance_level.include? klass

                              klass
                            rescue NameError
                              nil
                            end
      end

      def custom_fields_allowed?(module_name, klass)
        if module_name.blank?
          ::GobiertoCore.classes_with_custom_fields.include?(klass)
        else
          site.configuration.modules.include?(module_name) && module_name.constantize.try(:classes_with_custom_fields)&.include?(klass)
        end
      end

      def custom_fields_relation
        site ? site.custom_fields : ::GobiertoCommon::CustomField.none
      end

      def classes_with_custom_fields_at_instance_level
        @classes_with_custom_fields_at_instance_level ||= class_name.deconstantize.constantize.try(:classes_with_custom_fields_at_instance_level) || []
      end

      def plugin_configuration_format
        return unless plugin_configuration

        JSON.parse(plugin_configuration)
      rescue JSON::ParserError
        errors.add :plugin_configuration, I18n.t("errors.messages.invalid")

        false
      end

      def plugin_configuration_valid
        return unless custom_field.plugin?

        unless ::GobiertoCommon::CustomFieldValidators.const_defined?(plugin_type.classify)
          begin
            ::GobiertoCommon::CustomFieldValidators.const_get(plugin_type.classify)
          rescue NameError
            return
          end
        end

        ::GobiertoCommon::CustomFieldValidators.const_get(plugin_type.classify).new(self).valid?
      end
    end
  end
end
