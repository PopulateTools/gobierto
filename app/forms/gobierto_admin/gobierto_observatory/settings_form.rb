# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoObservatory
    class SettingsForm < BaseForm

      VALID_OBSERVATORY_KEYS = %w(map)

      attr_writer(
        :site_id,
        :observatory_config
      )

      delegate :persisted?, to: :gobierto_module_settings
      validates :site, :observatory_config, presence: true
      validate :validate_observatory_config_format, :validate_observatory_config_values

      def save
        valid? && save_settings
      end

      def site_id
        @site_id ||= gobierto_module_settings.site_id
      end

      def site
        @site ||= Site.find site_id
      end

      def observatory_config
        @observatory_config ||= gobierto_module_settings.observatory_config.present? ? JSON.pretty_generate(gobierto_module_settings.observatory_config) : nil
      end

      def gobierto_module_settings
        @gobierto_module_settings ||= existing_gobierto_module_settings || build_gobierto_module_settings
      end

      private

      def save_settings
        @gobierto_module_settings = gobierto_module_settings.tap do |settings_attributes|
          settings_attributes.module_name = module_name
          settings_attributes.site_id = site_id
          settings_attributes.observatory_config = parsed_observatory_config
        end

        if @gobierto_module_settings.save
          true
        else
          promote_errors(@gobierto_module_settings.errors)
          false
        end
      end

      def validate_observatory_config_format
        if not valid_observatory_config_format?
          errors.add :observatory_config, :invalid_format
        end
      end

      def validate_observatory_config_values
        return if observatory_config.blank?
        return if not valid_observatory_config_format?

        if not parsed_observatory_config.has_key?('observatory')
          errors.add :observatory_config, :invalid_values
        end

        if parsed_observatory_config.fetch('observatory', {}).keys.any?{|name| !VALID_OBSERVATORY_KEYS.include?(name) }
          errors.add :observatory_config, :invalid_values
        end
      end

      def parsed_observatory_config
        @parsed_observatory_config ||= begin
          return if observatory_config.blank?
          JSON.parse(observatory_config).with_indifferent_access
        end
      end

      def valid_observatory_config_format?
        parsed_observatory_config
        true
      rescue JSON::ParserError
        false
      end

      def existing_gobierto_module_settings
        gobierto_module_settings_class.find_by(site_id: site_id, module_name: module_name)
      end

      def build_gobierto_module_settings
        gobierto_module_settings_class.new
      end

      def gobierto_module_settings_class
        ::GobiertoModuleSettings
      end

      def module_name
        self.class.superclass.name.demodulize
      end

    end
  end
end
