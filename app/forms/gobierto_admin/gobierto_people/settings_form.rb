module GobiertoAdmin
  module GobiertoPeople
    class SettingsForm
      include ActiveModel::Model

      attr_accessor(
        :site_id,
        :home_text_es,
        :home_text_ca,
        :home_text_en,
        :submodules_enabled,
        :calendar_integration,
      )

      delegate :persisted?, to: :gobierto_module_settings

      def save
        save_settings if valid?
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
        end

        if @gobierto_module_settings.valid?
          @gobierto_module_settings.save

          @gobierto_module_settings
        else
          promote_errors(@gobierto_module_settings.errors)

          false
        end
      end

      protected

      def promote_errors(errors_hash)
        errors_hash.each do |attribute, message|
          errors.add(attribute, message)
        end
      end
    end
  end
end
