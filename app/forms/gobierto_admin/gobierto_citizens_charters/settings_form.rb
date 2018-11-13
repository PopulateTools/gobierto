# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    class SettingsForm < BaseForm

      attr_accessor(
        :categories_vocabulary_id
      )

      attr_writer :site_id, :enable_charters, :enable_services, :enable_services_home

      delegate :persisted?, to: :gobierto_module_settings
      validates :site, :categories_vocabulary, presence: true

      def save
        valid? && save_settings
      end

      def gobierto_module_settings
        @gobierto_module_settings ||= gobierto_module_settings_class.find_by(site_id: site_id, module_name: "GobiertoCitizensCharters") || build_gobierto_module_settings
      end

      def enable_charters
        @enable_charters ||= !gobierto_module_settings.disable_charters
      end

      def enable_services
        @enable_services ||= !gobierto_module_settings.disable_services
      end

      def enable_services_home
        @enable_services_home ||= gobierto_module_settings.enable_services_home
      end

      def site_id
        @site_id ||= gobierto_module_settings.site_id
      end

      def site
        @site ||= Site.find site_id
      end

      def vocabularies_options
        site.vocabularies.map do |vocabulary|
          [vocabulary.name, vocabulary.id]
        end
      end

      private

      def gobierto_module_settings_class
        ::GobiertoModuleSettings
      end

      def build_gobierto_module_settings
        gobierto_module_settings_class.new
      end

      def save_settings
        @gobierto_module_settings = gobierto_module_settings.tap do |settings_attributes|
          settings_attributes.module_name = "GobiertoCitizensCharters"
          settings_attributes.site_id = site_id
          settings_attributes.categories_vocabulary_id = categories_vocabulary_id
          settings_attributes.disable_charters = enable_charters != "1"
          settings_attributes.disable_services = enable_services != "1"
          settings_attributes.enable_services_home = enable_services_home == "1"
        end

        if @gobierto_module_settings.save
          true
        else
          promote_errors(@gobierto_module_settings.errors)
          false
        end
      end

      def categories_vocabulary
        @categories_vocabulary ||= site.vocabularies.find_by_id(categories_vocabulary_id)
      end
    end
  end
end
