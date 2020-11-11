# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoDashboards
    class SettingsForm < BaseForm

      VALID_DASHBOARDS_NAMES = %w(contracts subsidies costs)

      attr_writer(
        :site_id,
        :dashboards_config
      )

      delegate :persisted?, to: :gobierto_module_settings
      validates :site, :dashboards_config, presence: true
      validate :validate_dashboards_config_format, :validate_dashboards_config_values

      def save
        valid? && save_settings
      end

      def site_id
        @site_id ||= gobierto_module_settings.site_id
      end

      def site
        @site ||= Site.find site_id
      end

      def dashboards_config
        @dashboards_config ||= gobierto_module_settings.dashboards_config.present? ? JSON.pretty_generate(gobierto_module_settings.dashboards_config) : nil
      end

      def gobierto_module_settings
        @gobierto_module_settings ||= existing_gobierto_module_settings || build_gobierto_module_settings
      end

      private

      def save_settings
        @gobierto_module_settings = gobierto_module_settings.tap do |settings_attributes|
          settings_attributes.module_name = module_name
          settings_attributes.site_id = site_id
          settings_attributes.dashboards_config = parsed_dashboards_config
        end

        if @gobierto_module_settings.save
          true
        else
          promote_errors(@gobierto_module_settings.errors)
          false
        end
      end

      def validate_dashboards_config_format
        if not valid_dashboards_config_format?
          errors.add :dashboards_config, :invalid_format
        end
      end

      def validate_dashboards_config_values
        return if dashboards_config.blank?
        return if not valid_dashboards_config_format?

        if not parsed_dashboards_config.has_key?('dashboards')
          errors.add :dashboards_config, :invalid_values
        end

        if parsed_dashboards_config.fetch('dashboards', {}).keys.any?{|name| !VALID_DASHBOARDS_NAMES.include?(name) }
          errors.add :dashboards_config, :invalid_values
        end
      end

      def parsed_dashboards_config
        @parsed_dashboards_config ||= begin
          return if dashboards_config.blank?
          JSON.parse(dashboards_config).with_indifferent_access
        end
      end

      def valid_dashboards_config_format?
        parsed_dashboards_config
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
        self.class.module_parent.name.demodulize
      end

    end
  end
end
