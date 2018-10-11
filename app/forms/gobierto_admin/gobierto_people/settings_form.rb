# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPeople
    class SettingsForm < BaseForm

      ENCRYPTED_SETTING_PLACEHOLDER = 'encrypted_setting_placeholder'

      attr_accessor(
        :site_id,
        :home_text_es,
        :home_text_ca,
        :home_text_en,
        :submodules_enabled,
        :political_groups_vocabulary_id
      )

      delegate :persisted?, to: :gobierto_module_settings

      validates :ibm_notes_usr, :ibm_notes_pwd, presence: true, if: :ibm_notes_integration_selected?
      validates :ibm_notes_usr, :ibm_notes_pwd, absence: true, unless: :ibm_notes_integration_selected?

      def save
        valid? && save_settings
      end

      def gobierto_module_settings
        @gobierto_module_settings ||= gobierto_module_settings_class.find_by(site_id: site_id, module_name: "GobiertoPeople") || build_gobierto_module_settings
      end

      def site_id
        @site_id ||= gobierto_module_settings.site_id
      end

      def home_text_es
        @home_text_es ||= gobierto_module_settings.home_text_es
      end

      def home_text_ca
        @home_text_ca ||= gobierto_module_settings.home_text_ca
      end

      def home_text_en
        @home_text_en ||= gobierto_module_settings.home_text_en
      end

      def submodules_enabled
        @submodules_enabled ||= gobierto_module_settings.submodules_enabled
      end

      def calendar_integration
        @calendar_integration ||= gobierto_module_settings.calendar_integration
      end

      def ibm_notes_usr
        @ibm_notes_usr ||= gobierto_module_settings.ibm_notes_usr
      end

      def ibm_notes_pwd
        @ibm_notes_pwd ||= gobierto_module_settings.ibm_notes_pwd
      end

      def dummy_ibm_notes_usr
        html_dummy_for_encrypted_setting(ibm_notes_usr)
      end

      def dummy_ibm_notes_pwd
        html_dummy_for_encrypted_setting(ibm_notes_pwd)
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
          settings_attributes.module_name = "GobiertoPeople"
          settings_attributes.site_id = site_id
          settings_attributes.home_text_es = home_text_es
          settings_attributes.home_text_ca = home_text_ca
          settings_attributes.home_text_en = home_text_en
          settings_attributes.submodules_enabled = submodules_enabled.select{|m| m.present?}
          settings_attributes.calendar_integration = calendar_integration
          settings_attributes.political_groups_vocabulary_id = political_groups_vocabulary_id

          set_ibm_notes_integration_settings(settings_attributes)
        end

        if @gobierto_module_settings.save
          true
        else
          promote_errors(@gobierto_module_settings.errors)
          false
        end
      end

      private

      def ibm_notes_integration_selected?
        calendar_integration == 'ibm_notes'
      end

      def set_ibm_notes_integration_settings(settings_attributes)
        if ibm_notes_integration_selected?
          settings_attributes.ibm_notes_usr = encrypted_ibm_notes_usr
          settings_attributes.ibm_notes_pwd = encrypted_ibm_notes_pwd
        else
          settings_attributes.ibm_notes_usr = nil
          settings_attributes.ibm_notes_pwd = nil
        end
      end

      def encrypted_ibm_notes_usr
        if ibm_notes_usr.present? && ibm_notes_usr != ENCRYPTED_SETTING_PLACEHOLDER
          ::SecretAttribute.encrypt(ibm_notes_usr)
        elsif ibm_notes_usr == ENCRYPTED_SETTING_PLACEHOLDER
          gobierto_module_settings.ibm_notes_usr
        else
          nil
        end
      end

      def encrypted_ibm_notes_pwd
        if ibm_notes_pwd.present? && ibm_notes_pwd != ENCRYPTED_SETTING_PLACEHOLDER
          ::SecretAttribute.encrypt(ibm_notes_pwd)
        elsif ibm_notes_pwd == ENCRYPTED_SETTING_PLACEHOLDER
          gobierto_module_settings.ibm_notes_pwd
        else
          nil
        end
      end

      def html_dummy_for_encrypted_setting(plain_text_setting)
        if plain_text_setting.present? && plain_text_setting != ENCRYPTED_SETTING_PLACEHOLDER
          ENCRYPTED_SETTING_PLACEHOLDER
        else
          plain_text_setting
        end
      end

    end
  end
end
