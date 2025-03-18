# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoVisualizations
    class SettingsForm < BaseForm

      VALID_VISUALIZATION_NAMES = %w(contracts subsidies costs debts odss)

      attr_writer(
        :site_id,
        :visualizations_config
      )

      delegate :persisted?, to: :gobierto_module_settings
      validates :site, :visualizations_config, presence: true
      validate :validate_visualizations_config_format, :validate_visualizations_config_values

      def save
        valid? && save_settings
      end

      def site_id
        @site_id ||= gobierto_module_settings.site_id
      end

      def site
        @site ||= Site.find site_id
      end

      def visualizations_config
        @visualizations_config ||= gobierto_module_settings.visualizations_config.present? ? JSON.pretty_generate(gobierto_module_settings.visualizations_config) : nil
      end

      def gobierto_module_settings
        @gobierto_module_settings ||= existing_gobierto_module_settings || build_gobierto_module_settings
      end

      private

      def save_settings
        @gobierto_module_settings = gobierto_module_settings.tap do |settings_attributes|
          settings_attributes.module_name = module_name
          settings_attributes.site_id = site_id
          settings_attributes.visualizations_config = parsed_visualizations_config
        end

        if @gobierto_module_settings.save
          true
        else
          promote_errors(@gobierto_module_settings.errors)
          false
        end
      end

      def validate_visualizations_config_format
        if not valid_visualizations_config_format?
          errors.add :visualizations_config, :invalid_format
        end
      end

      def validate_visualizations_config_values
        return if visualizations_config.blank?
        return if not valid_visualizations_config_format?

        if not parsed_visualizations_config.has_key?('visualizations')
          errors.add :visualizations_config, :invalid_values
        end

        if parsed_visualizations_config.fetch('visualizations', {}).keys.any?{|name| !VALID_VISUALIZATION_NAMES.include?(name) }
          errors.add :visualizations_config, :invalid_values
        end
      end

      def parsed_visualizations_config
        @parsed_visualizations_config ||= begin
          return if visualizations_config.blank?
          JSON.parse(visualizations_config).with_indifferent_access
        end
      end

      def valid_visualizations_config_format?
        parsed_visualizations_config
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
