# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoData
    class SettingsForm < BaseForm

      attr_writer(
        :site_id,
        :db_config,
        :frontend_enabled
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

      private

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
        end

        if @gobierto_module_settings.save
          true
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

    end
  end
end
