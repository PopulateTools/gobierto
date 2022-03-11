# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoData
    class SettingsForm < BaseForm
      DEFAULT_API_SETTINGS = {
        "max_dataset_size_for_queries" => APP_CONFIG[:populate_data][:max_dataset_size_for_queries].to_i
      }.freeze

      def self.api_settings_keys
        @api_settings_keys ||= DEFAULT_API_SETTINGS.keys.map { |key| "api_settings_#{key}" }
      end

      attr_writer(
        :site_id,
        :db_config,
        :frontend_enabled,
        *api_settings_keys
      )

      delegate :persisted?, to: :gobierto_module_settings
      validates :site, :db_config, presence: true
      validate :db_config_format, :db_config_connection

      def save
        valid? && save_settings
      end

      def gobierto_module_settings
        @gobierto_module_settings ||= gobierto_module_settings_class.find_by(site_id: site_id, module_name: module_name) || build_gobierto_module_settings
      end

      def site_id
        @site_id ||= gobierto_module_settings.site_id
      end

      def site
        @site ||= Site.find site_id
      end

      def db_config
        @db_config ||= gobierto_module_settings.db_config.present? ? JSON.pretty_generate(gobierto_module_settings.db_config) : nil
      end

      def frontend_enabled
        @frontend_enabled ||= !gobierto_module_settings.frontend_disabled
      end

      def api_settings_max_dataset_size_for_queries
        api_setting_for("max_dataset_size_for_queries").to_i
      end

      private

      def api_setting_for(setting_key)
        instance_variable_get("@api_settings_#{setting_key}") || module_api_settings.fetch(setting_key, DEFAULT_API_SETTINGS[setting_key])
      end

      def module_api_settings
        @module_api_settings ||= gobierto_module_settings.api_settings || {}
      end

      def db_config_format
        return if db_config.blank?

        JSON.parse(db_config).with_indifferent_access
      rescue JSON::ParserError
        errors.add :db_config, :invalid_format
      end

      def db_config_connection
        return if errors.added? :db_config, :invalid_format

        config = db_config_format

        ::GobiertoData::Connection.test_connection_config(config, :read_db_config)
        ::GobiertoData::Connection.test_connection_config(config, :read_draft_db_config) if config&.has_key?(:read_draft_db_config)
        ::GobiertoData::Connection.test_connection_config(config, :write_db_config) if config&.has_key?(:write_db_config)
      rescue ActiveRecord::ActiveRecordError, PG::Error => e
        errors.add(:db_config, :invalid_connection, error_message: e.message)
      end

      def gobierto_module_settings_class
        ::GobiertoModuleSettings
      end

      def module_name
        self.class.module_parent.name.demodulize
      end

      def build_gobierto_module_settings
        gobierto_module_settings_class.new
      end

      def save_settings
        @gobierto_module_settings = gobierto_module_settings.tap do |settings_attributes|
          settings_attributes.module_name = module_name
          settings_attributes.site_id = site_id
          settings_attributes.db_config = db_config_clean
          settings_attributes.frontend_disabled = frontend_enabled != "1"
          settings_attributes.api_settings = DEFAULT_API_SETTINGS.keys.each_with_object({}) do |key, settings|
            settings[key] = send("api_settings_#{key}")
          end
        end

        if @gobierto_module_settings.save
          true
          touch_datasets
        else
          promote_errors(@gobierto_module_settings.errors)
          false
        end
      end

      def db_config_clean
        config = db_config_format
        return config if config.blank?

        config.has_key?(:read_db_config) ? config.slice(:read_db_config, :read_draft_db_config, :write_db_config) : { read_db_config: config }
      end

      def touch_datasets
        site.datasets.each(&:touch)
      end

    end
  end
end
